# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "stapp"
  }, var.naming_options)
}

# [ App Service Plan ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_static_site" "default" {
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  name                = module.naming.rendered
  tags                = merge(var.tags, var.resource_group.tags)
  sku_size            = var.sku_size //"Free"
  sku_tier            = var.sku_tier //"Free"
}