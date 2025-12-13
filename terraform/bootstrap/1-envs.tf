module "miran248-terraform-talos-modules-dev" {
  source = "../modules/env"

  gcp = {
    project   = "miran248-talos-modules-dev"
    services  = flatten([local.s0.gcp.services, "storage-api.googleapis.com"])
    org_roles = ["roles/resourcemanager.folderAdmin", "roles/resourcemanager.organizationViewer"]
    roles     = flatten([local.s0.gcp.roles, "roles/storage.admin"])
  }
  scw = { project = "miran248-terraform-talos-modules-dev" }
  tfc = { organization = "miran248", project = "terraform-talos-modules", workspace = "dev", working_directory = "dev" }

  tokens = local.tokens
}
