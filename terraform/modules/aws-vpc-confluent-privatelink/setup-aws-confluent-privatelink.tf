# VPC Endpoint
resource "aws_vpc_endpoint" "privatelink" {
  vpc_id              = var.vpc_id
  service_name        = var.privatelink_service_name
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.privatelink.id]
  private_dns_enabled = false
  
  subnet_ids = var.vpc_subnet_ids
  
  tags = {
    Name        = "ccloud-privatelink-${local.network_id}"
    VPC         = var.vpc_id
    Domain      = var.dns_domain
    Environment = data.confluent_environment.privatelink.display_name
  }

  depends_on = [ 
    aws_security_group.privatelink 
  ]
}

# Route53 Private Hosted Zone
# CRITICAL: Zone name must exactly match Confluent DNS domain
resource "aws_route53_zone" "privatelink" {
  name = var.dns_domain
  
  # Associate with local VPC
  vpc {
    vpc_id = var.vpc_id
  }
  
  tags = {
    Name        = "phz-${local.network_id}-${var.vpc_id}"
    VPC         = var.vpc_id
    Domain      = var.dns_domain
    Environment = data.confluent_environment.privatelink.display_name
  }
}

# Associate the PHZ with the DNS VPC, if provided
resource "aws_route53_zone_association" "dns_vpc" {
  count = (var.dns_vpc_id != "") ? 1 : 0

  zone_id = aws_route53_zone.privatelink.zone_id
  vpc_id  = var.dns_vpc_id

  depends_on = [ 
    aws_route53_zone.privatelink
  ]
}

# Associate the PHZ with the TFC Agent VPC, if provided
resource "aws_route53_zone_association" "tfc_agent" {
  count = (var.tfc_agent_vpc_id != "") ? 1 : 0
  
  zone_id = aws_route53_zone.privatelink.zone_id
  vpc_id  = var.tfc_agent_vpc_id

  depends_on = [ 
    aws_route53_zone.privatelink
  ]
}

# Global wildcard CNAME (for multi-AZ deployments)
resource "aws_route53_record" "privatelink_wildcard" {
  count = length(var.vpc_subnet_ids) > 1 ? 1 : 0
  
  zone_id = aws_route53_zone.privatelink.zone_id
  name    = "*.${var.dns_domain}"
  type    = "CNAME"
  ttl     = 60
  records = [aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"]]

  depends_on = [ 
    aws_route53_zone.privatelink,
    aws_vpc_endpoint.privatelink 
  ]
}

# Zonal CNAME records (one per subnet/AZ)
resource "aws_route53_record" "privatelink_zonal" {
  for_each = toset(var.vpc_subnet_ids)
  
  zone_id = aws_route53_zone.privatelink.zone_id
  name    = length(var.vpc_subnet_ids) == 1 ? "*.${var.dns_domain}" : "*.${data.aws_availability_zone.privatelink[each.key].zone_id}.${var.dns_domain}"
  type    = "CNAME"
  ttl     = 60
  
  records = [
    format("%s-%s%s",
      split(".", aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"])[0],
      data.aws_availability_zone.privatelink[each.key].name,
      replace(
        aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"],
        split(".", aws_vpc_endpoint.privatelink.dns_entry[0]["dns_name"])[0],
        ""
      )
    )
  ]
  
  lifecycle {
    create_before_destroy = true
  }

  depends_on = [ 
    aws_route53_zone.privatelink,
    aws_vpc_endpoint.privatelink
  ]
}

# Wait for DNS propagation
resource "time_sleep" "wait_for_zone_associations" {
  depends_on = [
    aws_route53_zone_association.dns_vpc,
    aws_route53_zone_association.tfc_agent,
    aws_route53_record.privatelink_wildcard,
    aws_route53_record.privatelink_zonal
  ]
  
  create_duration = "3m"
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

# ============================================================================
# TRANSIT GATEWAY ATTACHMENT
# ============================================================================

resource "aws_ec2_transit_gateway_vpc_attachment" "privatelink" {
  subnet_ids         = data.aws_subnets.privatelink.ids
  transit_gateway_id = var.tgw_id
  vpc_id             = var.vpc_id
  
  # Enable DNS support for cross-VPC resolution
  dns_support = "enable"

  tags = {
    Name        = "${var.vpc_id}-ccloud-privatelink-tgw-attachment"
    Environment = data.confluent_environment.privatelink.display_name
    ManagedBy   = "Terraform Cloud"
    Purpose     = "Confluent PrivateLink connectivity"
  }
}

# Associate with Transit Gateway Route Table
resource "aws_ec2_transit_gateway_route_table_association" "privatelink" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.privatelink.id
  transit_gateway_route_table_id = var.tgw_rt_id
}

# ============================================================================
# ROUTE TABLE UPDATES FOR TRANSIT GATEWAY CONNECTIVITY
# ============================================================================

# Add route to for VPC via Transit Gateway
resource "aws_route" "privatelink_to_vpc" {
  route_table_id         = var.vpc_rt_id
  destination_cidr_block = var.vpc_cidr
  transit_gateway_id     = var.tgw_id
}

# Add route to TFC Agent VPC via Transit Gateway
resource "aws_route" "privatelink_to_tfc_agent" {
  route_table_id         = var.vpc_rt_id
  destination_cidr_block = var.tfc_agent_vpc_cidr
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.privatelink
  ]
}

# Add route to VPN clients via Transit Gateway
resource "aws_route" "privatelink_to_vpn_client" {
  route_table_id         = var.vpc_rt_id
  destination_cidr_block = var.vpn_client_cidr
  transit_gateway_id     = var.tgw_id

  depends_on = [
    aws_ec2_transit_gateway_vpc_attachment.privatelink
  ]
}

# ============================================================================
# SECURITY GROUP RULES FOR THE VPC
# ============================================================================
resource "aws_security_group" "privatelink" {
  name        = "ccloud-privatelink_${local.network_id}_${var.vpc_id}"
  description = "Confluent Cloud Private Link Security Group for ${var.dns_domain}"
  vpc_id      = var.vpc_id

  lifecycle {
    create_before_destroy = true
  }
  
  tags = {
    Name        = "ccloud-privatelink-${local.network_id}"
    VPC         = var.vpc_id
    Environment = data.confluent_environment.privatelink.display_name
  }
}

resource "aws_security_group_rule" "allow_https" {
  description       = "HTTPS from VPC, TFC Agent VPCs, and VPN clients"
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  cidr_blocks       = [var.tfc_agent_vpc_cidr, var.vpn_client_cidr, var.vpc_cidr]
  security_group_id = aws_security_group.privatelink.id
}

resource "aws_security_group_rule" "allow_kafka" {
  description       = "Kafka from VPC, TFC Agent VPCs, and VPN clients"
  type              = "ingress"
  from_port         = 9092
  to_port           = 9092
  protocol          = "tcp"
  cidr_blocks       = [var.tfc_agent_vpc_cidr, var.vpn_client_cidr, var.vpc_cidr]
  security_group_id = aws_security_group.privatelink.id
}
