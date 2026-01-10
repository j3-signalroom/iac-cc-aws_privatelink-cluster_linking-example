# Fetches VPC details including CIDR block
data "aws_vpc" "privatelink" {
  id = var.vpc_id_to_privatelink
}

# Filters subnets in target VPC tagged with Type = "private"
# Returns set of subnet IDs for multi-AZ endpoint deployment
data "aws_subnets" "subnets_to_privatelink" {
  filter {
    name   = "vpc-id"
    values = [var.vpc_id_to_privatelink]
  }
  
  tags = {
    Type = "private"
  }
}

# Fetches details for each subnet identified for PrivateLink endpoint
data "aws_subnet" "subnets_to_privatelink" {
  for_each = toset(data.aws_subnets.subnets_to_privatelink.ids)
  id = each.value
}

# Creates map of subnet_id → AZ name
data "aws_availability_zone" "privatelink" {
  for_each = toset(data.aws_subnets.subnets_to_privatelink.ids)
  name = data.aws_subnet.subnets_to_privatelink[each.key].availability_zone
}