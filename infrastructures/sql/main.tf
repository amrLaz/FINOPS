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

# [Virtual Network]
# ------------------------------------------------------------------------------------------------------------------------------------
module "virtual_network" {
  source         = "../../modules/microsoft/azurerm/azurerm_virtual_network"
  resource_group = data.terraform_remote_state.default.outputs.resource_group
  naming_options = local.naming_options
  address_space  = local.address_space
}


module "subnet-00" {
  source           = "../../modules/microsoft/azurerm/azurerm_subnet/default"
  resource_group   = data.terraform_remote_state.default.outputs.resource_group
  virtual_network  = module.virtual_network
  naming_options   = merge(local.naming_options, { suffix : "database" })
  address_prefixes = [local.address_space[0]]
}

module "subnet-01" {
  source           = "../../modules/microsoft/azurerm/azurerm_subnet/default"
  resource_group   = data.terraform_remote_state.default.outputs.resource_group
  virtual_network  = module.virtual_network
  naming_options   = merge(local.naming_options, { suffix : "web-app" })
  address_prefixes = [local.address_space[1]]
  delegation = {
    service_delegation = {
      "name"    = "Microsoft.Web/serverFarms"
      "actions" = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

module "subnet-02" {
  source           = "../../modules/microsoft/azurerm/azurerm_subnet/default"
  resource_group   = data.terraform_remote_state.default.outputs.resource_group
  virtual_network  = module.virtual_network
  naming_options   = merge(local.naming_options, { suffix : "key-vault" })
  address_prefixes = [local.address_space[2]]
}

# [SQL SERVER]----------------------------------------------------------------------------------------------------------------------------
module "mssql_server_default" {
  source         = "../../modules/microsoft/azurerm/azurerm_mssql_server"
  resource_group = data.terraform_remote_state.default.outputs.resource_group
  naming_options = local.naming_options
  tenant_id      = data.azurerm_client_config.default.tenant_id
  object_id      = data.azurerm_client_config.default.object_id
  object_name    = "Azure DevOps"
}



# [DATABASE] --------------------------------------------------------------------------------------------------------------
module "mssql_database" {
  source         = "../../modules/microsoft/azurerm/azurerm_mssql_database"
  server_id      = module.mssql_server_default.id
  naming_options = local.naming_options
}

resource "azurerm_private_endpoint" "mssql_server_pe" {
  name                = module.mssql_server_default.name
  location            = data.terraform_remote_state.default.outputs.resource_group.location
  resource_group_name = data.terraform_remote_state.default.outputs.resource_group.name
  subnet_id           = module.subnet-00.id

  private_service_connection {
    name                           = module.mssql_server_default.name
    private_connection_resource_id = module.mssql_server_default.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}
