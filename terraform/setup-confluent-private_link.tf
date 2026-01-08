resource "confluent_network" "cluster_linking_demo" {
  display_name     = "signalroom-network"
  cloud            = "AWS"
  region           = "us-east-1"
  connection_types = ["PRIVATELINK"]
  
  environment {
    id = confluent_environment.cluster_linking_demo.id
  }
  
  zones = ["ua-east-1a", "us-east-1b"]
}

resource "confluent_private_link_access" "cluster_linking_demo" {
  display_name = "aws-privatelink"
  
  environment {
    id = confluent_environment.cluster_linking_demo.id
  }
  
  network {
    id = confluent_network.cluster_linking_demo.id
  }
  
  aws {
    account = data.aws_caller_identity.current.account_id
  }
}

# AWS VPC Endpoint
resource "aws_vpc_endpoint" "confluent" {
  vpc_id              = data.aws_vpc.tfc_agent.id
  service_name        = confluent_private_link_attachment.destination.aws[0].vpc_endpoint_service_name
  vpc_endpoint_type   = "Interface"
  subnet_ids          = data.aws_subnets.private.ids
  security_group_ids  = [data.aws_security_group.tfc_agent.id]
  
  private_dns_enabled = false
}