variable "resource_group" {
  type = object({
    name : string, location : string, tags : map(string)
  })
  description = ""
}
variable "naming_options" {
  type        = map(any)
  default     = {}
  description = "(Optional) Options to pass to th name generator"
}
variable "administrator_password" {
  type        = string
  description = ""
  default     = ""
}
variable "administrator_login" {
  type        = string
  description = ""
  default     = ""
}
variable "key_vault_id" {
  type    = string
  default = ""
}
variable "tags" {
  type    = map(string)
  default = {}
}

variable "tenant_id" {
  description = "Tenant of the users & groups"
  type        = string
  default     = null
}
variable "object_id" {
  description = "Identifier of the administrator group"
  type        = string
  default     = null
}
variable "object_name" {
  description = "Name of the administrator group"
  type        = string
  default     = null
}