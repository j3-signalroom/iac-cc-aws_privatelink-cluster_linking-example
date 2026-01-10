resource "confluent_private_link_attachment" "sandbox_cluster" {
  cloud = "AWS"
  region = var.aws_region
  display_name = "sandbox-cluster-aws-platt"
  environment {
    id = confluent_environment.non_prod.id
  }
}

module "sandbox_cluster_privatelink" {
  source                   = "./aws-privatelink-endpoint"
  privatelink_service_name = confluent_private_link_attachment.sandbox_cluster.aws[0].vpc_endpoint_service_name
  dns_domain               = "${confluent_kafka_cluster.sandbox_cluster.id}.${confluent_private_link_attachment.sandbox_cluster.dns_domain}"
  vpc_id_to_privatelink    = var.sandbox_cluster_vpc_id_to_privatelink
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id
}

resource "confluent_private_link_attachment_connection" "sandbox_cluster" {
  display_name = "sandbox-cluster-aws-plattc"
  environment {
    id = confluent_environment.non_prod.id
  }
  aws {
    vpc_endpoint_id = module.sandbox_cluster_privatelink.vpc_endpoint_id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.sandbox_cluster.id
  }
}

resource "confluent_private_link_attachment" "shared_cluster" {
  cloud = "AWS"
  region = var.aws_region
  display_name = "shared-cluster-aws-platt"
  environment {
    id = confluent_environment.non_prod.id
  }
}

module "shared_cluster_privatelink" {
  source                   = "./aws-privatelink-endpoint"
  privatelink_service_name = confluent_private_link_attachment.shared_cluster.aws[0].vpc_endpoint_service_name
  dns_domain               = "${confluent_kafka_cluster.shared_cluster.id}.${confluent_private_link_attachment.shared_cluster.dns_domain}"
  vpc_id_to_privatelink    = var.shared_cluster_vpc_id_to_privatelink
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id
}

resource "confluent_private_link_attachment_connection" "shared_cluster" {
  display_name = "shared-cluster-aws-plattc"
  environment {
    id = confluent_environment.non_prod.id
  }
  aws {
    vpc_endpoint_id = module.shared_cluster_privatelink.vpc_endpoint_id
  }

  private_link_attachment {
    id = confluent_private_link_attachment.shared_cluster.id
  }
}