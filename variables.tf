# AKS Module Variables

# Naming and Resource Configuration
variable "name_prefix" {
  description = "Prefix for resource naming. If empty, defaults to 'aks-{environment}-{location_short}'"
  type        = string
  default     = ""
}

variable "name_suffix" {
  description = "Suffix for resource naming"
  type        = string
  default     = ""
}

variable "custom_name" {
  description = "Custom name for the AKS cluster. If provided, name_prefix and name_suffix are ignored"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure region for the AKS cluster"
  type        = string
}

variable "location_short" {
  description = "Short name for the location (e.g., 'eus' for East US)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "resource_group_id" {
  description = "Resource group ID for policy assignments"
  type        = string
  default     = null
}

variable "environment" {
  description = "Environment name (dev, test, prod, etc.)"
  type        = string
}

variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "enterprise"
}

variable "created_by" {
  description = "Identifier of who created this resource"
  type        = string
  default     = "terraform"
}

variable "additional_tags" {
  description = "Additional tags to add to resources"
  type        = map(string)
  default     = {}
}

# AKS Cluster Configuration
variable "dns_prefix" {
  description = "DNS prefix for the AKS cluster"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "Kubernetes version for the AKS cluster"
  type        = string
  default     = "1.27.3"
}

variable "node_resource_group" {
  description = "Resource group for cluster nodes. If empty, defaults to {resource_group_name}-aks-nodes"
  type        = string
  default     = ""
}

variable "sku_tier" {
  description = "SKU tier for the AKS cluster (Free or Paid)"
  type        = string
  default     = "Free"
  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "SKU tier must be either 'Free' or 'Paid'."
  }
}

variable "enable_private_cluster" {
  description = "Enable private cluster"
  type        = bool
  default     = true
}

# Identity Configuration
variable "enable_managed_identity" {
  description = "Enable system-assigned managed identity"
  type        = bool
  default     = true
}

# Default Node Pool Configuration
variable "default_node_pool_name" {
  description = "Name of the default node pool"
  type        = string
  default     = "default"
}

variable "default_node_pool_vm_size" {
  description = "VM size for the default node pool"
  type        = string
  default     = "Standard_DS2_v2"
}

variable "default_node_pool_node_count" {
  description = "Number of nodes in the default node pool"
  type        = number
  default     = 3
}

variable "enable_auto_scaling" {
  description = "Enable auto-scaling for the default node pool"
  type        = bool
  default     = true
}

variable "default_node_pool_min_count" {
  description = "Minimum number of nodes in the default node pool"
  type        = number
  default     = 1
}

variable "default_node_pool_max_count" {
  description = "Maximum number of nodes in the default node pool"
  type        = number
  default     = 10
}

variable "default_node_pool_os_disk_size_gb" {
  description = "OS disk size in GB for the default node pool"
  type        = number
  default     = 128
}

variable "default_node_pool_os_disk_type" {
  description = "OS disk type for the default node pool"
  type        = string
  default     = "Managed"
  validation {
    condition     = contains(["Managed", "Ephemeral"], var.default_node_pool_os_disk_type)
    error_message = "OS disk type must be either 'Managed' or 'Ephemeral'."
  }
}

variable "default_node_pool_max_pods" {
  description = "Maximum number of pods per node in the default node pool"
  type        = number
  default     = 110
}

variable "default_node_pool_labels" {
  description = "Labels for the default node pool"
  type        = map(string)
  default     = {}
}

variable "default_node_pool_taints" {
  description = "Taints for the default node pool"
  type        = list(string)
  default     = []
}

# Additional Node Pools
variable "additional_node_pools" {
  description = "Map of additional node pools to create"
  type = map(object({
    name                = string
    vm_size             = string
    node_count          = number
    min_count           = optional(number, 1)
    max_count           = optional(number, 10)
    enable_auto_scaling = optional(bool, true)
    os_disk_size_gb     = optional(number, 128)
    os_disk_type        = optional(string, "Managed")
    vnet_subnet_id      = optional(string)
    max_pods            = optional(number, 110)
    node_labels         = optional(map(string), {})
    node_taints         = optional(list(string), [])
    tags                = optional(map(string), {})
  }))
  default = {}
}

