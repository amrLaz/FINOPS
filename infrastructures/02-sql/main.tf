terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.19.1"
    }
  }
}
#Configure the Microsoft Azure Provider
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

# [Backends]
# ----------------------------------------------------------------------------------------------------

terraform {
  backend "azurerm" {
    resource_group_name  = "TerraformTfState"
    storage_account_name = "tfstorageamr"
    container_name       = "tfstate"
    key                  = "development/infrastructures/sql/terraform.tfstate"
  }
}


# [DATA]---------------------------------------------------------------------------------------------------------------------------------------------

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
data "terraform_remote_state" "app" {
  backend = "azurerm"
  config = {
    resource_group_name  = "TerraformTfState"
    storage_account_name = "tfstorageamr"
    container_name       = "tfstate"
    key                  = "development/infrastructures/app/terraform.tfstate"
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


# [SQL SERVER]----------------------------------------------------------------------------------------------------------------------------
module "mssql_server_default" {
  source         = "../../modules/microsoft/azurerm/azurerm_mssql_server"
  resource_group = data.terraform_remote_state.default.outputs.resource_group
  naming_options = local.naming_options
  tenant_id      = data.azurerm_client_config.default.tenant_id
  object_id      = data.azurerm_client_config.default.object_id
  object_name    = "Azure DevOps"
  tags = merge(local.tags, {
    environment = "dev"
    owner       = "amr.lazraq@exakis-nelite.com"
  })
}

resource "azurerm_key_vault_access_policy" "mssql_server_default" {
  key_vault_id = data.terraform_remote_state.default.outputs.key_vault.id
  object_id    = module.mssql_server.identity[0].principal_id
  tenant_id    = module.mssql_server.identity[0].tenant_id

  secret_permissions = [
    "Get"
  ]
}


# [DATABASE] --------------------------------------------------------------------------------------------------------------
module "mssql_database" {
  source         = "../../modules/microsoft/azurerm/azurerm_mssql_database"
  server_id      = module.mssql_server_default.id
  naming_options = local.naming_options
  tags = merge(local.tags, {
    environment = "dev"
    owner       = "amr.lazraq@exakis-nelite.com"
  })
}

resource "azurerm_private_endpoint" "mssql_server_pe" {
  name                = module.mssql_server_default.name
  location            = data.terraform_remote_state.default.outputs.resource_group.location
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
  subnet_id           = data.terraform_remote_state.default.outputs.subnet0.id
  tags = merge(local.tags, {
    environment = "dev"
    owner       = "amr.lazraq@exakis-nelite.com"
  })
  private_service_connection {
    name                           = module.mssql_server_default.name
    private_connection_resource_id = module.mssql_server_default.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}
