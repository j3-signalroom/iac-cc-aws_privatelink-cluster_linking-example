output "shared_phz_id" {
  description = "Shared Private Hosted Zone ID"
  value       = aws_route53_zone.confluent_privatelink.zone_id
}

output "sandbox_vpc_endpoint_id" {
  description = "Sandbox VPC Endpoint ID"
  value       = module.sandbox_vpc_privatelink.vpc_endpoint_id
}

output "shared_vpc_endpoint_id" {
  description = "Shared VPC Endpoint ID"
  value       = module.shared_vpc_privatelink.vpc_endpoint_id
}