# Network Configuration
variable "vnet_id" {
  description = "Virtual network ID for the AKS cluster"
  type        = string
}

variable "vnet_subnet_id" {
  description = "Subnet ID for the AKS cluster nodes"
  type        = string
}

variable "enable_azure_cni" {
  description = "Enable Azure CNI networking"
  type        = bool
  default     = true
}

variable "enable_network_policy" {
  description = "Enable network policy"
  type        = bool
  default     = true
}

variable "dns_service_ip" {
  description = "IP address for the DNS service"
  type        = string
  default     = "10.0.0.10"
}



variable "service_cidr" {
  description = "CIDR for the service network"
  type        = string
  default     = "10.0.0.0/16"
}

variable "load_balancer_sku" {
  description = "SKU for the load balancer"
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["basic", "standard"], var.load_balancer_sku)
    error_message = "Load balancer SKU must be either 'basic' or 'standard'."
  }
}

variable "enable_load_balancer_profile" {
  description = "Enable load balancer profile"
  type        = bool
  default     = false
}

variable "managed_outbound_ip_count" {
  description = "Number of managed outbound IPs"
  type        = number
  default     = 1
}

variable "outbound_ip_prefix_ids" {
  description = "List of outbound IP prefix IDs"
  type        = list(string)
  default     = []
}

variable "outbound_ip_address_ids" {
  description = "List of outbound IP address IDs"
  type        = list(string)
  default     = []
}

# API Server Access
variable "enable_api_server_authorized_ip_ranges" {
  description = "Enable authorized IP ranges for API server"
  type        = bool
  default     = true
}

variable "api_server_authorized_ip_ranges" {
  description = "List of authorized IP ranges for API server"
  type        = list(string)
  default     = []
}

variable "api_server_subnet_id" {
  description = "Subnet ID for API server VNet integration"
  type        = string
  default     = null
}



# Azure AD Integration
variable "enable_aad_rbac" {
  description = "Enable Azure AD RBAC for the cluster"
  type        = bool
  default     = true
}



variable "aad_admin_group_object_ids" {
  description = "List of Azure AD group object IDs for cluster admins"
  type        = list(string)
  default     = []
}

variable "enable_azure_rbac" {
  description = "Enable Azure RBAC for Kubernetes authorization"
  type        = bool
  default     = true
}

# Key Vault Integration
variable "enable_key_vault_secrets_provider" {
  description = "Enable Key Vault secrets provider"
  type        = bool
  default     = true
}

variable "key_vault_secret_rotation_enabled" {
  description = "Enable secret rotation for Key Vault provider"
  type        = bool
  default     = true
}

variable "key_vault_secret_rotation_interval" {
  description = "Secret rotation interval"
  type        = string
  default     = "2m"
}

# OIDC and Workload Identity
variable "enable_oidc_issuer" {
  description = "Enable OIDC issuer"
  type        = bool
  default     = true
}

variable "enable_workload_identity" {
  description = "Enable workload identity"
  type        = bool
  default     = true
}

# Monitoring
variable "enable_azure_monitor" {
  description = "Enable Azure Monitor for containers"
  type        = bool
  default     = true
}

variable "enable_log_analytics" {
  description = "Enable Log Analytics workspace creation"
  type        = bool
  default     = true
}

variable "log_analytics_workspace_id" {
  description = "Existing Log Analytics workspace ID"
  type        = string
  default     = null
}

variable "log_analytics_sku" {
  description = "SKU for Log Analytics workspace"
  type        = string
  default     = "PerGB2018"
}

variable "log_analytics_retention_days" {
  description = "Retention period for Log Analytics data"
  type        = number
  default     = 30
}

# Auto-upgrade
variable "enable_auto_upgrade" {
  description = "Enable automatic cluster upgrades"
  type        = bool
  default     = true
}

