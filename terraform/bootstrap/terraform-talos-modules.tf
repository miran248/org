# repo
resource "github_repository" "terraform-talos-modules" {
  name        = "terraform-talos-modules"
  description = "a collection of opinionated terraform modules for running talos on hetzner"

  allow_auto_merge       = true
  allow_merge_commit     = true
  allow_squash_merge     = false
  allow_rebase_merge     = false
  auto_init              = false
  delete_branch_on_merge = false
  has_issues             = true
  has_projects           = false
  has_wiki               = false
  visibility             = "public"

  topics = [
    "terraform",
    "talos",
    "modules",
    "hetzner",
  ]
}

# project
resource "tfe_project" "terraform-talos-modules" {
  organization = "miran248"
  name         = "terraform-talos-modules"
}

# envs
module "terraform-talos-modules-dev" {
  source = "../modules/env"

  gcp = {
    project   = "miran248-talos-modules-dev"
    services  = flatten([local.gcp.services, "storage-api.googleapis.com"])
    org_roles = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.organizationViewer"]
    roles     = flatten([local.gcp.roles, "roles/storage.admin"])
  }
  scw = { organization_id = local.tokens.scaleway.organization_id, project = "miran248-terraform-talos-modules-dev" }
  tfc = { organization = "miran248", project = "terraform-talos-modules", workspace = "dev", working_directory = "dev" }

  tokens = { github = local.tokens.github }
}

# dns
data "google_project" "terraform-talos-modules-dev" {
  project_id = "miran248-talos-modules-dev"
}
resource "google_dns_managed_zone" "terraform-talos-modules-dev" {
  project  = data.google_project.terraform-talos-modules-dev.project_id
  name     = "dev"
  dns_name = "dev.248.sh."

  dnssec_config {
    state = "on"
  }
}
resource "google_dns_record_set" "terraform-talos-modules-dev" {
  project      = data.google_project.sh_248.project_id
  managed_zone = data.google_dns_managed_zone.sh_248.name
  name         = "dev.${data.google_dns_managed_zone.sh_248.dns_name}"
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.terraform-talos-modules-dev.name_servers
}
