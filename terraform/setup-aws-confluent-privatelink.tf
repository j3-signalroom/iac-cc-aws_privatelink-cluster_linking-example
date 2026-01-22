resource "confluent_private_link_attachment" "non_prod" {
  cloud        = "AWS"
  region       = var.aws_region
  display_name = "${confluent_environment.non_prod.display_name}-aws-platt"
  
  environment {
    id = confluent_environment.non_prod.id
  }
}

# ===================================================================================
# SANDBOX AWS VPC WITH TGW INTEGRATION CREATION AND CONFLUENT PRIVATELINK ENDPOINT
# ===================================================================================
module "sandbox_vpc" {
  source = "./modules/aws-vpc"
  
  vpc_name          = "sandbox-${confluent_environment.non_prod.display_name}-vpc"
  vpc_cidr          = "10.0.0.0/20"
  subnet_count      = 3
  new_bits          = 4

  depends_on = [ 
    confluent_private_link_attachment.non_prod 
  ]
}

module "sandbox_vpc_privatelink" {
  source = "./modules/aws-vpc-confluent-privatelink"
  
  # Transit Gateway configuration
  tgw_id                   = var.tgw_id
  tgw_rt_id                = var.tgw_rt_id

  # PrivateLink configuration from Confluent
  privatelink_service_name = confluent_private_link_attachment.non_prod.aws[0].vpc_endpoint_service_name
  dns_domain               = confluent_private_link_attachment.non_prod.dns_domain
  
  # AWS VPC configuration
  vpc_id                   = module.sandbox_vpc.vpc_id
  vpc_cidr                 = module.sandbox_vpc.vpc_cidr
  vpc_subnet_ids           = module.sandbox_vpc.private_subnet_ids
  vpc_availability_zones   = module.sandbox_vpc.private_subnet_azs
  vpc_rt_id                = module.sandbox_vpc.vpc_rt_id

  # VPN Client configuration
  vpn_client_cidr          = var.vpn_client_cidr

  # DNS VPC configuration
  dns_vpc_id               = var.dns_vpc_id

  # Confluent Cloud configuration
  confluent_environment_id = confluent_environment.non_prod.id
  confluent_platt_id       = confluent_private_link_attachment.non_prod.id

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id
  tfc_agent_vpc_cidr       = var.tfc_agent_vpc_cidr

  depends_on = [ 
    module.sandbox_vpc 
  ]
}

# ===================================================================================
# SHARED AWS VPC WITH TGW INTEGRATION CREATION AND CONFLUENT PRIVATELINK ENDPOINT
# ===================================================================================
module "shared_vpc" {
  source = "./modules/aws-vpc"
  
  vpc_name          = "shared-${confluent_environment.non_prod.display_name}-vpc"
  vpc_cidr          = "10.1.0.0/20"
  subnet_count      = 3
  new_bits          = 4

  depends_on = [ 
    confluent_private_link_attachment.non_prod 
  ]
}

module "shared_vpc_privatelink" {
  source = "./modules/aws-vpc-confluent-privatelink"
  
  # Transit Gateway configuration
  tgw_id                   = var.tgw_id
  tgw_rt_id                = var.tgw_rt_id

  # PrivateLink configuration from Confluent
  privatelink_service_name = confluent_private_link_attachment.non_prod.aws[0].vpc_endpoint_service_name
  dns_domain               = confluent_private_link_attachment.non_prod.dns_domain
  
  # AWS VPC configuration
  vpc_id                   = module.shared_vpc.vpc_id
  vpc_cidr                 = module.shared_vpc.vpc_cidr
  vpc_subnet_ids           = module.shared_vpc.private_subnet_ids
  vpc_availability_zones   = module.shared_vpc.private_subnet_azs
  vpc_rt_id                = module.shared_vpc.vpc_rt_id

  # VPN Client configuration
  vpn_client_cidr          = var.vpn_client_cidr

  # DNS VPC configuration
  dns_vpc_id               = var.dns_vpc_id

  # Confluent Cloud configuration
  confluent_environment_id = confluent_environment.non_prod.id
  confluent_platt_id       = confluent_private_link_attachment.non_prod.id

  # Terraform Cloud Agent configuration
  tfc_agent_vpc_id         = var.tfc_agent_vpc_id
  tfc_agent_vpc_cidr       = var.tfc_agent_vpc_cidr

  depends_on = [ 
    module.shared_vpc 
  ]
}
