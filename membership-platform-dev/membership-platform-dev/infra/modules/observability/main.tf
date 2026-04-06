resource "azurerm_log_analytics_workspace" "this" {
  name                = "log-${var.resource_name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "random_uuid" "workbook" {}

resource "azurerm_application_insights_workbook" "sre_dashboard" {
  name                = random_uuid.workbook.result
  resource_group_name = var.resource_group_name
  location            = var.location
  display_name        = "SRE Dashboard"

  data_json = templatefile(var.workbook_template_path, {
    law_id = azurerm_log_analytics_workspace.this.id
  })

  tags = var.tags
}