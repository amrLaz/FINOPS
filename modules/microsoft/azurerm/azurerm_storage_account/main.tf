# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "st"
  }, var.naming_options, {
    separator = "", lower = true
  })
}

# [ Storage Account ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_storage_account" "default" {
  depends_on = [
    module.naming
  ]
  resource_group_name      = var.resource_group.name
  location                 = var.resource_group.location
  name                     = replace( module.naming.rendered, "-", "")
  tags                     = merge(var.tags, var.resource_group.tags)
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  min_tls_version          = "TLS1_2"
  identity {
    type = "SystemAssigned"
  }
}
