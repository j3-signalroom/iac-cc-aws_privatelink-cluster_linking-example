# ============================================
# SANDBOX ENVIRONMENT
# ============================================
resource "confluent_environment" "sandbox" {
  display_name = "Sandbox"

  stream_governance {
    package = "ESSENTIALS"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_private_link_attachment" "sandbox" {
  cloud        = "AWS"
  region       = var.aws_region
  display_name = "sandbox-aws-platt"
  
  environment {
    id = confluent_environment.sandbox.id
  }
}

# ============================================
# SHARED ENVIRONMENT
# ============================================
resource "confluent_environment" "shared" {
  display_name = "Shared"

  stream_governance {
    package = "ESSENTIALS"
  }
  
  lifecycle {
    prevent_destroy = true
  }
}

resource "confluent_private_link_attachment" "shared" {
  cloud        = "AWS"
  region       = var.aws_region
  display_name = "shared-aws-platt"
  
  environment {
    id = confluent_environment.shared.id
  }
}
