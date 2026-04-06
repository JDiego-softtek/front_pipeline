output "zone_ids" {
  description = "Map of DNS zone name => resource ID. Used by private endpoint modules to create DNS zone group associations."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.id }
}

output "zone_names" {
  description = "Map of DNS zone name => zone name (for referencing in DNS zone group resources)."
  value       = { for k, z in azurerm_private_dns_zone.this : k => z.name }
}
