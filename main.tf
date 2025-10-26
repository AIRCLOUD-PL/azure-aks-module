# Azure Kubernetes Service (AKS) Module - Enterprise Edition
# This module creates a comprehensive AKS cluster with advanced security and operational features

locals {
  # Naming convention following Microsoft CAF
  name_prefix = var.name_prefix != "" ? var.name_prefix : "aks-${var.environment}-${var.location_short}"
  aks_name    = var.custom_name != "" ? var.custom_name : "${local.name_prefix}${var.name_suffix}"

  # Default tags
  default_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Module      = "aks"
    CreatedDate = formatdate("YYYY-MM-DD", timestamp())
    CreatedBy   = var.created_by
  }

  # Merge tags
  tags = merge(local.default_tags, var.additional_tags)

  # Network configuration
  network_plugin = var.enable_azure_cni ? "azure" : "kubenet"
  network_policy = var.enable_network_policy ? (var.enable_azure_cni ? "azure" : "calico") : null

  # API server authorized IP ranges
  api_server_authorized_ip_ranges = var.enable_api_server_authorized_ip_ranges ? var.api_server_authorized_ip_ranges : null

  # Node pools configuration
  default_node_pool = {
    name                = var.default_node_pool_name
    vm_size             = var.default_node_pool_vm_size
    node_count          = var.default_node_pool_node_count
    min_count           = var.enable_auto_scaling ? var.default_node_pool_min_count : null
    max_count           = var.enable_auto_scaling ? var.default_node_pool_max_count : null
    enable_auto_scaling = var.enable_auto_scaling
    os_disk_size_gb     = var.default_node_pool_os_disk_size_gb
    os_disk_type        = var.default_node_pool_os_disk_type
    vnet_subnet_id      = var.vnet_subnet_id
    max_pods            = var.default_node_pool_max_pods
    node_labels         = var.default_node_pool_labels
    node_taints         = var.default_node_pool_taints
    tags                = local.tags
  }

  # Additional node pools
  additional_node_pools = {
    for k, v in var.additional_node_pools : k => merge(v, {
      vnet_subnet_id = v.vnet_subnet_id != null ? v.vnet_subnet_id : var.vnet_subnet_id
      tags           = merge(local.tags, v.tags)
    })
  }

  # Identity configuration
  identity_type = var.enable_managed_identity ? "SystemAssigned" : "UserAssigned"
  identity_ids  = var.enable_managed_identity ? null : [azurerm_user_assigned_identity.aks[0].id]
}

# Data sources
data "azurerm_client_config" "current" {}

# User Assigned Identity (when not using system-assigned)
resource "azurerm_user_assigned_identity" "aks" {
  count = var.enable_managed_identity ? 0 : 1

  name                = "${local.aks_name}-identity"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = local.tags
}

# Role assignment for user-assigned identity
resource "azurerm_role_assignment" "aks_identity_network_contributor" {
  count = var.enable_managed_identity ? 0 : 1

  scope                = var.vnet_id
  role_definition_name = "Network Contributor"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}

resource "azurerm_role_assignment" "aks_identity_managed_identity_operator" {
  count = var.enable_managed_identity ? 0 : 1

  scope                = azurerm_user_assigned_identity.aks[0].id
  role_definition_name = "Managed Identity Operator"
  principal_id         = azurerm_user_assigned_identity.aks[0].principal_id
}

