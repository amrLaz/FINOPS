output "id" {
  value = azurerm_mssql_server.default.id
}
output "name" {
  value = azurerm_mssql_server.default.name
}
output "identity" {
  value = azurerm_mssql_server.default.identity
}
output "administrator_password" {
  value     = local.administrator_password
  sensitive = true
}
output "administrator_login" {
  value     = local.administrator_login
  sensitive = true
}

output "fully_qualified_domain_name" {
  value = azurerm_mssql_server.default.fully_qualified_domain_name
}
output "serial" {
  value = module.naming.identifier
}