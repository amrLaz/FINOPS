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

variable "enable_global_logging" {
  type    = bool
  default = false
}
variable "sku" {
  type    = string
  default = "Free"
}
variable "retention_in_days" {
  type    = number
  default = 7
}