# AKS Cluster
resource "azurerm_kubernetes_cluster" "this" {
  name                    = local.aks_name
  location                = var.location
  resource_group_name     = var.resource_group_name
  dns_prefix              = var.dns_prefix != "" ? var.dns_prefix : local.aks_name
  kubernetes_version      = var.kubernetes_version
  node_resource_group     = var.node_resource_group != "" ? var.node_resource_group : "${var.resource_group_name}-aks-nodes"
  sku_tier                = var.sku_tier
  private_cluster_enabled = var.enable_private_cluster

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [1] : []
    content {
      type = local.identity_type
    }
  }

  dynamic "identity" {
    for_each = var.enable_managed_identity ? [] : [1]
    content {
      type         = local.identity_type
      identity_ids = local.identity_ids
    }
  }

  # Default node pool
  default_node_pool {
    name            = local.default_node_pool.name
    vm_size         = local.default_node_pool.vm_size
    node_count      = local.default_node_pool.enable_auto_scaling ? null : local.default_node_pool.node_count
    min_count       = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.min_count : null
    max_count       = local.default_node_pool.enable_auto_scaling ? local.default_node_pool.max_count : null
    auto_scaling_enabled = local.default_node_pool.enable_auto_scaling
    os_disk_size_gb = local.default_node_pool.os_disk_size_gb
    os_disk_type    = local.default_node_pool.os_disk_type
    vnet_subnet_id  = local.default_node_pool.vnet_subnet_id
    max_pods        = local.default_node_pool.max_pods
    node_labels     = local.default_node_pool.node_labels
    tags            = local.default_node_pool.tags

    dynamic "upgrade_settings" {
      for_each = var.enable_auto_upgrade ? [1] : []
      content {
        max_surge = var.upgrade_max_surge
      }
    }
  }

  # Network profile
  network_profile {
    network_plugin    = local.network_plugin
    network_policy    = local.network_policy
    dns_service_ip    = var.dns_service_ip
    service_cidr      = var.service_cidr
    load_balancer_sku = var.load_balancer_sku

    dynamic "load_balancer_profile" {
      for_each = var.enable_load_balancer_profile ? [1] : []
      content {
        managed_outbound_ip_count = var.managed_outbound_ip_count
        outbound_ip_prefix_ids    = var.outbound_ip_prefix_ids
        outbound_ip_address_ids   = var.outbound_ip_address_ids
      }
    }
  }

  # API server access profile
  dynamic "api_server_access_profile" {
    for_each = var.enable_private_cluster || var.enable_api_server_authorized_ip_ranges ? [1] : []
    content {
      authorized_ip_ranges = local.api_server_authorized_ip_ranges
      subnet_id           = var.api_server_subnet_id
    }
  }

  # Azure AD integration
  dynamic "azure_active_directory_role_based_access_control" {
    for_each = var.enable_aad_rbac ? [1] : []
    content {
      tenant_id              = data.azurerm_client_config.current.tenant_id
      admin_group_object_ids = var.aad_admin_group_object_ids
      azure_rbac_enabled     = var.enable_azure_rbac
    }
  }

  # Key Vault integration
  dynamic "key_vault_secrets_provider" {
    for_each = var.enable_key_vault_secrets_provider ? [1] : []
    content {
      secret_rotation_enabled  = var.key_vault_secret_rotation_enabled
      secret_rotation_interval = var.key_vault_secret_rotation_interval
    }
  }

  # OIDC issuer
  oidc_issuer_enabled = var.enable_oidc_issuer

  # Workload identity
  workload_identity_enabled = var.enable_workload_identity

  # Auto upgrade - handled through Azure Policy

  # Azure Monitor (Container Insights)
  dynamic "oms_agent" {
    for_each = var.enable_azure_monitor ? [1] : []
    content {
      log_analytics_workspace_id      = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.this[0].id
      msi_auth_for_monitoring_enabled = true
    }
  }

  # Maintenance window
  dynamic "maintenance_window" {
    for_each = var.enable_maintenance_window ? [1] : []
    content {
      dynamic "allowed" {
        for_each = var.maintenance_window_allowed
        content {
          day   = allowed.value.day
          hours = allowed.value.hours
        }
      }
      dynamic "not_allowed" {
        for_each = var.maintenance_window_not_allowed
        content {
          end   = not_allowed.value.end
          start = not_allowed.value.start
        }
      }
    }
  }

  # HTTP proxy configuration
  dynamic "http_proxy_config" {
    for_each = var.enable_http_proxy ? [1] : []
    content {
      http_proxy  = var.http_proxy_url
      https_proxy = var.https_proxy_url
      no_proxy    = var.no_proxy_list
      trusted_ca  = var.http_proxy_trusted_ca
    }
  }

  # Ingress application gateway
  dynamic "ingress_application_gateway" {
    for_each = var.enable_ingress_application_gateway ? [1] : []
    content {
      gateway_id   = var.ingress_application_gateway_id
      gateway_name = var.ingress_application_gateway_name
      subnet_cidr  = var.ingress_application_gateway_subnet_cidr
      subnet_id    = var.ingress_application_gateway_subnet_id
    }
  }

  # Service mesh profile
  dynamic "service_mesh_profile" {
    for_each = var.enable_service_mesh ? [1] : []
    content {
      mode      = var.service_mesh_mode
      revisions = "r1"
    }
  }

  tags = local.tags

  lifecycle {
    ignore_changes = [
      kubernetes_version,
      default_node_pool[0].node_count,
    ]
  }
}

