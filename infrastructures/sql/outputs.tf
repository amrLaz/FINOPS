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

output "subnet2" {
  value     = module.subnet-02
  sensitive = true
}

output "subnet1" {
  value     = module.subnet-01
  sensitive = true
}


output "virtual-network" {
  value     = module.virtual_network
  sensitive = true
}
