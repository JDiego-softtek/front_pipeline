module "adf" {
  source = "../../../modules/adf"

  name                = var.adf_name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  public_network_access_enabled = var.adf_public_network_access_enabled

  tags = local.tags
}
