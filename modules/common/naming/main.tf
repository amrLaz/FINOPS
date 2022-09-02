locals {
  naming_options = merge({
    resource_name = ""
    suffix        = ""
    prefix        = ""
    separator     = "-"
    identifier    = ""
    lower         = true
    length        = 0
  }, var.naming_options)
  identifier         = local.naming_options.identifier == "" ? random_id.default[0].hex : local.naming_options.identifier
  items          = [
    local.naming_options.prefix,
    local.naming_options.resource_name,
    local.naming_options.suffix,
    local.identifier
  ]
  join           = join(local.naming_options.separator, compact(local.items))
  case           = local.naming_options.lower ? lower(local.join) : upper(local.join)
  rendered       = local.naming_options.length == 0 ? local.case: substr(local.case, 0, local.naming_options.length)
}
resource "random_id" "default" {
  count       = 1
  byte_length = 4
}