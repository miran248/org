# google
data "google_organization" "this" {
  domain = "248.sh"
}
data "google_billing_account" "this" {
  display_name = "main"

  lookup_projects = false
}

# scaleway
data "scaleway_iam_group" "admins" {
  name = "Administrators"
}

# terraform
data "tfe_project" "this" {
  organization = var.tfc.organization
  name         = var.tfc.project
}
