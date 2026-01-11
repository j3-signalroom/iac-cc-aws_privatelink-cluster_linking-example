variable "vpc_id_to_privatelink" {
  description = "Target VPC for PrivateLink connection"
  type        = string
}

variable "privatelink_service_name" {
  description = "Confluent Cloud service name (e.g., com.amazonaws.vpce.us-east-1.vpce-svc-xxxxx)"
  type        = string
}

variable "dns_domain" {
  description = "Confluent domain (e.g., plkxyz.us-east-1.aws.confluent.cloud)"
  type        = string
}

variable "tfc_agent_vpc_id" {
  description = "VPC where TFC Agent runs (for cross-VPC DNS)"
  type        = string
}