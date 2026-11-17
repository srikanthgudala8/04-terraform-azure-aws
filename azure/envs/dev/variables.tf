variable "location" {
  type    = string
  default = "centralindia"
}

variable "project" {
  type    = string
  default = "demo"
}

variable "environment" {
  type    = string
  default = "dev"
}

variable "web_instances" {
  type    = set(string)
  default = ["web1", "web2"]
}

variable "ssh_public_key" {
  description = "Contents of your ~/.ssh/id_ed25519.pub (public key only)"
  type        = string
}
