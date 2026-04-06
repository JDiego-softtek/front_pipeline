resource "random_string" "acr_suffix" {
  length  = 6
  upper   = false
  special = false
}

module "acr" {
  source = "../../../modules/acr"

  name                = replace("acr${var.project}${var.environment}${random_string.acr_suffix.result}", "-", "")
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  sku           = var.acr_sku
  admin_enabled = var.acr_admin_enabled

  public_network_access_enabled = var.acr_public_access_enabled

  tags = local.tags
}