# Additional Node Pools
resource "azurerm_kubernetes_cluster_node_pool" "additional" {
  for_each = local.additional_node_pools

  name                  = each.value.name
  kubernetes_cluster_id = azurerm_kubernetes_cluster.this.id
  vm_size               = each.value.vm_size
  node_count            = each.value.enable_auto_scaling ? null : each.value.node_count
  min_count             = each.value.enable_auto_scaling ? each.value.min_count : null
  max_count             = each.value.enable_auto_scaling ? each.value.max_count : null
  auto_scaling_enabled  = each.value.enable_auto_scaling
  os_disk_size_gb       = each.value.os_disk_size_gb
  os_disk_type          = each.value.os_disk_type
  vnet_subnet_id        = each.value.vnet_subnet_id
  max_pods              = each.value.max_pods
  node_labels           = each.value.node_labels
  tags                  = each.value.tags

  dynamic "upgrade_settings" {
    for_each = var.enable_auto_upgrade ? [1] : []
    content {
      max_surge = var.upgrade_max_surge
    }
  }
}

# Log Analytics Workspace (if not provided)
resource "azurerm_log_analytics_workspace" "this" {
  count = var.log_analytics_workspace_id == null && var.enable_log_analytics ? 1 : 0

  name                = "${local.aks_name}-logs"
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.log_analytics_sku
  retention_in_days   = var.log_analytics_retention_days
  tags                = local.tags
}

# Azure Monitor Container Insights
resource "azurerm_monitor_diagnostic_setting" "aks" {
  count = var.enable_diagnostic_settings ? 1 : 0

  name                       = "${local.aks_name}-diagnostics"
  target_resource_id         = azurerm_kubernetes_cluster.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id != null ? var.log_analytics_workspace_id : azurerm_log_analytics_workspace.this[0].id

  dynamic "enabled_log" {
    for_each = var.diagnostic_logs
    content {
      category = enabled_log.value
    }
  }

  dynamic "metric" {
    for_each = var.diagnostic_metrics
    content {
      category = metric.value
      enabled  = true
    }
  }
}

# Azure Policy for AKS
resource "azurerm_resource_group_policy_assignment" "aks_security" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-security-policy"
  resource_group_id    = var.resource_group_id
  policy_definition_id = "/providers/Microsoft.Authorization/policyDefinitions/04c371c1-7c80-4b5c-94cb-fc21baee2b7e" # AKS Encryption At Host

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

# Resource Lock
resource "azurerm_management_lock" "this" {
  count = var.enable_resource_lock ? 1 : 0

  name       = "${local.aks_name}-lock"
  scope      = azurerm_kubernetes_cluster.this.id
  lock_level = var.resource_lock_level
  notes      = "AKS cluster resource lock to prevent accidental deletion"
}