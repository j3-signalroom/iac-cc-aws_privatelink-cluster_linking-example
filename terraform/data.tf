data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  cloud = "AWS"
}

locals {
  # Combine zone IDs from both VPCs
  all_zone_ids = distinct(concat(
    [for s in data.aws_subnet.sandbox_subnets : s.availability_zone_id],
    [for s in data.aws_subnet.shared_subnets : s.availability_zone_id]
  ))

  acl_operations = ["READ", "WRITE", "DESCRIBE"]
}
