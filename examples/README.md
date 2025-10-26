# AKS Module Examples

This directory contains examples demonstrating how to use the AKS module with various configurations.

## Examples

### Basic AKS Cluster

```hcl
module "aks" {
  source = "../../"

  resource_group_name = "rg-aks-basic"
  location            = "East US"
  location_short      = "eus"
  environment         = "dev"
  custom_name         = "aks-basic"

  # VNet configuration
  vnet_id        = azurerm_virtual_network.example.id
  vnet_subnet_id = azurerm_subnet.aks.id

  # Cluster configuration
  kubernetes_version = "1.27.3"
  sku_tier          = "Free"

  # Identity
  enable_managed_identity = true

  # Default node pool
  default_node_pool_vm_size     = "Standard_DS2_v2"
  default_node_pool_node_count  = 2
  enable_auto_scaling          = false
  default_node_pool_os_disk_size_gb = 128

  # Network
  enable_azure_cni     = true
  enable_network_policy = false
  dns_service_ip       = "10.0.0.10"
  service_cidr         = "10.0.0.0/16"
  load_balancer_sku    = "standard"

  # Security features
  enable_oidc_issuer          = true
  enable_workload_identity    = true

  # Monitoring
  enable_azure_monitor = false
  enable_log_analytics = false

  # Disable enterprise features for basic example
  enable_private_cluster = false
  enable_aad_rbac        = false
  enable_azure_rbac      = false
  enable_key_vault_secrets_provider = false
  enable_diagnostic_settings = false
  enable_auto_upgrade = false
  enable_maintenance_window = false
  enable_http_proxy = false
  enable_ingress_application_gateway = false
  enable_service_mesh = false
  enable_policy_assignments = false
  enable_custom_policies = false
  enable_policy_initiative = false
  enable_resource_lock = false
}
```

### Enterprise AKS Cluster with Private Networking

```hcl
module "aks_enterprise" {
  source = "../../"

  resource_group_name = "rg-aks-enterprise"
  location            = "East US"
  location_short      = "eus"
  environment         = "prod"
  custom_name         = "aks-enterprise"

  # VNet configuration
  vnet_id        = azurerm_virtual_network.example.id
  vnet_subnet_id = azurerm_subnet.aks.id

  # Cluster configuration
  kubernetes_version = "1.27.3"
  sku_tier          = "Standard"

  # Private cluster
  enable_private_cluster = true
  enable_api_server_authorized_ip_ranges = true
  api_server_authorized_ip_ranges = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
  ]

  # Identity
  enable_managed_identity = true

  # Default node pool with auto-scaling
  default_node_pool_vm_size     = "Standard_DS3_v2"
  default_node_pool_node_count  = 3
  enable_auto_scaling          = true
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 10
  default_node_pool_os_disk_size_gb = 128

  # Additional node pools
  additional_node_pools = {
    "user-pool" = {
      name                = "user-pool"
      vm_size            = "Standard_DS4_v2"
      node_count         = 2
      enable_auto_scaling = true
      min_count          = 1
      max_count          = 5
      os_disk_size_gb    = 128
      node_labels = {
        "workload" = "user-apps"
      }
      tags = {
        "Purpose" = "User Applications"
      }
    }
    "system-pool" = {
      name                = "system-pool"
      vm_size            = "Standard_DS2_v2"
      node_count         = 2
      enable_auto_scaling = true
      min_count          = 1
      max_count          = 3
      os_disk_size_gb    = 128
      node_labels = {
        "workload" = "system"
      }
      node_taints = [
        "CriticalAddonsOnly=true:NoSchedule"
      ]
    }
  }

  # Network
  enable_azure_cni     = true
  enable_network_policy = true
  network_policy       = "azure"
  dns_service_ip       = "10.0.0.10"
  service_cidr         = "10.0.0.0/16"
  load_balancer_sku    = "standard"

  # Azure AD integration
  enable_aad_rbac = true
  enable_azure_rbac = true
  aad_admin_group_object_ids = [
    "00000000-0000-0000-0000-000000000000"  # Replace with actual AAD group ID
  ]

  # Security features
  enable_oidc_issuer          = true
  enable_workload_identity    = true
  enable_key_vault_secrets_provider = true
  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Monitoring
  enable_azure_monitor = true
  enable_log_analytics = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
  enable_diagnostic_settings = true
  diagnostic_settings = {
    logs = [
      {
        category = "kube-apiserver"
        enabled  = true
      },
      {
        category = "kube-controller-manager"
        enabled  = true
      },
      {
        category = "kube-scheduler"
        enabled  = true
      }
    ]
    metrics = [
      {
        category = "AllMetrics"
        enabled  = true
      }
    ]
  }

  # Auto-upgrade
  enable_auto_upgrade = true
  auto_upgrade_profile = {
    upgrade_channel = "stable"
  }

  # Maintenance window
  enable_maintenance_window = true
  maintenance_window = {
    allowed = [
      {
        day   = "Sunday"
        hours = [1, 2, 3, 4, 5]
      }
    ]
    not_allowed = []
  }

  # HTTP proxy
  enable_http_proxy = true
  http_proxy_config = {
    http_proxy  = "http://proxy.example.com:8080"
    https_proxy = "http://proxy.example.com:8080"
    no_proxy    = "localhost,127.0.0.1,.local,.internal"
    trusted_ca  = "LS0tLS1CRUdJTi..."  # Base64 encoded CA certificate
  }

  # Ingress Application Gateway
  enable_ingress_application_gateway = true
  ingress_application_gateway = {
    gateway_id   = azurerm_application_gateway.example.id
    gateway_name = azurerm_application_gateway.example.name
    subnet_cidr  = "10.0.1.0/24"
  }

  # Service Mesh
  enable_service_mesh = true
  service_mesh_profile = {
    mode = "Istio"
    external_ingress_gateway_enabled = true
    internal_ingress_gateway_enabled = true
  }

  # Azure Policy
  enable_policy_assignments = true
  enable_custom_policies = true
  enable_policy_initiative = true
  policy_initiative_id = "/providers/Microsoft.Authorization/policySetDefinitions/1f3afdf9-d0c9-4c3d-847f-89da613e70a8"  # Kubernetes security baseline

  # Resource lock
  enable_resource_lock = true
  lock_level          = "CanNotDelete"
}
```

