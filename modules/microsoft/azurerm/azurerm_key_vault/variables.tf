variable "resource_group" {
  type        = object({
    name:string,
    location: string,
    tags: map(string)
  })
  description = ""
}
variable "naming_options" {
  type        = map(any)
  default     = {}
  description = "(Optional) Options to pass to th name generator"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "tenant_id" {
  type        = string
  default     = ""
  description = ""
}
variable "sku_name" {
  type    = string
  default = "standard"
}