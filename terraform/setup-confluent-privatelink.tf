resource "confluent_private_link_attachment" "non_prod" {
  cloud = "AWS"
  region = var.aws_region
  display_name = "non-prod-aws-platt"
  environment {
    id = confluent_environment.non_prod.id
  }
}

module "sandbox_cluster_privatelink" {
  source                   = "./aws-privatelink-endpoint"
  privatelink_service_name = confluent_private_link_attachment.non_prod.aws[0].vpc_endpoint_service_name
  dns_domain               = confluent_private_link_attachment.non_prod.dns_domain
  vpc_id_to_privatelink    = var.sandbox_cluster_vpc_id_to_privatelink
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id
}

resource "confluent_private_link_attachment_connection" "sandbox_cluster_plattc" {
  display_name = "sandbox-cluster-aws-plattc"
  environment {
    id = confluent_environment.non_prod.id
  }
  aws {
    vpc_endpoint_id = module.sandbox_cluster_privatelink.vpc_endpoint_id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.non_prod.id
  }
}

module "shared_cluster_privatelink" {
  source                   = "./aws-privatelink-endpoint"
  privatelink_service_name = confluent_private_link_attachment.non_prod.aws[0].vpc_endpoint_service_name
  dns_domain               = confluent_private_link_attachment.non_prod.dns_domain
  vpc_id_to_privatelink    = var.shared_cluster_vpc_id_to_privatelink
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id
}

resource "confluent_private_link_attachment_connection" "shared_cluster_plattc" {
  display_name = "shared-cluster-aws-plattc"
  environment {
    id = confluent_environment.non_prod.id
  }
  aws {
    vpc_endpoint_id = module.shared_cluster_privatelink.vpc_endpoint_id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.non_prod.id
  }
}