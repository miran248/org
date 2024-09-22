# from github variable set
variable "github_token" {
  sensitive = true
  type      = string
}

# from tfe variable set
variable "tfe_token" {
  sensitive = true
  type      = string
}
