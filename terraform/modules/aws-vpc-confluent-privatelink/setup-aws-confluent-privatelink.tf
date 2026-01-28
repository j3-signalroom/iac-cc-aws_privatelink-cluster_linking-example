# VPC Endpoint
resource "aws_vpc_endpoint" "privatelink" {
  vpc_id              = aws_vpc.privatelink.id
  service_name        = var.privatelink_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink.id]
  private_dns_enabled = false
  
  subnet_ids = aws_subnet.private[*].id
  
  tags = {
    Name        = "ccloud-privatelink-${local.network_id}"
    VPC         = aws_vpc.privatelink.id
    Domain      = var.dns_domain
    Environment = data.confluent_environment.privatelink.display_name
  }

  depends_on = [ 
    aws_security_group.privatelink 
  ]
}

# ============================================================================
# ROUTE53 PRIVATE HOSTED ZONE AND RECORDS
# ============================================================================
#
# Data source for existing PHZ (when shared_phz_id is provided)
data "aws_route53_zone" "existing" {
  zone_id = var.shared_phz_id
}

locals {
  shared_phz_id = data.aws_route53_zone.existing.zone_id
}

# ============================================================================
# VPC ASSOCIATIONS
# ============================================================================
#
# Associate the PHZ with the local VPC (only if using existing PHZ AND not TFC agent VPC)
resource "aws_route53_zone_association" "local_vpc" {
  zone_id = local.shared_phz_id
  vpc_id  = aws_vpc.privatelink.id
}

# Wait for DNS propagation
resource "time_sleep" "wait_for_zone_associations" {
  depends_on = [
    aws_route53_zone_association.local_vpc
  ]
  
  create_duration = "1m"
}

resource "confluent_private_link_attachment_connection" "privatelink" {
  display_name = "ccloud-plattc-${local.network_id}"
  
  environment {
    id = var.confluent_environment_id
  }
  
  aws {
    vpc_endpoint_id = aws_vpc_endpoint.privatelink.id
  }

  private_link_attachment {
    id = var.confluent_platt_id
  }
  
  depends_on = [
    time_sleep.wait_for_zone_associations
  ]
}
