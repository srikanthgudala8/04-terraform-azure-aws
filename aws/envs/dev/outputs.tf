output "app_url" {
  description = "Open this in a browser once instances are healthy"
  value       = "http://${module.compute.alb_dns_name}"
}

output "vpc_id" {
  value = module.vpc.vpc_id
}