variable "upgrade_channel" {
  description = "Upgrade channel for automatic upgrades"
  type        = string
  default     = "stable"
  validation {
    condition     = contains(["none", "patch", "stable", "rapid", "node-image"], var.upgrade_channel)
    error_message = "Upgrade channel must be one of: none, patch, stable, rapid, node-image."
  }
}

variable "upgrade_max_surge" {
  description = "Maximum surge for upgrades"
  type        = string
  default     = "10%"
}

# Maintenance Window
variable "enable_maintenance_window" {
  description = "Enable maintenance window"
  type        = bool
  default     = false
}

variable "maintenance_window_allowed" {
  description = "List of allowed maintenance windows"
  type = list(object({
    day   = string
    hours = list(number)
  }))
  default = []
}

variable "maintenance_window_not_allowed" {
  description = "List of not allowed maintenance windows"
  type = list(object({
    start = string
    end   = string
  }))
  default = []
}

# HTTP Proxy
variable "enable_http_proxy" {
  description = "Enable HTTP proxy configuration"
  type        = bool
  default     = false
}

variable "http_proxy_url" {
  description = "HTTP proxy URL"
  type        = string
  default     = ""
}

variable "https_proxy_url" {
  description = "HTTPS proxy URL"
  type        = string
  default     = ""
}

variable "no_proxy_list" {
  description = "List of addresses to exclude from proxy"
  type        = list(string)
  default     = []
}

variable "http_proxy_trusted_ca" {
  description = "Trusted CA for HTTP proxy"
  type        = string
  default     = ""
}

# Application Gateway Ingress
variable "enable_ingress_application_gateway" {
  description = "Enable Application Gateway ingress controller"
  type        = bool
  default     = false
}

variable "ingress_application_gateway_id" {
  description = "Existing Application Gateway ID"
  type        = string
  default     = null
}

variable "ingress_application_gateway_name" {
  description = "Name for new Application Gateway"
  type        = string
  default     = null
}

variable "ingress_application_gateway_subnet_cidr" {
  description = "Subnet CIDR for Application Gateway"
  type        = string
  default     = null
}

variable "ingress_application_gateway_subnet_id" {
  description = "Existing subnet ID for Application Gateway"
  type        = string
  default     = null
}

# Service Mesh
variable "enable_service_mesh" {
  description = "Enable service mesh"
  type        = bool
  default     = false
}

variable "service_mesh_mode" {
  description = "Service mesh mode"
  type        = string
  default     = "Istio"
  validation {
    condition     = contains(["Istio", "Linkerd"], var.service_mesh_mode)
    error_message = "Service mesh mode must be either 'Istio' or 'Linkerd'."
  }
}

# Diagnostic Settings
variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings"
  type        = bool
  default     = true
}

variable "diagnostic_logs" {
  description = "List of diagnostic logs to enable"
  type        = list(string)
  default = [
    "kube-apiserver",
    "kube-audit",
    "kube-audit-admin",
    "kube-controller-manager",
    "kube-scheduler",
    "cluster-autoscaler",
    "guard"
  ]
}

variable "diagnostic_metrics" {
  description = "List of diagnostic metrics to enable"
  type        = list(string)
  default = [
    "AllMetrics"
  ]
}

# Azure Policy
variable "enable_policy_assignments" {
  description = "Enable Azure Policy assignments"
  type        = bool
  default     = true
}

variable "enable_custom_policies" {
  description = "Enable custom Azure Policy definitions"
  type        = bool
  default     = false
}

variable "enable_policy_initiative" {
  description = "Enable Azure Policy initiative for AKS security"
  type        = bool
  default     = true
}

# Resource Lock
variable "enable_resource_lock" {
  description = "Enable resource lock for the AKS cluster"
  type        = bool
  default     = true
}

variable "resource_lock_level" {
  description = "Level of the resource lock"
  type        = string
  default     = "CanNotDelete"
  validation {
    condition     = contains(["CanNotDelete", "ReadOnly"], var.resource_lock_level)
    error_message = "Resource lock level must be 'CanNotDelete' or 'ReadOnly'."
  }
}