resource "azurerm_private_dns_zone" "this" {
  for_each = toset(var.private_dns_zones)

  name                = each.key
  resource_group_name = var.resource_group_name

  tags = var.tags
}


resource "azurerm_private_dns_zone_virtual_network_link" "spoke" {
  for_each = toset(var.private_dns_zones)

  name                  = "link-spoke-${replace(each.key, ".", "-")}"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.key].name
  virtual_network_id    = var.spoke_vnet_id
  registration_enabled  = false

  tags = var.tags
}
