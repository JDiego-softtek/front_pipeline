output "service_fqdns" {
  value = {
    for k, app in azurerm_container_app.this :
    k => app.ingress[0].fqdn
  }
}

output "service_names" {
  value = {
    for k, app in azurerm_container_app.this :
    k => app.name
  }
}

output "aca_env_name" {
  value = azurerm_container_app_environment.this.name
}

output "aca_env_id" {
  value = azurerm_container_app_environment.this.id
}
