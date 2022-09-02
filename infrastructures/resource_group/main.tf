# [Providers]

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


