output "vnet_id" {
  description = "The resource ID of the virtual network."
  value       = azurerm_virtual_network.this.id
}

output "vnet_name" {
  description = "The name of the virtual network."
  value       = azurerm_virtual_network.this.name
}

output "vnet_address_space" {
  description = "The address space(s) of the virtual network."
  value       = azurerm_virtual_network.this.address_space
}

output "vnet_resource_group_name" {
  description = "The resource group that contains the virtual network."
  value       = azurerm_virtual_network.this.resource_group_name
}

output "location" {
  description = "The Azure region where network resources are deployed."
  value       = azurerm_virtual_network.this.location
}

output "subnet_ids" {
  description = "Map of subnet name => subnet id"
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "subnet_address_prefixes" {
  description = "Map of subnet name to its CIDR address prefix."
  value       = { for k, s in azurerm_subnet.this : k => s.address_prefixes[0] }
}

output "nsg_ids" {
  description = "Map of subnet name to NSG resource ID (excludes APIM NSG)."
  value       = { for k, nsg in azurerm_network_security_group.subnet : k => nsg.id }
}

output "nsg_names" {
  description = "Map of subnet name to NSG resource name (excludes APIM NSG)."
  value       = { for k, nsg in azurerm_network_security_group.subnet : k => nsg.name }
}