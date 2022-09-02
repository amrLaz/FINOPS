variable "address_prefixes" {
  type = list(string)
}
variable "naming_options" {
  type = any
  default = {}
}
variable "resource_group" {
  type = object({
    name : string
  })
  description = "(Required) Specifies the name of the resource group."
}
variable "virtual_network" {
  type = object({
    name : string
  })
  description = "(Required) Specifies the name of the virtual network."
}
variable "delegation" {
  type = map(object({
    name = string
    actions = list(string)
  }))
  default = {}
}
variable "enforce_private_link_service_network_policies" {
  type = bool
  default = false
}
variable "enforce_private_link_endpoint_network_policies" {
  type = bool
  default = false
}
variable "service_endpoints" {
  type = list(string)
  default = []
}