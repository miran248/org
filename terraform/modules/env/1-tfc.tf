resource "tfe_workspace" "this" {
  organization = data.tfe_project.this.organization
  project_id   = data.tfe_project.this.id
  name         = var.tfc.workspace

  allow_destroy_plan            = true
  structured_run_output_enabled = true

  working_directory = var.tfc.working_directory

  terraform_version = "latest"
}
resource "tfe_workspace_settings" "this" {
  workspace_id = tfe_workspace.this.id

  execution_mode = "remote"
}
