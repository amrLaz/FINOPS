terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.19.1"
    }
  }
}
# [ Backends ]
# ----------------------------------------------------------------------------------------------------

terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformTfState"
    storage_account_name = "tfstorageamr"
    container_name       = "tfstate"
    key                  = "development/infrastructures/application/terraform.tfstate"
  }
}
# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
    key_vault {
      purge_soft_delete_on_destroy               = false
      purge_soft_deleted_certificates_on_destroy = false
      purge_soft_deleted_keys_on_destroy         = false
      purge_soft_deleted_secrets_on_destroy      = false
    }
    application_insights {
      disable_generated_rule = true
    }
  }
}

# Data --------------------------------------------------------------------------------------------------------------------------------
data "azurerm_client_config" "default" {}
data "terraform_remote_state" "default" {
  backend = "azurerm"
  config = {
    resource_group_name  = "TerraformTfState"
    storage_account_name = "tfstorageamr"
    container_name       = "tfstate"
    key                  = "development/infrastructures/resource-group/terraform.tfstate"
  }
}
data "terraform_remote_state" "analytics" {
  backend = "azurerm"
  config = {
    resource_group_name  = "TerraformTfState"
    storage_account_name = "tfstorageamr"
    container_name       = "tfstate"
    key                  = "development/infrastructures/analytics/terraform.tfstate"
  }
}
data "terraform_remote_state" "sql" {
  backend = "azurerm"
  config = {
    resource_group_name  = "TerraformTfState"
    storage_account_name = "tfstorageamr"
    container_name       = "tfstate"
    key                  = "development/infrastructures/sql/terraform.tfstate"
  }
}
# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
  naming_options = {
    suffix = "${var.environment}-swow"
    prefix = "az"
    lower  = true
  }
  tags = {
    company     = "Exakis Nelite"
    application = "swow"
    environment = var.environment
  }
  address_space = cidrsubnets("192.168.1.0/26", 3, 3, 3)
  administrators = [
    "7daa2b7f-6c00-42cc-9aca-aa820c05fd80"

  ]
}



# [ Key Vault ]
# ----------------------------------------------------------------------------------------------------
module "key_vault" {
  source         = "../../modules/microsoft/azurerm/azurerm_key_vault"
  resource_group = data.terraform_remote_state.default.outputs.resource_group
  naming_options = local.naming_options
  tenant_id      = data.azurerm_client_config.default.tenant_id
}

resource "azurerm_key_vault_access_policy" "default" {
  key_vault_id = module.key_vault.id
  object_id    = data.azurerm_client_config.default.object_id
  tenant_id    = data.azurerm_client_config.default.tenant_id

  secret_permissions = [
    "Get", "Set"
  ]
}

resource "azurerm_key_vault_access_policy" "mssql_server_default" {
  key_vault_id = module.key_vault.id
  object_id    = data.terraform_remote_state.sql.outputs.mssql_server.identity[0].principal_id
  tenant_id    = data.terraform_remote_state.sql.outputs.mssql_server.identity[0].tenant_id

  secret_permissions = [
    "Get"
  ]
}

# { Diagnostic Settings }
module "key_vault_diagnostic_setting" {
  source                     = "../../modules/microsoft/azurerm/azurerm_monitor_diagnostic_setting"
  name                       = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.name
  target_resource_id         = module.key_vault.id
  log_analytics_workspace_id = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.id
}

resource "azurerm_private_endpoint" "key_vault" {
  name                = module.key_vault.name
  location            = data.terraform_remote_state.default.outputs.resource_group.location
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
  subnet_id           = data.terraform_remote_state.sql.outputs.subnet2.id

  private_service_connection {
    name                           = module.key_vault.name
    private_connection_resource_id = module.key_vault.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }
}

# APP-INSIGHTS-------------------------------------------------------------------------------------------------------------------------------------

module "application_insights" {
  source         = "../../modules/microsoft/azurerm/azurerm_application_insights"
  resource_group = data.terraform_remote_state.default.outputs.resource_group
  naming_options = local.naming_options
  workspace_id   = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.id
}

