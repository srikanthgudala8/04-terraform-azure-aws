output "vnet_id" {
  value = azurerm_virtual_network.this.id
}

output "subnet_ids" {
  description = "Map of subnet name to subnet ID"
  value       = { for k, s in azurerm_subnet.this : k => s.id }
}

output "nsg_names" {
  description = "Map of subnet name to NSG name"
  value       = { for k, n in azurerm_network_security_group.this : k => n.name }
}
