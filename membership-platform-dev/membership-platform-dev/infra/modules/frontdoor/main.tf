resource "random_string" "endpoint_suffix" {
  length  = 6
  upper   = false
  special = false
}

resource "random_string" "fd_suffix" {
  length  = 4
  upper   = false
  special = false
}

resource "azurerm_cdn_frontdoor_profile" "this" {
  name                = "afd-${var.resource_name}-${random_string.fd_suffix.result}"
  resource_group_name = var.resource_group_name
  sku_name            = "Standard_AzureFrontDoor"
  tags                = var.tags
}

resource "azurerm_cdn_frontdoor_endpoint" "this" {
  name                     = "${var.resource_name}-fd-endpoint-${random_string.endpoint_suffix.result}"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
  enabled                  = true
}

resource "azurerm_cdn_frontdoor_origin_group" "frontend" {
  name                     = "frontend-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin_group" "api" {
  name                     = "api-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "frontend" {
  name                           = "frontend-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.frontend.id
  enabled                        = true
  host_name                      = var.frontend_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.frontend_host_name
  certificate_name_check_enabled = true
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_origin" "api" {
  name                           = "api-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.api.id
  enabled                        = true
  host_name                      = var.apim_gateway_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.apim_gateway_host_name
  certificate_name_check_enabled = true
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "api" {
  name                          = "api-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.api.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.api.id]

  enabled                = true
  forwarding_protocol    = "MatchRequest"
  https_redirect_enabled = true
  patterns_to_match      = ["/api/*"]
  supported_protocols    = ["Http", "Https"]
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_route" "frontend" {
  name                          = "frontend-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.frontend.id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.frontend.id]

  enabled                = true
  forwarding_protocol    = "MatchRequest"
  https_redirect_enabled = true
  patterns_to_match      = ["/*"]
  supported_protocols    = ["Http", "Https"]
  link_to_default_domain = true
}

resource "azurerm_cdn_frontdoor_rule_set" "appservice_rewrite" {
  count                    = var.enable_appservice ? 1 : 0
  name                     = "appservicerewrite"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id
}

resource "azurerm_cdn_frontdoor_rule" "appservice_strip_prefix" {
  count                     = var.enable_appservice ? 1 : 0
  name                      = "stripappserviceprefix"
  cdn_frontdoor_rule_set_id = azurerm_cdn_frontdoor_rule_set.appservice_rewrite[0].id
  order                     = 1

  actions {
    url_rewrite_action {
      source_pattern          = "/appservice/"
      destination             = "/"
      preserve_unmatched_path = true
    }
  }

  depends_on = [azurerm_cdn_frontdoor_rule_set.appservice_rewrite]
}

resource "azurerm_cdn_frontdoor_origin_group" "appservice" {
  count                    = var.enable_appservice ? 1 : 0
  name                     = "appservice-og"
  cdn_frontdoor_profile_id = azurerm_cdn_frontdoor_profile.this.id

  load_balancing {
    sample_size                 = 4
    successful_samples_required = 3
  }

  health_probe {
    interval_in_seconds = 100
    path                = "/"
    protocol            = "Https"
    request_type        = "GET"
  }
}

resource "azurerm_cdn_frontdoor_origin" "appservice" {
  count                          = var.enable_appservice ? 1 : 0
  name                           = "appservice-origin"
  cdn_frontdoor_origin_group_id  = azurerm_cdn_frontdoor_origin_group.appservice[0].id
  enabled                        = true
  host_name                      = var.appservice_host_name
  http_port                      = 80
  https_port                     = 443
  origin_host_header             = var.appservice_host_name
  certificate_name_check_enabled = true
  priority                       = 1
  weight                         = 1000
}

resource "azurerm_cdn_frontdoor_route" "appservice" {
  count                         = var.enable_appservice ? 1 : 0
  name                          = "appservice-route"
  cdn_frontdoor_endpoint_id     = azurerm_cdn_frontdoor_endpoint.this.id
  cdn_frontdoor_origin_group_id = azurerm_cdn_frontdoor_origin_group.appservice[0].id
  cdn_frontdoor_origin_ids      = [azurerm_cdn_frontdoor_origin.appservice[0].id]
  cdn_frontdoor_rule_set_ids    = [azurerm_cdn_frontdoor_rule_set.appservice_rewrite[0].id]

  enabled                = true
  forwarding_protocol    = "MatchRequest"
  https_redirect_enabled = true
  patterns_to_match      = ["/appservice/*"]
  supported_protocols    = ["Http", "Https"]
  link_to_default_domain = true
}

resource "azurerm_monitor_diagnostic_setting" "frontdoor" {
  name                       = "diag-frontdoor"
  target_resource_id         = azurerm_cdn_frontdoor_profile.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "FrontDoorAccessLog"
  }

  enabled_log {
    category = "FrontDoorHealthProbeLog"
  }

  enabled_log {
    category = "FrontDoorWebApplicationFirewallLog"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
