variable "name" {
  type = string
}
variable "target_resource_id" {
  type = string
}
variable "log_analytics_workspace_id" {
  type = string
}
variable "days" {
  type = number
  default = 365
}