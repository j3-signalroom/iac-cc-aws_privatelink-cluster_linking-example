data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

# Reference the existing VPC
# Get all matching VPCs
data "aws_vpcs" "tfc_agent" {
  filter {
    name   = "tag:Name"
    values = ["signalroom-tfc-agent-vpc"]
  }
  
  filter {
    name   = "state"
    values = ["available"]
  }
}

# Get details of the first VPC
data "aws_vpc" "tfc_agent" {
  id = tolist(data.aws_vpcs.tfc_agent.ids)[0]
}

# Reference the existing TFC agent security group
data "aws_security_group" "tfc_agent" {
  filter {
    name   = "tag:Name"
    values = ["signalroom-tfc-agent-terraform-agent-sg"]
  }

  vpc_id = data.aws_vpc.tfc_agent.id
}

# Reference private subnets
data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.tfc_agent.id]
  }
  
  filter {
    name   = "tag:Type"
    values = ["Private"]
  }
}

locals {
  cloud = "AWS"
}