### AKS with Key Vault Integration

```hcl
module "aks_with_kv" {
  source = "../../"

  resource_group_name = "rg-aks-kv"
  location            = "East US"
  location_short      = "eus"
  environment         = "prod"
  custom_name         = "aks-kv"

  # VNet configuration
  vnet_id        = azurerm_virtual_network.example.id
  vnet_subnet_id = azurerm_subnet.aks.id

  # Cluster configuration
  kubernetes_version = "1.27.3"
  sku_tier          = "Standard"

  # Private cluster
  enable_private_cluster = true

  # Identity
  enable_managed_identity = true

  # Default node pool
  default_node_pool_vm_size     = "Standard_DS3_v2"
  default_node_pool_node_count  = 3
  enable_auto_scaling          = true
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 10

  # Network
  enable_azure_cni     = true
  enable_network_policy = true
  network_policy       = "azure"

  # Security features
  enable_oidc_issuer          = true
  enable_workload_identity    = true
  enable_key_vault_secrets_provider = true
  key_vault_secrets_provider = {
    secret_rotation_enabled  = true
    secret_rotation_interval = "2m"
  }

  # Key Vault references
  key_vault_secrets_provider_key_vault_key_version = "7c12f4b3-5c8d-4e9f-a1b2-c3d4e5f6g7h8"
  key_vault_secrets_provider_key_vault_secret_version = "1a2b3c4d-5e6f-7g8h-9i0j-1k2l3m4n5o6p"

  # Monitoring
  enable_azure_monitor = true
  enable_log_analytics = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Azure Policy
  enable_policy_assignments = true
}
```

### AKS with Service Mesh and Ingress Gateway

```hcl
module "aks_mesh" {
  source = "../../"

  resource_group_name = "rg-aks-mesh"
  location            = "East US"
  location_short      = "eus"
  environment         = "prod"
  custom_name         = "aks-mesh"

  # VNet configuration
  vnet_id        = azurerm_virtual_network.example.id
  vnet_subnet_id = azurerm_subnet.aks.id

  # Cluster configuration
  kubernetes_version = "1.27.3"
  sku_tier          = "Standard"

  # Private cluster
  enable_private_cluster = true

  # Identity
  enable_managed_identity = true

  # Default node pool
  default_node_pool_vm_size     = "Standard_DS3_v2"
  default_node_pool_node_count  = 3
  enable_auto_scaling          = true
  default_node_pool_min_count  = 1
  default_node_pool_max_count  = 10

  # Network
  enable_azure_cni     = true
  enable_network_policy = true
  network_policy       = "azure"

  # Security features
  enable_oidc_issuer          = true
  enable_workload_identity    = true

  # Service Mesh
  enable_service_mesh = true
  service_mesh_profile = {
    mode = "Istio"
    external_ingress_gateway_enabled = true
    internal_ingress_gateway_enabled = true
  }

  # Ingress Application Gateway
  enable_ingress_application_gateway = true
  ingress_application_gateway = {
    gateway_id   = azurerm_application_gateway.example.id
    gateway_name = azurerm_application_gateway.example.name
    subnet_cidr  = "10.0.1.0/24"
  }

  # Monitoring
  enable_azure_monitor = true
  enable_log_analytics = true
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id

  # Azure Policy
  enable_policy_assignments = true
}
```

## Required Resources

Before using these examples, ensure you have the following resources created:

### Virtual Network and Subnet

```hcl
resource "azurerm_resource_group" "example" {
  name     = "rg-network"
  location = "East US"
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "snet-aks"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/24"]
}
```

### Log Analytics Workspace (for monitoring)

```hcl
resource "azurerm_log_analytics_workspace" "example" {
  name                = "log-aks-monitoring"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}
```

### Application Gateway (for ingress)

```hcl
resource "azurerm_subnet" "appgw" {
  name                 = "snet-appgw"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_application_gateway" "example" {
  name                = "agw-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gateway-ip-config"
    subnet_id = azurerm_subnet.appgw.id
  }

  frontend_port {
    name = "http"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "frontend-ip-config"
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name = "backend-pool"
  }

  backend_http_settings {
    name                  = "http-settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http-listener"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name             = "http"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "routing-rule"
    rule_type                  = "Basic"
    http_listener_name         = "http-listener"
    backend_address_pool_name  = "backend-pool"
    backend_http_settings_name = "http-settings"
  }
}
```

## Notes

- All examples assume you have the necessary Azure permissions and provider configuration
- Private clusters require additional networking setup for access
- Azure AD integration requires AAD admin group configuration
- Key Vault integration requires Key Vault with appropriate permissions
- Service mesh features are in preview and may have limitations
- Always test configurations in non-production environments first