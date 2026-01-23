data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

locals {
  cloud = "AWS"
}

locals {
  acl_operations = ["READ", "WRITE", "DESCRIBE"]
}
