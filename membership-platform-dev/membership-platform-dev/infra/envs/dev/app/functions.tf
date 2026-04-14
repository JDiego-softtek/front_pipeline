module "functions" {
  source = "./modules/functions"

  name                = var.function_name
  location            = var.location
  resource_group_name = var.resource_group_name

  service_plan_id            = var.app_service_plan_id
  storage_account_name       = var.storage_account_name
  storage_account_access_key = var.storage_account_access_key

  vnet_integration_subnet_id = var.functions_subnet_id

  cosmos_secret_uri = var.cosmos_secret_uri

  tags = {
    env = "dev"
    app = "functions"
  }
}