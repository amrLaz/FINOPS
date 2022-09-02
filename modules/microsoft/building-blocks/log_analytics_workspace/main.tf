# [ Log Analytics Workspace ]
# ----------------------------------------------------------------------------------------------------
module "log_analytics_workspace" {
  source            = "../../azurerm/azurerm_log_analytics_workspace"
  resource_group    = var.resource_group
  naming_options    = var.naming_options
  retention_in_days = var.retention_in_days
  sku               = var.sku
}

# { Diagnostic Settings }
module "log_analytics_workspace_diagnostic_setting" {
  count                      = var.enable_global_logging ? 1 : 0
  source                     = "../../azurerm/azurerm_monitor_diagnostic_setting"
  name                       = module.log_analytics_workspace.name
  target_resource_id         = module.log_analytics_workspace.id
  log_analytics_workspace_id = module.log_analytics_workspace.id
}