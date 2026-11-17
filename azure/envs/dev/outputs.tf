output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "avd_host_pool_id" {
  value = module.avd.host_pool_id
}

output "avd_registration_token" {
  value     = module.avd.registration_token
  sensitive = true
}
