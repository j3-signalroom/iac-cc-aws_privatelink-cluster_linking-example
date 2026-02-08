data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_vpc" "tfc_agent" {
  id = var.tfc_agent_vpc_id
}

data "aws_vpc" "dns" {
  id = var.dns_vpc_id
}

data "aws_vpc" "vpn" {
  id = var.vpn_vpc_id
}

locals {
  cloud = "AWS"
  acl_operations = ["READ", "WRITE", "DESCRIBE"]
}
