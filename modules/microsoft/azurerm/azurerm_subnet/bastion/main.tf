# [ Naming ]
# ----------------------------------------------------------------------------------------------------

# [ Subnet ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_subnet" "default" {
  address_prefixes     = var.address_prefixes
  name                 = "AzureBastionSubnet"
  resource_group_name  = var.resource_group.name
  virtual_network_name = var.virtual_network.name
}
