resource "azurerm_linux_function_app" "this" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id              = var.service_plan_id
  storage_account_name         = var.storage_account_name
  storage_account_access_key   = var.storage_account_access_key

  https_only = true

  identity {
    type = "SystemAssigned"
  }

  site_config {
    application_stack {
      node_version = "18"
    }
  }

  app_settings = {
    FUNCTIONS_WORKER_RUNTIME = "node"
    WEBSITE_RUN_FROM_PACKAGE = "1"

    # ejemplo Key Vault reference
    COSMOS_CONN = "@Microsoft.KeyVault(SecretUri=${var.cosmos_secret_uri})"
  }

  tags = var.tags
}

#  VNet Integration (solo egress)
resource "azurerm_app_service_virtual_network_swift_connection" "this" {
  app_service_id = azurerm_linux_function_app.this.id
  subnet_id     = var.vnet_integration_subnet_id
}