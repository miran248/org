# google
resource "google_iam_workload_identity_pool" "oidc_tfc" {
  project = google_project.this.project_id

  workload_identity_pool_id = "terraform"
}
resource "google_iam_workload_identity_pool_provider" "oidc_tfc" {
  project = google_project.this.project_id

  workload_identity_pool_id          = google_iam_workload_identity_pool.oidc_tfc.workload_identity_pool_id
  workload_identity_pool_provider_id = "terraform-oidc"

  attribute_mapping = {
    "google.subject" = "assertion.sub"
    "attribute.aud"  = "assertion.aud"
  }
  attribute_condition = "assertion.sub.startsWith(\"organization:${var.tfc.organization}:project:${var.tfc.project}:workspace:${var.tfc.workspace}\")"

  oidc {
    issuer_uri = "https://app.terraform.io"
  }
}

resource "google_service_account" "oidc_tfc" {
  project = google_project.this.project_id

  account_id = "terraform"
}
resource "google_organization_iam_member" "oidc_tfc" {
  for_each = var.gcp.org_roles

  org_id = data.google_organization.this.org_id
  role   = each.key
  member = "serviceAccount:${google_service_account.oidc_tfc.email}"
}
resource "google_project_iam_member" "oidc_tfc" {
  for_each = var.gcp.roles

  project = google_project.this.project_id
  role    = each.key
  member  = "serviceAccount:${google_service_account.oidc_tfc.email}"
}
resource "google_service_account_iam_member" "oidc_tfc" {
  service_account_id = google_service_account.oidc_tfc.id
  role               = "roles/iam.workloadIdentityUser"
  member             = "principalSet://iam.googleapis.com/${google_iam_workload_identity_pool.oidc_tfc.name}/*"
}

# terraform
resource "tfe_variable" "enable_gcp_provider_auth" {
  workspace_id = tfe_workspace.this.id

  key      = "TFC_GCP_PROVIDER_AUTH"
  value    = "true"
  category = "env"

  description = "Enable the Workload Identity integration for GCP."
}
resource "tfe_variable" "gcp_workload_provider_name" {
  workspace_id = tfe_workspace.this.id

  key      = "TFC_GCP_WORKLOAD_PROVIDER_NAME"
  value    = google_iam_workload_identity_pool_provider.oidc_tfc.name
  category = "env"

  description = "The workload provider name to authenticate against."
}
resource "tfe_variable" "gcp_service_account_email" {
  workspace_id = tfe_workspace.this.id

  key      = "TFC_GCP_RUN_SERVICE_ACCOUNT_EMAIL"
  value    = google_service_account.oidc_tfc.email
  category = "env"

  description = "The GCP service account email runs will use to authenticate."
}
