# AKS Module Outputs

output "aks_cluster_id" {
  description = "The ID of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.id
}

output "aks_cluster_name" {
  description = "The name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.name
}

output "aks_cluster_fqdn" {
  description = "The FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.fqdn
}

output "aks_cluster_private_fqdn" {
  description = "The private FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.private_fqdn
}

output "aks_cluster_portal_fqdn" {
  description = "The portal FQDN of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.portal_fqdn
}

output "aks_kube_config" {
  description = "The kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config
  sensitive   = true
}

output "aks_kube_config_raw" {
  description = "The raw kubeconfig for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config_raw
  sensitive   = true
}

output "aks_host" {
  description = "The Kubernetes cluster server host"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].host
}

output "aks_client_certificate" {
  description = "The client certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_certificate
  sensitive   = true
}

output "aks_client_key" {
  description = "The client key for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].client_key
  sensitive   = true
}

output "aks_cluster_ca_certificate" {
  description = "The cluster CA certificate for the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kube_config[0].cluster_ca_certificate
  sensitive   = true
}

output "aks_node_resource_group" {
  description = "The resource group containing the AKS cluster nodes"
  value       = azurerm_kubernetes_cluster.this.node_resource_group
}

output "aks_location" {
  description = "The location of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.location
}

output "aks_resource_group_name" {
  description = "The resource group name of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.resource_group_name
}

output "aks_kubernetes_version" {
  description = "The Kubernetes version of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.kubernetes_version
}

output "aks_identity" {
  description = "The identity configuration of the AKS cluster"
  value = var.enable_managed_identity ? {
    type         = azurerm_kubernetes_cluster.this.identity[0].type
    principal_id = azurerm_kubernetes_cluster.this.identity[0].principal_id
    tenant_id    = azurerm_kubernetes_cluster.this.identity[0].tenant_id
  } : null
}

output "aks_user_assigned_identity_id" {
  description = "The ID of the user-assigned identity"
  value       = var.enable_managed_identity ? null : azurerm_user_assigned_identity.aks[0].id
}

output "aks_user_assigned_identity_principal_id" {
  description = "The principal ID of the user-assigned identity"
  value       = var.enable_managed_identity ? null : azurerm_user_assigned_identity.aks[0].principal_id
}

output "aks_user_assigned_identity_client_id" {
  description = "The client ID of the user-assigned identity"
  value       = var.enable_managed_identity ? null : azurerm_user_assigned_identity.aks[0].client_id
}

output "aks_default_node_pool" {
  description = "The default node pool configuration"
  value = {
    name       = azurerm_kubernetes_cluster.this.default_node_pool[0].name
    node_count = azurerm_kubernetes_cluster.this.default_node_pool[0].node_count
    vm_size    = azurerm_kubernetes_cluster.this.default_node_pool[0].vm_size
  }
}

output "aks_additional_node_pools" {
  description = "Map of additional node pools created"
  value = {
    for k, v in azurerm_kubernetes_cluster_node_pool.additional : k => {
      name       = v.name
      node_count = v.node_count
      vm_size    = v.vm_size
      id         = v.id
    }
  }
}

output "aks_network_profile" {
  description = "The network profile of the AKS cluster"
  value = {
    network_plugin    = azurerm_kubernetes_cluster.this.network_profile[0].network_plugin
    network_policy    = azurerm_kubernetes_cluster.this.network_profile[0].network_policy
    service_cidr      = azurerm_kubernetes_cluster.this.network_profile[0].service_cidr
    dns_service_ip    = azurerm_kubernetes_cluster.this.network_profile[0].dns_service_ip
    load_balancer_sku = azurerm_kubernetes_cluster.this.network_profile[0].load_balancer_sku
  }
}

output "aks_oidc_issuer_url" {
  description = "The OIDC issuer URL of the AKS cluster"
  value       = var.enable_oidc_issuer ? azurerm_kubernetes_cluster.this.oidc_issuer_url : null
}

output "aks_log_analytics_workspace_id" {
  description = "The ID of the Log Analytics workspace"
  value       = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : (var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].id : null)
}

output "aks_log_analytics_workspace_name" {
  description = "The name of the Log Analytics workspace"
  value       = var.log_analytics_workspace_id != null ? null : (var.enable_log_analytics ? azurerm_log_analytics_workspace.this[0].name : null)
}

output "aks_diagnostic_setting_id" {
  description = "The ID of the diagnostic setting"
  value       = var.enable_diagnostic_settings ? azurerm_monitor_diagnostic_setting.aks[0].id : null
}

output "aks_policy_assignment_id" {
  description = "The ID of the Azure Policy assignment"
  value       = var.enable_policy_assignments ? azurerm_resource_group_policy_assignment.aks_security[0].id : null
}

output "aks_resource_lock_id" {
  description = "The ID of the resource lock"
  value       = var.enable_resource_lock ? azurerm_management_lock.this[0].id : null
}

output "aks_tags" {
  description = "Tags applied to the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.tags
}

# Security information
output "aks_private_cluster_enabled" {
  description = "Whether the AKS cluster is private"
  value       = azurerm_kubernetes_cluster.this.private_cluster_enabled
}

output "aks_aad_rbac_enabled" {
  description = "Whether Azure AD RBAC is enabled"
  value       = var.enable_aad_rbac
}

output "aks_azure_rbac_enabled" {
  description = "Whether Azure RBAC is enabled"
  value       = var.enable_azure_rbac
}

output "aks_workload_identity_enabled" {
  description = "Whether workload identity is enabled"
  value       = var.enable_workload_identity
}

output "aks_key_vault_secrets_provider_enabled" {
  description = "Whether Key Vault secrets provider is enabled"
  value       = var.enable_key_vault_secrets_provider
}

output "aks_network_policy_enabled" {
  description = "Whether network policy is enabled"
  value       = var.enable_network_policy
}

output "aks_auto_scaling_enabled" {
  description = "Whether auto-scaling is enabled for the default node pool"
  value       = var.enable_auto_scaling
}

output "aks_auto_upgrade_enabled" {
  description = "Whether auto-upgrade is enabled"
  value       = var.enable_auto_upgrade
}

output "aks_azure_monitor_enabled" {
  description = "Whether Azure Monitor is enabled"
  value       = var.enable_azure_monitor
}

# Operational information
output "aks_sku_tier" {
  description = "The SKU tier of the AKS cluster"
  value       = azurerm_kubernetes_cluster.this.sku_tier
}

output "aks_api_server_authorized_ip_ranges" {
  description = "The authorized IP ranges for API server access"
  value       = azurerm_kubernetes_cluster.this.api_server_access_profile[0].authorized_ip_ranges
}

output "aks_upgrade_channel" {
  description = "The upgrade channel for the AKS cluster"
  value       = var.enable_auto_upgrade ? var.upgrade_channel : "none"
}

output "aks_maintenance_window_enabled" {
  description = "Whether maintenance window is enabled"
  value       = var.enable_maintenance_window
}

output "aks_http_proxy_enabled" {
  description = "Whether HTTP proxy is enabled"
  value       = var.enable_http_proxy
}

output "aks_ingress_application_gateway_enabled" {
  description = "Whether Application Gateway ingress is enabled"
  value       = var.enable_ingress_application_gateway
}

output "aks_service_mesh_enabled" {
  description = "Whether service mesh is enabled"
  value       = var.enable_service_mesh
}