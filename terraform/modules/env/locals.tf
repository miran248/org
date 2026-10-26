locals {
  ids = {
    gcp = {
      project = google_project.this.id
    }
    tfc = {
      workspace = tfe_workspace.this.id
    }
    scw = {
      project     = scaleway_account_project.this.id
      application = scaleway_iam_application.this.id
    }
  }
}
