# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "ai"
  }, var.naming_options)
}

# [ Application Insights ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_application_insights" "default" {
  location            = var.resource_group.location
  resource_group_name = var.resource_group.name
  tags                = merge(var.tags, var.resource_group.tags)
  application_type    = "other"
  name                = module.naming.rendered
  workspace_id        = var.workspace_id
}