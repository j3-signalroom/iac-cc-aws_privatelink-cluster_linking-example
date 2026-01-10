output "vpc_endpoint_id" {
  description = "The ID of the VPC endpoint which provisions the PrivateLink connection"
  value       = aws_vpc_endpoint.privatelink.id
}

output "route53_zone_id" {
  description = "The ID of the Route 53 Private Hosted Zone created for PrivateLink DNS"
  value       = aws_route53_zone.privatelink.zone_id
}

output "route53_zone_name" {
  description = "The name of the Route 53 Private Hosted Zone created for PrivateLink DNS"
  value       = aws_route53_zone.privatelink.name
}

output "dns_records" {
  description = "All DNS records created in the zone"
  value = merge(
    length(aws_route53_record.privatelink) > 0 ? {
      "global" = aws_route53_record.privatelink[0].name
    } : {},
    {
      for k, v in aws_route53_record.privatelink-zonal : k => v.name
    }
  )
}