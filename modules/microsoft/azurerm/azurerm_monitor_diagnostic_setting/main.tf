# { Diagnostic Categories }
data "azurerm_monitor_diagnostic_categories" "default" {
  resource_id = var.target_resource_id
}

# { Diagnostic Settings }
resource "azurerm_monitor_diagnostic_setting" "default" {
  name                       = var.name
  target_resource_id         = var.target_resource_id
  log_analytics_workspace_id = var.log_analytics_workspace_id
  dynamic "log" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.logs
    content {
      category = log.key
      retention_policy {
        enabled = true
        days    = var.days
      }
    }
  }
  dynamic "metric" {
    for_each = data.azurerm_monitor_diagnostic_categories.default.metrics
    content {
      category = metric.key
      retention_policy {
        enabled = true
        days    = var.days
      }
    }
  }
}