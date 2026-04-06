data "azurerm_resource_group" "rg" {
  name = var.resource_group_name
}

module "networking" {
  source = "../../../modules/networking"

  resource_name       = var.project
  environment         = var.environment
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  vnet_cidr        = var.vnet_cidr
  subnets          = local.effective_subnets
  apim_subnet_name = var.apim_subnet_name

  tags = local.tags
}
