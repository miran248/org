# environments
# data "tfe_organization" "this" {
#   for_each = { for key, env in local.tfc.organizations : key => env }

#   name = each.value.tfc.organization
# }
# data "tfe_project" "this" {
#   for_each = { for key, env in local.tfc.projects : key => env if env.owned == false }

#   organization = each.value.tfc.organization
#   name         = each.value.tfc.project
# }
# data "tfe_workspace" "this" {
#   for_each = { for key, env in local.tfc.workspaces : key => env if env.owned == false }

#   organization = each.value.tfc.organization
#   name         = each.value.tfc.workspace
# }
