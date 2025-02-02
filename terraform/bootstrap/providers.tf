provider "github" {
  owner = "miran248"
  token = local.github_token
  # app_auth {}
}
provider "google" {
  project = "miran248-org-bootstrap"
  region  = "global"
}
provider "scaleway" {
  organization_id = local.scaleway.organization_id
  project_id      = local.scaleway.project_id
  access_key      = local.scaleway.access_key
  secret_key      = local.scaleway.secret_key
}
provider "tfe" {
  organization = "miran248"
  token        = var.tfe_token
  hostname     = "app.terraform.io"
}
