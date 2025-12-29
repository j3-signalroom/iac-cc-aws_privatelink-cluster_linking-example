resource "confluent_environment" "sandbox_cluster_sharing" {
  display_name = "sandbox_cluster_sharing"

  stream_governance {
    package = "ESSENTIALS"
  }
}