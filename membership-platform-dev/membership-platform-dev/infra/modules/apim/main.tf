resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

locals {
  base      = lower(replace(var.name, "_", "-"))
  apim_name = substr("apim-${local.base}-${random_string.suffix.result}", 0, 50)
  is_v2_sku = can(regex("V2_", var.sku_name))
}

#checkov:skip=CKV_AZURE_174: APIM must remain public for DEV testing
resource "azurerm_api_management" "apim" {
  name                = local.apim_name
  location            = var.location
  resource_group_name = var.resource_group_name

  publisher_name  = var.publisher_name
  publisher_email = var.publisher_email
  sku_name        = var.sku_name

  virtual_network_type = local.is_v2_sku ? "None" : var.virtual_network_type

  dynamic "virtual_network_configuration" {
    for_each = local.is_v2_sku ? [] : [1]
    content {
      subnet_id = var.subnet_apim_id
    }
  }

  identity {
    type = "SystemAssigned"
  }

  tags = var.tags

}

data "azurerm_monitor_diagnostic_categories" "apim" {
  resource_id = azurerm_api_management.apim.id
}

resource "azurerm_monitor_diagnostic_setting" "apim" {
  name                       = "diag-${azurerm_api_management.apim.name}"
  target_resource_id         = azurerm_api_management.apim.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  dynamic "enabled_log" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.apim.log_category_types)
    content {
      category = enabled_log.value
    }
  }

  dynamic "enabled_metric" {
    for_each = toset(data.azurerm_monitor_diagnostic_categories.apim.metrics)
    content {
      category = enabled_metric.value
    }
  }
}

#checkov:skip=CKV_AZURE_174: APIM must remain public for DEV testing
resource "azurerm_api_management_api" "api" {
  for_each            = var.apis
  name                = "${each.key}-api"
  resource_group_name = var.resource_group_name
  api_management_name = azurerm_api_management.apim.name

  revision              = "1"
  display_name          = coalesce(each.value.display_name, upper(each.key))
  path                  = each.value.path
  protocols             = each.value.protocols
  subscription_required = false
}

locals {
  operations_flat = merge([
    for api_key, api in var.apis : {
      for op_key, op in api.operations :
      "${api_key}::${op_key}" => {
        api_key      = api_key
        op_key       = op_key
        method       = upper(op.method)
        url_template = op.url_template
        display_name = op.display_name
        responses    = op.responses
      }
    }
  ]...)
}

resource "azurerm_api_management_api_operation" "op" {
  for_each            = local.operations_flat
  operation_id        = replace(lower(each.key), "::", "-")
  api_name            = azurerm_api_management_api.api[each.value.api_key].name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name

  display_name = coalesce(each.value.display_name, "${each.value.method} ${each.value.url_template}")
  method       = each.value.method
  url_template = each.value.url_template

  dynamic "response" {
    for_each = each.value.responses
    content {
      status_code = response.value
    }
  }
}

resource "azurerm_api_management_api_policy" "policy" {
  for_each            = var.apis
  api_name            = azurerm_api_management_api.api[each.key].name
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = var.resource_group_name

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-backend-service base-url="${each.value.backend_url}" />
    <rewrite-uri template="/" />
  </inbound>
  <backend>
    <base />
  </backend>
  <outbound>
    <base />
  </outbound>
  <on-error>
    <base />
  </on-error>
</policies>
XML
}
