data "google_project" "sh_248" {
  project_id = "sh-248-org-bootstrap"
}
data "google_dns_managed_zone" "sh_248" {
  project = data.google_project.sh_248.project_id
  name    = "sh-248"
}
data "google_project" "miran248-talos-modules-dev" {
  project_id = "miran248-talos-modules-dev"
}

# terraform-talos-modules-dev
resource "google_dns_managed_zone" "miran248_ttm_dev" {
  project  = data.google_project.miran248-talos-modules-dev.project_id
  name     = "dev"
  dns_name = "dev.248.sh."

  dnssec_config {
    state = "on"
  }
}
resource "google_dns_record_set" "miran248_ttm_dev" {
  project      = data.google_project.sh_248.project_id
  managed_zone = data.google_dns_managed_zone.sh_248.name
  name         = "dev.${data.google_dns_managed_zone.sh_248.dns_name}"
  type         = "NS"
  ttl          = 300

  rrdatas = google_dns_managed_zone.miran248_ttm_dev.name_servers
}
