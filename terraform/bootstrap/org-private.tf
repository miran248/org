# The private half of the repo policy lives in its own repository and its own
# Terraform Cloud workspace, so no private token or private repo setting depends
# on the public bootstrap workspace's repository.
locals {
  tfc_project_org = "prj-beKuyN9ULjaJkZyT"
}

resource "github_repository" "org_private" {
  name        = "org-private"
  description = "Terraform-owned policy for the private miran248 repositories"
  visibility  = "private"
  auto_init   = true

  allow_auto_merge       = false
  allow_squash_merge     = true
  allow_merge_commit     = false
  allow_rebase_merge     = false
  delete_branch_on_merge = true

  has_issues   = true
  has_projects = true
  has_wiki     = false

  topics = [
    "terraform",
    "github",
  ]
}

resource "tfe_workspace" "private" {
  organization = "miran248"
  project_id   = local.tfc_project_org
  name         = "private"

  working_directory = "terraform"
  terraform_version = "latest"
  auto_apply        = false
}

resource "tfe_workspace_settings" "private" {
  workspace_id = tfe_workspace.private.id

  execution_mode = "remote"
}

resource "tfe_variable" "private_github_token" {
  workspace_id = tfe_workspace.private.id

  key       = "github_token"
  value     = local.tokens.github
  category  = "terraform"
  sensitive = true
}
