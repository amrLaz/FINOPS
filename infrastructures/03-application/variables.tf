variable "private_dns_zone_group" {

  type = object({
    name                 = string
    private_dns_zone_ids = list(string)
  })
  default = null
}
variable "project" {
  type        = string
  description = "Project name"
}

variable "environment" {
  type        = string
  description = "Environment (dev / stage / prod)"
}

variable "location" {
  type        = string
  description = "Azure region to deploy module to"
}