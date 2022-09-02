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
  description = "(Optional) Options to pass to the name generator"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "app_service_plan_id" {
  type = string
}
variable "app_settings" {
  type    = map(string)
  default = {}
}
variable "ip_restriction" {
  type    = list(object({
    action: string,
    ip_address: string,
    name: string
  }))
  default = []
}
variable "linux_fx_version" {
  type    = string
  default = "DOTNETCORE|6.0"
  description = "(Optional) Linux App Framework and version for the App Service."
}
variable "always_on" {
  type    = bool
  default = false
}
variable "http2_enabled" {
  type    = bool
  default = false
}


variable "storage_account_url" {
  type    = string
  default = false
}