# { Diagnostic Settings }
module "application_insights_diagnostic_setting" {
  source                     = "../../modules/microsoft/azurerm/azurerm_monitor_diagnostic_setting"
  name                       = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.name
  target_resource_id         = module.application_insights.id
  log_analytics_workspace_id = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.id
}

# App-Insights secrets------------------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "application_insights_connection_string" {
  depends_on = [
    azurerm_key_vault_access_policy.mssql_server_default
  ]
  key_vault_id = module.key_vault.id
  name         = "application-insights-connection-string-${random_id.secret.hex}"
  value        = module.application_insights.connection_string
}

resource "azurerm_key_vault_secret" "application_insights_instrumentation_key" {
  depends_on = [
    azurerm_key_vault_access_policy.mssql_server_default
  ]
  key_vault_id = module.key_vault.id
  name         = "application-insights-instrumentation-key-${random_id.secret.hex}"
  value        = module.application_insights.instrumentation_key
}


# [DNS private zone sql]
#  -------------------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "sql_database" {
  name                = "privatelink.database.windows.net"
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
}
resource "azurerm_private_dns_zone_virtual_network_link" "sql_database" {
  name                  = azurerm_private_dns_zone.sql_database.name
  resource_group_name   = data.terraform_remote_state.default.outputs.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.sql_database.name
  virtual_network_id    = data.terraform_remote_state.sql.outputs.virtual-network.id
  registration_enabled  = false

}
# create A record in the private dns zone for the sqlserver
resource "azurerm_private_dns_a_record" "mssql_server" {
  name                = data.terraform_remote_state.sql.outputs.mssql_server.name
  zone_name           = azurerm_private_dns_zone.sql_database.name
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
  ttl                 = 3600
  records             = ["${data.terraform_remote_state.sql.outputs.pe-mssql.private_service_connection[0].private_ip_address}"]
}
# ---------------------------------------------------------------------------------------------------------------
# private dns zone keyvault--------------------------------------------------------------------------------------
resource "azurerm_private_dns_zone" "key_vault" {
  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "key_vault" {
  name                  = azurerm_private_dns_zone.key_vault.name
  resource_group_name   = data.terraform_remote_state.default.outputs.resource_group.name
  private_dns_zone_name = azurerm_private_dns_zone.key_vault.name
  virtual_network_id    = data.terraform_remote_state.sql.outputs.virtual-network.id
  registration_enabled  = false

}

resource "azurerm_private_dns_a_record" "key_vault" {
  name                = module.key_vault.name
  zone_name           = azurerm_private_dns_zone.key_vault.name
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
  ttl                 = 3600
  records = [
    azurerm_private_endpoint.key_vault.private_service_connection.0.private_ip_address
  ]
}


# [ Service Plan ]
# ----------------------------------------------------------------------------------------------------
module "service_plan" {
  source         = "../../modules/microsoft/azurerm/azurerm_service_plan"
  resource_group = data.terraform_remote_state.default.outputs.resource_group
  naming_options = local.naming_options
  os_type        = "Linux"
  sku_name       = "Y1"
}

#  Diagnostic Settings 
# -------------------------------------------
module "service_plan_diagnostic_setting" {
  source                     = "../../modules/microsoft/azurerm/azurerm_monitor_diagnostic_setting"
  name                       = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.name
  target_resource_id         = module.service_plan.id
  log_analytics_workspace_id = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.id
}

# [ Function ]
# ----------------------------------------------------------------------------------------------------
module "worker" {
  source                      = "../../modules/microsoft/azurerm/azurerm_linux_function_app"
  app_service_plan_id         = module.service_plan.id
  resource_group              = data.terraform_remote_state.default.outputs.resource_group
  storage_key_vault_secret_id = azurerm_key_vault_secret.storage_account_connection_string.versionless_id
  naming_options              = local.naming_options
  tags                        = { "scope" = "worker" }
  # always_on                   = true
  http2_enabled = true
  app_settings = {
    APPLICATIONINSIGHTS_CONNECTION_STRING = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_insights_connection_string.versionless_id})"
    APPINSIGHTS_INSTRUMENTATIONKEY        = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_insights_instrumentation_key.versionless_id})"
    # AzureWebJobsTeamConnectionSettings                      = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_connection_string.versionless_id})"
    # AzureWebJobsYammerConnectionSettings                    = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_connection_string.versionless_id})"
    # AzureWebJobsExchangeConnectionSettings                  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_connection_string.versionless_id})"
    # AzureWebJobsOneDriveConnectionSettings                  = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_connection_string.versionless_id})"
    # AzureWebJobsSharePointConnectionSettings                = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.storage_account_connection_string.versionless_id})"
    # AzureAd__TenantId                                       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_tenant_id.versionless_id})"
    # AzureAd__ClientId                                       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_client_id.versionless_id})"
    //AzureAd__ClientSecret                                   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_client_secret.versionless_id})"
    # AzureAd__Domain                                         = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_domain.versionless_id})"
    # AzureAd__Audience                                       = "api://testing.magellan.swow.service"
    # AzureAd__Scope                                          = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_scopes.versionless_id})"
    # AzureAd__CallbackPath                                   = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_callback_path.versionless_id})"
    # AzureAd__Instance                                       = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_service_instance.versionless_id})"
    # AzureAd__ClientCertificates__0__SourceType              = "KeyVault"
    # AzureAd__ClientCertificates__0__KeyVaultUrl             = module.key_vault_default.vault_uri
    # AzureAd__ClientCertificates__0__KeyVaultCertificateName = azurerm_key_vault_certificate.application_service_application_certificate.name
    # Web__ClientId                                           = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_web_client_id.versionless_id})"
    # Web__Scopes                                             = "@Microsoft.KeyVault(SecretUri=${azurerm_key_vault_secret.application_web_scopes.versionless_id})"
    ConnectionStrings__Common = "Server=tcp:${data.terraform_remote_state.sql.outputs.mssql_server.fully_qualified_domain_name},1433;Initial Catalog=${data.terraform_remote_state.sql.outputs.mssql_database.name};Persist Security Info=False;MultipleActiveResultSets=False;Encrypt=True;TrustServerCertificate=False;"
  }
}

