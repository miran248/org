resource "google_project" "this" {
  org_id          = data.google_organization.this.org_id
  billing_account = data.google_billing_account.this.id
  project_id      = var.gcp.project
  name            = var.gcp.project

  deletion_policy = "DELETE"
}
resource "google_project_service" "this" {
  for_each = var.gcp.services

  project = google_project.this.project_id
  service = each.key

  disable_on_destroy         = false
  disable_dependent_services = false
}
