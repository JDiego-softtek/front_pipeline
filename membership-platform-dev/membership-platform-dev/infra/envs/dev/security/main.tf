data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

data "azurerm_client_config" "current" {}

resource "random_string" "kv_suffix" {
  length  = 6
  special = false
  upper   = false
}

module "keyvault" {
  source = "../../../modules/keyvault"

  name                = lower(replace("kv-${local.resource_name}-${random_string.kv_suffix.result}", "-", ""))
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id

  sku_name                      = var.keyvault_sku
  public_network_access_enabled = var.keyvault_public_access_enabled
  purge_protection_enabled      = var.keyvault_purge_protection_enabled
  soft_delete_retention_days    = var.keyvault_soft_delete_retention_days

  tags = local.tags
}