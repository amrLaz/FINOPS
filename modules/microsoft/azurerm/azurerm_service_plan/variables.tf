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
variable "os_type" {
  type = string

}
variable "sku_name" {
  type = string
}
variable "maximum_elastic_worker_count" {
  type = number
  default = 1
}