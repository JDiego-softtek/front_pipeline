resource "random_string" "storage_suffix" {
  length  = 6
  upper   = false
  special = false
}

module "storage" {
  source = "../../../modules/storage"

  name                = "st${replace(local.resource_name, "-", "")}${random_string.storage_suffix.result}"
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = var.location

  replication_type              = var.storage_replication_type
  public_network_access_enabled = var.storage_public_network_access_enabled

  containers = var.storage_containers

  tags = local.tags
}
