output "resource_group" {
  value = module.resource_group
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

output "log_analytics_workspace" {
  value = module.bb_log_analytics_workspace
}