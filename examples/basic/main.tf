# Basic AKS Example

terraform {
  required_version = ">= 1.5.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# Resource Group
resource "azurerm_resource_group" "test" {
  name     = var.resource_group_name
  location = var.location
}

# Use the AKS module
module "aks" {
  source = "../"
  
  cluster_name        = var.cluster_name
  location            = var.location
  resource_group_name = azurerm_resource_group.test.name
  dns_prefix          = var.dns_prefix
  kubernetes_version  = var.kubernetes_version
  
  node_pools = var.node_pools
  
  enable_private_cluster = var.enable_private_cluster
  network_plugin        = var.network_plugin
  network_policy        = var.network_policy
  sku_tier             = var.sku_tier
  enable_rbac          = var.enable_rbac
  azure_policy_enabled = var.azure_policy_enabled
}

# Variables
variable "cluster_name" {
  description = "Name of the AKS cluster"
  type        = string
}

variable "location" {
  description = "Location for resources"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_prefix" {
  description = "DNS prefix for the cluster"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28.0"
}

variable "node_pools" {
  description = "Node pools configuration"
  type        = any
  default     = {}
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

variable "network_plugin" {
  description = "Network plugin"
  type        = string
  default     = "azure"
}

variable "network_policy" {
  description = "Network policy"
  type        = string
  default     = "azure"
}

variable "sku_tier" {
  description = "SKU tier"
  type        = string
  default     = "Standard"
}

variable "enable_rbac" {
  description = "Enable RBAC"
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "Enable Azure Policy"
  type        = bool
  default     = true
}

# Outputs
output "cluster_name" {
  value = module.aks.cluster_name
}

output "cluster_id" {
  value = module.aks.cluster_id
}