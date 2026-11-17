variable "name" {
  description = "Name prefix for all resources"
  type        = string
}

variable "vpc_id" {
  type = string
}

variable "public_subnet_ids" {
  description = "Subnets for the load balancer"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnets for the application instances"
  type        = list(string)
}

variable "container_image" {
  description = "Container image the instances run, e.g. ghcr.io/<user>/03-github-actions-cicd:latest"
  type        = string
}

variable "app_port" {
  description = "Port the app is exposed on the instance"
  type        = number
  default     = 8080
}

variable "health_check_path" {
  type    = string
  default = "/health"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "min_size" {
  type    = number
  default = 2
}

variable "max_size" {
  type    = number
  default = 4
}

variable "desired_capacity" {
  type    = number
  default = 2
}

variable "allowed_ingress_cidrs" {
  description = "CIDRs allowed to reach the load balancer"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "tags" {
  type    = map(string)
  default = {}
}
