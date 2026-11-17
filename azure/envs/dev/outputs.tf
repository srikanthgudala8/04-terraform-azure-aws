output "resource_group" {
  value = azurerm_resource_group.this.name
}

output "subnet_ids" {
  value = module.network.subnet_ids
}

output "web_url" {
  value = "http://${module.webserver.lb_public_ip}"
}

output "web_vm_private_ips" {
  value = module.webserver.vm_private_ips
}
