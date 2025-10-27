# AKS Module Version Requirements

terraform {
  required_version = "~> 4.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}