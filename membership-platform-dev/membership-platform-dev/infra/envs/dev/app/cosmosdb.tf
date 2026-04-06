module "cosmosdb" {
  source = "../../../modules/cosmosdb"

  name                = var.cosmos_account_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  serverless                    = var.cosmos_serverless
  consistency_level             = var.cosmos_consistency_level
  public_network_access_enabled = var.cosmos_public_network_access_enabled

  databases = var.cosmos_databases

  tags = local.tags
}
