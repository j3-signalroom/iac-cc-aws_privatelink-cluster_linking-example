locals {
  network_id = split(".", var.dns_domain)[0]
}

# Get Confluent Environment details
data "confluent_environment" "privatelink" {
  id = var.confluent_environment_id
}

