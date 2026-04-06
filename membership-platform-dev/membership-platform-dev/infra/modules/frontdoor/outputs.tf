output "frontdoor_endpoint_host" {
  value = azurerm_cdn_frontdoor_endpoint.this.host_name
}

output "frontdoor_profile_id" {
  value = azurerm_cdn_frontdoor_profile.this.id
}


