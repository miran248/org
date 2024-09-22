provider "github" {
  owner = "miran248"
  token = var.github_token
}
provider "tfe" {
  organization = "miran248"
  token        = var.tfe_token
}
