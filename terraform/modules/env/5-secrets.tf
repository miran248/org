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
  for_each = google_secret_manager_secret.github

  secret      = each.value.id
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
  for_each = google_secret_manager_secret.scaleway

  secret      = each.value.id
  secret_data = var.tokens.scaleway
}
