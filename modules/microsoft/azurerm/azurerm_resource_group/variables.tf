variable "naming_options" {
  type        = map(any)
  default     = {}
  description = "(Optional) Options to pass to the name generator"
}
variable "location" {
  type        = string
  default     = "West Europe"
  description = "(Required) The location where to deploy the resource group"
}
variable "tags" {
  type        = map(any)
  default     = {}
  description = "(Optional) The tags to be associated with the resource group"
}