variable "gcp" {
  type = object({
    project   = string
    services  = set(string)
    org_roles = set(string)
    roles     = set(string)
  })
  description = "gcp project"
}

variable "scw" {
  type = object({
    project = string
  })
  description = "scw project"
}

variable "tfc" {
  type = object({
    organization      = string
    project           = string
    workspace         = string
    working_directory = string
  })
  description = "tfc workspace"
}

variable "tokens" {
  type = object({
    github   = string
    scaleway = string
  })
  description = "externally managed tokens"
}
