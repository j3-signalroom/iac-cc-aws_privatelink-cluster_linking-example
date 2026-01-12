data "tfe_workspace" "workspace" {
  name         = "cc-cluster-linking-privatelink-iac-demo"
  organization = "signalroom"
}

data "tfe_agent_pool" "workspace_agent_pool" {
  name          = "signalroom-tfc-agent-pool"
  organization  = "signalroom"
}

resource "tfe_agent_pool_allowed_workspaces" "agent-pool-allowed-workspaces" {
  agent_pool_id         = data.tfe_agent_pool.workspace_agent_pool.id
  allowed_workspace_ids = [data.tfe_workspace.workspace.id]
}

resource "tfe_workspace_settings" "workspace_settings" {
  workspace_id   = data.tfe_workspace.workspace.id
  agent_pool_id  = tfe_agent_pool_allowed_workspaces.agent-pool-allowed-workspaces.agent_pool_id
  execution_mode = "agent"
}