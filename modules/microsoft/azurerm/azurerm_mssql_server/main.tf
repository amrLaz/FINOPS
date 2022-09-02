# [ Random ]
# ----------------------------------------------------------------------------------------------------
resource "random_id" "default" {
  count       = var.administrator_login == "" ? 1 : 0
  byte_length = 4
}
resource "random_password" "default" {
  count  = var.administrator_password == "" ? 1 : 0
  length = 20
}

# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
  administrator_login    = var.administrator_login == "" ? "administrator-${random_id.default[0].hex}" : var.administrator_login
  administrator_password = var.administrator_password == "" ? random_password.default[0].result : var.administrator_password
}

# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "sql"
  }, var.naming_options)
}

# [ MSSQL Server ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_mssql_server" "default" {
  depends_on                   = [
    module.naming
  ]
  name                         = module.naming.rendered
  resource_group_name          = var.resource_group.name
  location                     = var.resource_group.location
  tags                         = merge(var.tags, var.resource_group.tags)
  version                      = "12.0"
  administrator_login          = local.administrator_login
  administrator_login_password = local.administrator_password
  minimum_tls_version          = "1.2"

  azuread_administrator {
    login_username = var.object_name
    tenant_id      = var.tenant_id
    object_id      = var.object_id
  }

  outbound_network_restriction_enabled = true
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }
}

# [ Key Vault - Secrets ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_key_vault_secret" "administrator_login" {
  count        = var.key_vault_id == "" ? 0: 1
  key_vault_id = var.key_vault_id
  name         = "${azurerm_mssql_server.default.name}-administrator-login"
  value        = azurerm_mssql_server.default.administrator_login
  tags         = merge(var.tags, var.resource_group.tags)
}
resource "azurerm_key_vault_secret" "administrator_login_password" {
  count        = var.key_vault_id == "" ? 0: 1
  key_vault_id = var.key_vault_id
  name         = "${azurerm_mssql_server.default.name}-administrator-password"
  value        = azurerm_mssql_server.default.administrator_login_password
  tags         = merge(var.tags, var.resource_group.tags)
}
resource "azurerm_key_vault_secret" "fully_qualified_domain_name" {
  count        = var.key_vault_id == "" ? 0: 1
  key_vault_id = var.key_vault_id
  name         = "${azurerm_mssql_server.default.name}-fully-qualified-domain-name"
  value        = azurerm_mssql_server.default.fully_qualified_domain_name
  tags         = merge(var.tags, var.resource_group.tags)
}