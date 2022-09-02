# [ Naming ]
# ----------------------------------------------------------------------------------------------------
module "naming" {
  source         = "../../../common/naming"
  naming_options = merge({
    resource_name = "func"
  }, var.naming_options)
}

# [ Locals ]
# ----------------------------------------------------------------------------------------------------
locals {
  app_settings = {
    WEBSITE_RUN_FROM_PACKAGE                        = "1"
    APPINSIGHTS_PROFILERFEATURE_VERSION             = "1.0.0"
    APPINSIGHTS_SNAPSHOTFEATURE_VERSION             = "1.0.0"
    APPLICATIONINSIGHTS_CONNECTION_STRING           = ""
    ApplicationInsightsAgent_EXTENSION_VERSION      = "~2"
    FUNCTIONS_WORKER_RUNTIME                        = "dotnet"
    DiagnosticServices_EXTENSION_VERSION            = "~3"
    InstrumentationEngine_EXTENSION_VERSION         = "~1"
    SnapshotDebugger_EXTENSION_VERSION              = "~1"
    XDT_MicrosoftApplicationInsights_BaseExtensions = "~1"
    XDT_MicrosoftApplicationInsights_Mode           = "recommended"
    XDT_MicrosoftApplicationInsights_PreemptSdk     = "1"
    WEBSITE_ENABLE_SYNC_UPDATE_SITE                 = true
    WEBSITE_RUN_FROM_PACKAGE                        = 1
    WEBSITE_TIME_ZONE                               = "Romance Standard Time"
  }
}

# [ Function App ]
# ----------------------------------------------------------------------------------------------------
resource "azurerm_linux_function_app" "default" {
  location                    = var.resource_group.location
  resource_group_name         = var.resource_group.name
  tags                        = merge(var.tags, var.resource_group.tags)
  service_plan_id             = var.app_service_plan_id
  name                        = module.naming.rendered
  builtin_logging_enabled     = true
  https_only                  = true
  storage_key_vault_secret_id = var.storage_key_vault_secret_id
  functions_extension_version = "~4"

  identity {
    type = "SystemAssigned"
  }

  site_config {
    ftps_state          = "Disabled"
    minimum_tls_version = "1.2"
    always_on           = var.always_on
    http2_enabled       = var.http2_enabled

    dynamic "ip_restriction" {
      for_each = var.ip_restriction
      content {
        action     = ip_restriction.value.action
        name       = ip_restriction.value.name
        ip_address = ip_restriction.value.ip_address
        priority   = ip_restriction.key + 1
      }
    }
  }
  app_settings = merge(local.app_settings, var.app_settings)


  lifecycle {
    ignore_changes = [
      app_settings[ "WEBSITE_RUN_FROM_PACKAGE" ], site_config[ "scm_type" ]
    ]
  }
}