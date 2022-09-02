# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
}

# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "sqlmi"
  }, var.naming_options)
}

# [ MS SQL Managed Instance ]
# ----------------------------------------------------------------------------------------------------

resource "azurerm_mssql_managed_instance" "example" {
  name                         = module.naming.rendered
  resource_group_name          = var.resource_group.name
  location                     = var.resource_group.location
  administrator_login          = "mradministrator"
  administrator_login_password = "thisIsDog11"
  license_type                 = "BasePrice"
  sku_name                     = "GP_Gen5"
  vcores                       = 4
  storage_size_in_gb           = 32

}