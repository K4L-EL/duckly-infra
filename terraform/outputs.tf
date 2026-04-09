output "resource_group_name" {
  value = azurerm_resource_group.main.name
}

output "backend_url" {
  value = "https://${azurerm_linux_web_app.backend.default_hostname}"
}

output "dashboard_url" {
  value = "https://${azurerm_linux_web_app.dashboard.default_hostname}"
}

output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}

output "acr_admin_username" {
  value     = azurerm_container_registry.acr.admin_username
  sensitive = true
}

output "db_fqdn" {
  value = azurerm_postgresql_flexible_server.db.fqdn
}

output "db_name" {
  value = azurerm_postgresql_flexible_server_database.app.name
}

output "storage_account_name" {
  value = azurerm_storage_account.blob.name
}

output "storage_blob_endpoint" {
  value = azurerm_storage_account.blob.primary_blob_endpoint
}
