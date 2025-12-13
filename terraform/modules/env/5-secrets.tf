# TODO: generate unique token per project

# github
resource "google_secret_manager_secret" "github" {
  project = google_project.this.project_id

  secret_id = "github"

  replication {
    auto {
    }
  }
}
resource "google_secret_manager_secret_version" "github" {
  secret = google_secret_manager_secret.github.id

  secret_data = var.tokens.github
}

# scaleway
resource "google_secret_manager_secret" "scaleway" {
  project = google_project.this.project_id

  secret_id = "scaleway"

  replication {
    auto {
    }
  }
}
resource "google_secret_manager_secret_version" "scaleway" {
  secret = google_secret_manager_secret.scaleway.id

  secret_data = jsonencode({
    organization_id = var.scw.organization_id
    project_id      = scaleway_account_project.this.id
    access_key      = scaleway_iam_api_key.this.access_key
    secret_key      = scaleway_iam_api_key.this.secret_key
  })
}
