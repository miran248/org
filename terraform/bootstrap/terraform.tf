terraform {
  cloud {
    organization = "miran248"

    workspaces {
      name = "bootstrap"
    }
  }
  required_providers {
    github = {
      source = "integrations/github"
    }
    google = {
      source = "hashicorp/google"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
    scaleway = {
      source = "scaleway/scaleway"
    }
    tfe = {
      source = "hashicorp/tfe"
    }
  }
}
