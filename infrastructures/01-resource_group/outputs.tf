output "resource_group" {
  value = module.resource_group
}

output "subnet0" {
  value     = module.subnet-00
  sensitive = true
}



output "subnet1" {
  value     = module.subnet-01
  sensitive = true
}

output "subnet2" {
  value     = module.subnet-02
  sensitive = true
}

output "subnet3" {
  value     = module.subnet-03
  sensitive = true
}

output "virtual-network" {
  value     = module.virtual_network
  sensitive = true
}

output "log_analytics_workspace" {
  value = module.bb_log_analytics_workspace
}

output "key_vault" {
  value = module.key_vault
  sensitive = true
  
}

output "kv_pe" {
  value = azurerm_private_endpoint.key_vault
  
}