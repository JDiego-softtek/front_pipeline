output "require_tags_policy_id" {
  description = "Resource ID of the mandatory-tags policy definition"
  value       = azurerm_policy_definition.require_tags.id
}

output "sql_tls_policy_id" {
  description = "Resource ID of the SQL TLS minimum-version policy definition"
  value       = azurerm_policy_definition.sql_tls_min_version.id
}

output "allowed_locations_assignment_id" {
  description = "Resource ID of the allowed-locations policy assignment"
  value       = azurerm_subscription_policy_assignment.allowed_locations.id
}
