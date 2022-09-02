variable "address_prefixes" {
  type = list(string)
}
variable "resource_group" {
  type        = object({
    name : string
  })
  description = "(Required) Specifies the name of the resource group."
}
variable "virtual_network" {
  type        = object({
    name : string
  })
  description = "(Required) Specifies the name of the virtual network."
}
