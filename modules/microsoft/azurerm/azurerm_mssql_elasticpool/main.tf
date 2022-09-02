# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
}

# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "mssqlpool"
  }, var.naming_options)
}

# [ MSSQL Server ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_mssql_elasticpool" "default" {
  name                = module.naming.rendered
  resource_group_name = var.resource_group.name
  location            = var.resource_group.location
  tags                = merge(var.tags, var.resource_group.tags)
  server_name         = var.mssql_server.name
  license_type        = "LicenseIncluded"
  max_size_gb         = 100
  sku {
    name     = "StandardPool"
    tier     = "Standard"
    capacity = 100
  }
  per_database_settings {
    max_capacity = 20
    min_capacity = 10
  }
}