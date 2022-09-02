# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../../common/naming"
  naming_options = merge({
    resource_name = "snet"
  }, var.naming_options)
}

# [ Subnet ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_subnet" "default" {
  address_prefixes                               = var.address_prefixes
  name                                           = module.naming.rendered
  resource_group_name                            = var.resource_group.name
  virtual_network_name                           = var.virtual_network.name
  service_endpoints                              = var.service_endpoints
  enforce_private_link_endpoint_network_policies = var.enforce_private_link_endpoint_network_policies
  enforce_private_link_service_network_policies  = var.enforce_private_link_service_network_policies

  dynamic "delegation" {
    for_each = var.delegation
    content {
      name = delegation.key
      service_delegation {
        name    = delegation.value[ "name" ]
        actions = delegation.value[ "actions" ]
      }
    }
  }
}