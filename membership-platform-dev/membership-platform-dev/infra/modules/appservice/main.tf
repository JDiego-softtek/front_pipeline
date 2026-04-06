# Dedicated plan — only created when no shared plan is provided.
resource "azurerm_service_plan" "this" {
  count               = var.service_plan_id == null ? 1 : 0
  name                = "plan-${var.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.service_plan_sku_name

  tags = var.tags
}

locals {
  resolved_plan_id = var.service_plan_id != null ? var.service_plan_id : azurerm_service_plan.this[0].id
}

resource "azurerm_linux_web_app" "this" {
  name                = "ase-${var.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  service_plan_id     = local.resolved_plan_id
  https_only          = true
  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = var.node_version
    }
    always_on                         = true
    health_check_path                 = "/"
    health_check_eviction_time_in_min = 5
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
  }

  app_settings = merge(
    {
      "WEBSITES_ENABLE_APP_SERVICE_STORAGE" = "false"
      "NODE_ENV"                            = "development"
      "NEXT_PUBLIC_API_BASE_URL"            = "/api"
    },
    var.enable_app_insights ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"        = azurerm_application_insights.this[0].instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING" = azurerm_application_insights.this[0].connection_string
    } : {},
    var.app_settings
  )

  logs {
    detailed_error_messages = true
    failed_request_tracing  = true
    http_logs {
      file_system {
        retention_in_days = 7
        retention_in_mb   = 35
      }
    }
  }
  tags = var.tags
}

resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_web_app.this.id
  subnet_id      = var.frontend_subnet_id
}

resource "azurerm_monitor_diagnostic_setting" "frontend" {
  name                       = "diag-frontend"
  target_resource_id         = azurerm_linux_web_app.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Optional Application Insights — linked to the shared Log Analytics workspace.
resource "azurerm_application_insights" "this" {
  count               = var.enable_app_insights ? 1 : 0
  name                = "appi-${var.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = "web"

  workspace_id = var.log_analytics_workspace_id
}
