resource "github_repository" "terraform_talos_modules" {
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

resource "tfe_workspace" "terraform_talos_modules" {
  name               = "terraform-talos-modules"
  organization       = data.tfe_organization.this.name
  allow_destroy_plan = true
  terraform_version  = "latest"
  working_directory  = "dev"
}
