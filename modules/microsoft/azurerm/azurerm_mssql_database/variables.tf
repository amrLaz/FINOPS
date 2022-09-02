variable "naming_options" {
  type        = map(any)
  default     = {}
  description = "(Optional) Options to pass to th name generator"
}
variable "tags" {
  type    = map(string)
  default = {}
}
variable "server_id" {
  type = string
}