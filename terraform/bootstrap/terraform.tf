terraform {
  cloud {
    organization = "miran248"

    workspaces {
      name = "org-bootstrap"
    }
  }
  required_providers {
    github = {
      source = "integrations/github"
    }
  }
  required_version = ">= 1"
}