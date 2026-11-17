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

variable "avd_friendly_name" {
  type    = string
  default = "Demo desktops"
}

variable "avd_max_sessions_per_host" {
  type    = number
  default = 4
}
