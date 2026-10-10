terraform {
  required_version = ">= 1.11"

  required_providers {
    consul = {
      source  = "hashicorp/consul"
      version = ">= 2.21, < 3.0"
    }
    nomad = {
      source  = "hashicorp/nomad"
      version = ">= 2.5, < 3.0"
    }
  }
}
