resource "tfe_organization" "this" {
  for_each = { for key, env in local.tfc.organizations : key => env if env.owned }

  name  = each.value.tfc.organization
  email = "miran@248.sh"

  allow_force_delete_workspaces = true
  cost_estimation_enabled       = true
}
# TODO: limit to a set of workspaces
# TODO: generate unique token per workspace
resource "tfe_variable_set" "tfe" {
  for_each = tfe_organization.this

  organization = each.value.name
  name         = "tfe"
  description  = "global tfe variables"
  global       = true
}
resource "tfe_variable" "tfe_token" {
  for_each = tfe_variable_set.tfe

  variable_set_id = each.value.id
  category        = "terraform"
  key             = "tfe_token"
  value           = var.tfe_token
}

resource "tfe_project" "this" {
  for_each = { for key, env in local.tfc.projects : key => env if env.owned }

  organization = tfe_organization.this[each.value.keys.tfc.organization].id
  name         = each.value.tfc.project
}

resource "tfe_workspace" "this" {
  for_each = { for key, env in local.tfc.workspaces : key => env if env.owned }

  organization = tfe_organization.this[each.value.keys.tfc.organization].id
  project_id   = tfe_project.this[each.value.keys.tfc.project].id
  name         = each.value.tfc.workspace

  allow_destroy_plan            = true
  structured_run_output_enabled = true

  working_directory = each.value.tfc.working_directory

  terraform_version = "latest"
}
resource "tfe_workspace_settings" "this" {
  for_each = tfe_workspace.this

  workspace_id = each.value.id

  execution_mode = "remote"
}
