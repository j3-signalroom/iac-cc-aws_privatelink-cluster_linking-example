output "vpc_endpoint_id" {
  description = "VPC Endpoint ID"
  value       = aws_vpc_endpoint.privatelink.id
}

output "vpc_endpoint_dns_name" {
  description = "VPC Endpoint primary DNS name"
  value       = aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"]
}

output "route53_zone_id" {
  description = "Route53 Private Hosted Zone ID (either created or existing)"
  value       = local.shared_phz_id  # Use local.shared_phz_id instead of aws_route53_zone.privatelink.zone_id
}

output "route53_zone_name" {
  description = "Route53 Private Hosted Zone name"
  value       = var.dns_domain  # Use the variable instead of the resource attribute
}

output "vpc_subnet_details" {
  description = "Details of subnets used for the VPC endpoint"
  value       = var.vpc_subnet_details
}

output "vpc_availability_zones" {
  description = "Availability zones where VPC endpoint is deployed"
  value = [for subnet in var.vpc_subnet_details : subnet.availability_zone]
}

output "security_group_id" {
  description = "Security group ID attached to the VPC endpoint"
  value       = aws_security_group.privatelink.id
}

output "shared_phz_id" {
  description = "Route53 Private Hosted Zone ID (either created or existing)"
  value       = local.shared_phz_id
}

output "vpc_id" {
  description = "VPC ID where the PrivateLink endpoint is deployed"
  value       = var.vpc_id
}

output "tgw_attachment_id" {
  description = "Transit Gateway VPC Attachment ID"
  value       = aws_ec2_transit_gateway_vpc_attachment.privatelink.id
}

output "confluent_connection_id" {
  description = "Confluent Private Link Attachment Connection ID"
  value       = confluent_private_link_attachment_connection.privatelink.id
}

output "dns_ready" {
  description = "Dependency handle to ensure DNS is fully propagated before creating Confluent resources"
  value       = time_sleep.wait_for_zone_associations.id
}
