# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
  tags = merge(var.tags, {})
}

# [ Data ]
# ----------------------------------------------------------------------------------------------------
data "azurerm_client_config" "default" {}

# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "log"
  }, var.naming_options)
}

# [ Log Analytics Workspace ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_log_analytics_workspace" "default" {
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  name                = module.naming.rendered
  tags                = merge(local.tags, var.resource_group.tags)
  sku                 = var.sku
  retention_in_days   = var.retention_in_days
}