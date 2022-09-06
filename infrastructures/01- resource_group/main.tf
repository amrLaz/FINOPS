# [ Providers ]

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.19.1"
    }
  }
}

provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
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
    key                  = "development/infrastructures/resource-group/terraform.tfstate"
  }
}


# [Data]
# ----------------------------------------------------------------------------------------------------
data "azurerm_client_config" "default" {}

# [Locals]
# ----------------------------------------------------------------------------------------------------
locals {
  naming_options = {
    suffix = "${var.environment}-swow"
    prefix = "az"
    lower  = false
  }
  tags = {
    company     = "Exakis Nelite"
    application = "swow"
    environment = var.environment
  }
  address_space = cidrsubnets("192.168.1.0/26", 3, 3, 3, 3, 3, 3)
}


# [ Resource Group ]
# ----------------------------------------------------------------------------------------------------
module "resource_group" {
  source         = "../../modules/microsoft/azurerm/azurerm_resource_group"
  naming_options = local.naming_options
  location       = "westeurope"
  tags = merge(local.tags, {
    environment = "dev"
    owner       = "amr.lazraq@exakis-nelite.com"
  })
}

# [Virtual Network]
# ------------------------------------------------------------------------------------------------------------------------------------
module "virtual_network" {
  source         = "../../modules/microsoft/azurerm/azurerm_virtual_network"
  resource_group = module.resource_group
  naming_options = local.naming_options
  address_space  = local.address_space
}


module "subnet-00" {
  source           = "../../modules/microsoft/azurerm/azurerm_subnet/default"
  resource_group   = module.resource_group
  virtual_network  = module.virtual_network
  naming_options   = merge(local.naming_options, { suffix : "database" })
  address_prefixes = [local.address_space[0]]
}

module "subnet-01" {
  source           = "../../modules/microsoft/azurerm/azurerm_subnet/default"
  resource_group   = module.resource_group
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
  resource_group   = module.resource_group
  virtual_network  = module.virtual_network
  naming_options   = merge(local.naming_options, { suffix : "key-vault" })
  address_prefixes = [local.address_space[2]]
}

# [ Log Analytics Workspace ]
# ----------------------------------------------------------------------------------------------------
module "bb_log_analytics_workspace" {
  source            = "../../modules/microsoft/building-blocks/log_analytics_workspace"
  resource_group    = module.resource_group
  naming_options    = local.naming_options
  sku               = "PerGB2018"
  retention_in_days = 30
}

