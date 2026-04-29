resource "azurerm_linux_function_app" "this" {
  for_each                     = var.functions

  name                         = "func-${each.key}-${var.name}"
  location                     = var.location
  resource_group_name          = var.resource_group_name

  service_plan_id               = each.value.service_plan_id
  storage_account_name          = each.value.storage_account_name
  storage_uses_managed_identity = true

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = var.node_version
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME  = var.functions_worker_runtime
    FUNCTIONS_EXTENSION_VERSION = var.functions_extension_version
    WEBSITE_RUN_FROM_PACKAGE  = var.website_run_from_package

    AzureWebJobsStorage__accountName = each.value.storage_account_name
  }

  tags = {}
}


 #  VNet Integration (solo egress)
#resource "azurerm_app_service_virtual_network_swift_connection" "this" {
#  app_service_id = azurerm_linux_function_app.this.id
#  subnet_id     = var.vnet_integration_subnet_id
#}
