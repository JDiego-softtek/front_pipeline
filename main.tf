provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

module "acr" {
  source              = "./ACR-module"
  acr_name            = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location
  sku                 = "Basic"

  tags = {
    env = var.environment
  }
}

resource "azurerm_service_plan" "this" {
  for_each = { functions = {} }
  
}

module "functions" {
  source = "./functions-module"

  name                = var.function_name
  location            = var.location
  resource_group_name = var.resource_group_name


  functions = {
    main = {
      storage_account_name  = local.functions_storage_account_name
      storage_account_id    = local.functions_storage_account_id
      service_plan_id       = azurerm_service_plan.this["functions"].id
     

    }
  }


  # vnet_integration_subnet_id = local.subnet_id_functions


}
