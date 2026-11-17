variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "address_space" {
  type    = list(string)
  default = ["10.20.0.0/16"]
}

variable "subnets" {
  description = "Map of subnet name to CIDR, e.g. { avd = \"10.20.1.0/24\" }"
  type        = map(string)
}

variable "tags" {
  type    = map(string)
  default = {}
}
