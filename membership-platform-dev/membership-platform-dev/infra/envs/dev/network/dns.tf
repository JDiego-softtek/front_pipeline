# Private DNS zones for all PaaS services that will have private endpoints in snet-data.
# Zones are linked to the spoke VNet so resources inside the VNet resolve private IPs.
# When the Hub VNet is added, it must also be linked here so VPN-connected developers
# and DNS Resolver can resolve private IPs

locals {
  private_dns_zones = [
    "privatelink.database.windows.net",   # Azure SQL
    "privatelink.vaultcore.azure.net",    # Azure Key Vault
    "privatelink.azurecr.io",             # Azure Container Registry
    "privatelink.documents.azure.com",    # Azure Cosmos DB
    "privatelink.servicebus.windows.net", # Azure Service Bus
    "privatelink.blob.core.windows.net",  # Azure Blob Storage
  ]
}

module "dns" {
  count = var.enable_private_endpoints ? 1 : 0

  source = "../../../modules/dns"

  resource_group_name = data.azurerm_resource_group.rg.name
  spoke_vnet_id       = module.networking.vnet_id
  private_dns_zones   = local.private_dns_zones

  tags = local.tags
}
