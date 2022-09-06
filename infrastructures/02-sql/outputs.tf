output "mssql_server" {
  value     = module.mssql_server_default
  sensitive = true
}

output "mssql_database" {
  value     = module.mssql_database
  sensitive = true
}

output "pe-mssql" {
  value = azurerm_private_endpoint.mssql_server_pe

}

