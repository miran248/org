resource "tfe_organization" "this" {
  for_each = toset(local.tfc.owned_organizations)

  name  = each.key
  email = "miran@248.sh"

  allow_force_delete_workspaces = true
  cost_estimation_enabled       = true
}
# data "tfe_team" "this" {
#   for_each = tfe_organization.this

#   organization = each.value.name
#   name         = "owners"
# }
# resource "tfe_team_token" "this" {
#   for_each = data.tfe_team.this

#   team_id = each.value.id
# }
# resource "tfe_variable_set" "tfe" {
#   for_each = tfe_organization.this

#   organization = each.value.name
#   name         = "tfe"
#   description  = "global tfe variables"
#   global       = true
# }
# resource "tfe_variable" "tfe_token" {
#   for_each = tfe_variable_set.tfe

#   variable_set_id = each.value.id
#   category        = "terraform"
#   key             = "tfe_token"
#   value           = tfe_team_token.this[each.key].token
# }
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

  organization = each.value.keys.tfc.organization
  name         = each.value.tfc.project
}

# resource "tfe_workspace" "this" {
#   for_each = { for key, env in local.tfc.workspaces : key => env if env.owned }

#   organization = each.value.keys.tfc.organization
#   project_id   = tfe_project.this[each.value.keys.tfc.project].id
#   name         = each.value.tfc.workspace

#   allow_destroy_plan            = true
#   structured_run_output_enabled = true

#   working_directory = each.value.tfc.working_directory

#   terraform_version = "latest"
# }
moved {
  from = tfe_workspace.this["miran248-terraform-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.tfe_workspace.this
}
# resource "tfe_workspace_settings" "this" {
#   for_each = tfe_workspace.this

#   workspace_id = each.value.id

#   execution_mode = "remote"
# }
moved {
  from = tfe_workspace_settings.this["miran248-terraform-talos-modules-dev"]
  to   = module.miran248-terraform-talos-modules-dev.tfe_workspace_settings.this
}
