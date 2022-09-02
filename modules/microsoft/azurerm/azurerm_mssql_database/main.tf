# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "db"
  }, var.naming_options)
}

# [ Database ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_mssql_database" "default" {
  name      = module.naming.rendered
  server_id = var.server_id
  collation = "SQL_Latin1_General_CP1_CI_AS"
  sku_name  = "S0"
  tags = var.tags
}