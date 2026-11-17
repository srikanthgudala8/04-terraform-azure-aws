output "host_pool_id" {
  value = azurerm_virtual_desktop_host_pool.this.id
}

output "workspace_id" {
  value = azurerm_virtual_desktop_workspace.this.id
}

output "registration_token" {
  description = "Token for joining session hosts to the pool"
  value       = azurerm_virtual_desktop_host_pool_registration_info.this.token
  sensitive   = true
}
