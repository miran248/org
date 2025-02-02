# environments
data "google_organization" "this" {
  domain = "248.sh"
}
data "google_billing_account" "this" {
  display_name = "main"

  lookup_projects = false
}

# secrets
data "google_secret_manager_secret_version" "github_token" {
  secret = "github-token"
}
data "google_secret_manager_secret_version" "scaleway" {
  secret = "scaleway"
}

# projects
data "google_project" "this" {
  for_each = { for key, env in local.gcp.projects : key => env if env.owned == false }

  project_id = each.value.gcp.project
}
