# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "plan"
  }, var.naming_options)
}

# [ App Service Plan ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_service_plan" "default" {
  location                     = var.resource_group.location
  resource_group_name          = var.resource_group.name
  tags                         = merge(var.tags, var.resource_group.tags)
  name                         = module.naming.rendered
  os_type                      = var.os_type
  sku_name                     = var.sku_name
}