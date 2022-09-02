# [Providers ]
# ----------------------------------------------------------------------------------------------------
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
    key                  = "development/infrastructures/analytics/terraform.tfstate"
  }
}


# [Data]
# ----------------------------------------------------------------------------------------------------
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

# [ Locals ]
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



# [ Log Analytics Workspace ]
# ----------------------------------------------------------------------------------------------------
module "bb_log_analytics_workspace" {
  source            = "../../modules/microsoft/building-blocks/log_analytics_workspace"
  resource_group    = data.terraform_remote_state.default.outputs.resource_group
  naming_options    = local.naming_options
  sku               = "PerGB2018"
  retention_in_days = 30
}

