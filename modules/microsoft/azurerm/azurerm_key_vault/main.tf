# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
  tags      = merge(var.tags, {})
  tenant_id = var.tenant_id == "" ? data.azurerm_client_config.default.tenant_id : var.tenant_id
}

# [ Data ]
# ----------------------------------------------------------------------------------------------------
data "azurerm_client_config" "default" {}

# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "kv"
  }, var.naming_options)
}

# [ Key Vault ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_key_vault" "default" {
  location                 = var.resource_group.location
  resource_group_name      = var.resource_group.name
  tags                     = merge(local.tags, var.resource_group.tags)
  name                     = module.naming.rendered
  sku_name                 = var.sku_name
  tenant_id                = local.tenant_id
  purge_protection_enabled = true
}