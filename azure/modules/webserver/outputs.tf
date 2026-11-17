output "lb_public_ip" {
  description = "Public IP of the load balancer; curl http://<ip>"
  value       = azurerm_public_ip.lb.ip_address
}

output "vm_names" {
  value = [for vm in azurerm_linux_virtual_machine.this : vm.name]
}

output "vm_private_ips" {
  value = { for k, nic in azurerm_network_interface.this : k => nic.private_ip_address }
}