# { Diagnostic Settings }
module "worker_diagnostic_setting" {
  source                     = "../../modules/microsoft/azurerm/azurerm_monitor_diagnostic_setting"
  name                       = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.name
  target_resource_id         = module.worker.id
  log_analytics_workspace_id = data.terraform_remote_state.analytics.outputs.log_analytics_workspace.id
}

# { Key Vault - Policies }
resource "azurerm_key_vault_access_policy" "worker" {
  key_vault_id = module.key_vault.id
  object_id    = module.worker.identity[0].principal_id
  tenant_id    = module.worker.identity[0].tenant_id

  secret_permissions = [
    "Get",
  ]
}

# Virtual network integration
# resource "azurerm_app_service_virtual_network_swift_connection" "example" {
#   app_service_id = module.worker.id
#   subnet_id      = data.terraform_remote_state.sql.outputs.subnet1.id
# }
# [STORAGE] --------------------------------------------------------------------------------------------------------------------------------
resource "random_id" "secret" {
  byte_length = 6
}

module "storage_account" {
  source                   = "../../modules/microsoft/azurerm/azurerm_storage_account"
  resource_group           = data.terraform_remote_state.default.outputs.resource_group
  naming_options           = local.naming_options
  account_replication_type = "LRS"
  account_tier             = "Standard"
}

resource "azurerm_key_vault_secret" "storage_account_connection_string" {
  depends_on = [
    azurerm_key_vault_access_policy.mssql_server_default

  ]
  key_vault_id = module.key_vault.id
  name         = "storage-account-connection-string-${random_id.secret.hex}"
  value        = module.storage_account.secondary_connection_string
}






