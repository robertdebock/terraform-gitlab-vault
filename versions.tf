terraform {
  required_providers {
    vault = {
      source  = "hashicorp/vault"
      version = "3.8.2"
    }
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "3.18.0"
    }
  }
}