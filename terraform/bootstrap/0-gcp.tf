# projects
data "google_project" "sh_248" {
  project_id = "sh-248-org-bootstrap"
}
data "google_project" "terraform_talos_modules_dev" {
  project_id = "miran248-talos-modules-dev"
}

# secrets
data "google_secret_manager_secret_version" "github" {
  secret = "github"
}
data "google_secret_manager_secret_version" "scaleway" {
  secret = "scaleway"
}

# dns
data "google_dns_managed_zone" "sh_248" {
  project = data.google_project.sh_248.project_id
  name    = "sh-248"
}
