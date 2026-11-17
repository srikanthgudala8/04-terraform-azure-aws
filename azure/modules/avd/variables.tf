variable "name" {
  type = string
}

variable "location" {
  type = string
}

variable "resource_group_name" {
  type = string
}

variable "friendly_name" {
  type    = string
  default = "Demo desktops"
}

variable "load_balancer_type" {
  description = "BreadthFirst spreads users, DepthFirst fills one host first (cheaper)"
  type        = string
  default     = "BreadthFirst"

  validation {
    condition     = contains(["BreadthFirst", "DepthFirst"], var.load_balancer_type)
    error_message = "load_balancer_type must be BreadthFirst or DepthFirst."
  }
}

variable "max_sessions_per_host" {
  type    = number
  default = 4
}

variable "registration_expiration_date" {
  description = "RFC3339 timestamp when the host registration token expires (max 30 days ahead)"
  type        = string
}

variable "tags" {
  type    = map(string)
  default = {}
}
