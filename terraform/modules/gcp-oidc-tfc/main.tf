resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = var.tfc_workspace_id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}
resource "tfe_variable" "gcp_workload_provider_name" {
  workspace_id = var.tfc_workspace_id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = var.gcp_pool_provider_name
  category = "env"

  description = "The workload provider name to authenticate against."
}
resource "tfe_variable" "gcp_service_account_email" {
  workspace_id = var.tfc_workspace_id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = var.gcp_service_account_email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}
