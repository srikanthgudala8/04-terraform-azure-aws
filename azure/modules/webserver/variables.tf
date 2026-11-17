variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "subnet_id" {
  description = "Subnet for the VM NICs"
  type        = string
}

variable "nsg_name" {
  description = "NSG attached to that subnet; the module adds the HTTP and load balancer rules to it"
  type        = string
}

variable "instances" {
  description = "Names of VMs to create (a set, so removing one removes only that VM)"
  type        = set(string)
  default     = ["web1", "web2"]
}

variable "vm_size" {
  type    = string
  default = "Standard_B1s"
}

variable "admin_username" {
  type    = string
  default = "azureuser"
}

variable "ssh_public_key" {
  description = "Public key text (ssh-ed25519 ...). Never a private key."
  type        = string

  validation {
    condition     = can(regex("^ssh-", var.ssh_public_key))
    error_message = "ssh_public_key must be a public key that starts with ssh-."
  }
}

variable "tags" {
  type    = map(string)
  default = {}
}
