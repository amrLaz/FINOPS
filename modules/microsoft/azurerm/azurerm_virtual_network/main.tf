# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "vnet"
  }, var.naming_options)
}

# [ Virtual Network ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_virtual_network" "default" {
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  name                = module.naming.rendered
  tags                = merge(var.tags, var.resource_group.tags)
  address_space       = var.address_space
  dns_servers         = var.dns_servers_names
}