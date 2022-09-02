# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source = "../../../common/naming"
  naming_options = merge({
    resource_name = "rg"
  }, var.naming_options)
}

# [ Resource Group ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_resource_group" "default" {
  location = var.location
  tags = var.tags
  name = module.naming.rendered

}