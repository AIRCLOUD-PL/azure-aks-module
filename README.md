# Azure Kubernetes Service (AKS) Module - Enterprise Edition

[![CI/CD Pipeline](https://github.com/AIRCLOUD-PL/azure-aks-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-aks-module/actions/workflows/ci.yml)
[![Terraform Registry](https://img.shields.io/badge/terraform-registry-blue.svg)](https://registry.terraform.io/modules/AIRCLOUD-PL/aks/azurerm/latest)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Security](https://img.shields.io/badge/security-enabled-green.svg)](SECURITY.md)

This Terraform module creates an Azure Kubernetes Service (AKS) cluster with enterprise-grade security, networking, monitoring, compliance, and DevOps automation features. Designed for production workloads with comprehensive CI/CD, security scanning, and automated compliance validation.

## 🏆 Key Features

### 🚀 Core Features
- **Kubernetes Cluster**: Managed AKS cluster with configurable version and SKU tier
- **Private Clusters**: Optional private cluster deployment with authorized IP ranges
- **Managed Identity**: System-assigned or user-assigned managed identity support
- **Node Pools**: Configurable default and additional node pools with auto-scaling
- **Multi-region**: Geo-redundant deployments with Azure Front Door integration

### 🔒 Security & Compliance
- **Azure AD Integration**: RBAC integration with Azure AD and Azure RBAC
- **Workload Identity**: Enable workload identity for secure pod-to-resource access
- **OIDC Issuer**: OpenID Connect issuer for enhanced security
- **Key Vault Integration**: Secrets provider for Key Vault integration
- **Network Policies**: Azure network policies for pod-to-pod communication
- **Private Endpoints**: Private cluster access with private endpoints
- **CIS Benchmarks**: Automated CIS Kubernetes benchmark validation
- **Security Scanning**: Integrated Checkov, tfsec, and Trivy scanning

### 🌐 Networking & Connectivity
- **Azure CNI**: Advanced networking with Azure Container Networking Interface
- **Load Balancer**: Standard or basic load balancer configuration
- **API Server Access**: Configurable authorized IP ranges for API server
- **HTTP Proxy**: HTTP proxy configuration for outbound traffic
- **Ingress Gateway**: Application Gateway ingress controller integration
- **Service Mesh**: Istio service mesh integration (preview)
- **VPN Gateway**: Site-to-site VPN connectivity

### 📊 Monitoring & Observability
- **Azure Monitor**: Container insights and monitoring integration
- **Log Analytics**: Centralized logging with Log Analytics workspace
- **Diagnostic Settings**: Comprehensive diagnostic logging and metrics
- **Maintenance Windows**: Scheduled maintenance windows for cluster updates
- **Cost Monitoring**: Infracost integration for cost estimation
- **Performance Metrics**: Real-time performance monitoring and alerting

### 🤖 DevOps & Automation
- **CI/CD Pipeline**: GitHub Actions with matrix builds and automated testing
- **Automated Versioning**: Semantic versioning with automated releases
- **Dependency Updates**: Automated provider and action updates
- **Security Scanning**: Continuous security vulnerability scanning
- **Compliance Checks**: Automated policy validation with OPA Conftest
- **Infrastructure Testing**: Terratest integration for infrastructure validation

### 📋 Compliance & Governance
- **Azure Policy**: Policy assignments and initiatives for compliance
- **Resource Locks**: Prevent accidental deletion of critical resources
- **Auto-upgrade**: Automatic cluster and node pool upgrades
- **Backup & Recovery**: Automated backup strategies
- **Audit Logging**: Comprehensive audit trails and compliance reporting

## 📖 Usage

### Basic Example

```hcl
module "aks" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-aks-module.git?ref=v1.0.0"

  # Required
  resource_group_name = "rg-aks-prod"
  location           = "East US 2"
  location_short     = "eus2"
  environment        = "prod"
  project_name       = "ecommerce"

  # Optional - Networking
  enable_private_cluster = true
  vnet_subnet_id         = "/subscriptions/.../subnets/aks"

  # Optional - Security
  enable_aad_rbac        = true
  enable_workload_identity = true
  enable_key_vault_secrets_provider = true

  # Optional - Monitoring
  enable_azure_monitor = true
  log_analytics_workspace_id = "/subscriptions/.../workspaces/law"

  # Optional - Node Pools
  default_node_pool_vm_size = "Standard_D4s_v5"
  default_node_pool_node_count = 3
  enable_auto_scaling = true

  tags = {
    Environment = "prod"
    Project     = "ecommerce"
    Owner       = "platform-team"
  }
}
```

### Advanced Example with Custom Node Pools

```hcl
module "aks_advanced" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-aks-module.git?ref=v1.0.0"

  resource_group_name = "rg-aks-advanced"
  location           = "West Europe"
  location_short     = "weu"
  environment        = "prod"
  project_name       = "data-platform"

  # Private cluster with authorized IPs
  enable_private_cluster = true
  api_server_authorized_ip_ranges = ["10.0.0.0/8", "172.16.0.0/12"]

  # Azure AD and RBAC
  enable_aad_rbac = true
  aad_admin_group_object_ids = ["00000000-0000-0000-0000-000000000000"]

  # Workload identity and Key Vault
  enable_workload_identity = true
  enable_key_vault_secrets_provider = true

  # Network configuration
  enable_azure_cni = true
  network_policy   = "azure"

  # Monitoring and logging
  enable_azure_monitor = true
  enable_diagnostic_settings = true

  # Default node pool
  default_node_pool_vm_size = "Standard_D8s_v5"
  default_node_pool_node_count = 3
  enable_auto_scaling = true
  default_node_pool_min_count = 3
  default_node_pool_max_count = 10

  # Additional node pools
  additional_node_pools = {
    "system" = {
      name                = "system"
      vm_size            = "Standard_D4s_v5"
      node_count         = 2
      enable_auto_scaling = true
      min_count          = 2
      max_count          = 5
      node_labels = {
        "node-type" = "system"
      }
      node_taints = [
        "CriticalAddonsOnly=true:NoSchedule"
      ]
    }
    "user" = {
      name                = "user"
      vm_size            = "Standard_D16s_v5"
      node_count         = 1
      enable_auto_scaling = true
      min_count          = 1
      max_count          = 20
      node_labels = {
        "node-type" = "user"
        "workload"  = "batch"
      }
    }
  }

  # Maintenance windows
  enable_maintenance_window = true
  maintenance_window_allowed = [
    {
      day   = "Sunday"
      hours = [2, 3, 4, 5]
    }
  ]

  # Resource lock
  enable_resource_lock = true
  resource_lock_level  = "CanNotDelete"

  tags = {
    Environment   = "prod"
    Project       = "data-platform"
    Owner         = "data-team"
    CostCenter    = "data-eng"
    Compliance    = "pci-dss"
    Backup        = "daily"
  }
}
```

## 🔧 Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.80.0 |

## 📋 Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource names | `string` | `""` | no |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Custom name for the AKS cluster | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource names | `string` | `""` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for location | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name | `string` | n/a | yes |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Project name | `string` | n/a | yes |
| <a name="input_created_by"></a> [created\_by](#input\_created\_by) | Created by user | `string` | `"terraform"` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags | `map(string)` | `{}` | no |

## 📤 Outputs

| Name | Description |
|------|-------------|
| <a name="output_cluster_id"></a> [cluster\_id](#output\_cluster\_id) | AKS cluster ID |
| <a name="output_cluster_name"></a> [cluster\_name](#output\_cluster\_name) | AKS cluster name |
| <a name="output_kube_config"></a> [kube\_config](#output\_kube\_config) | Kubernetes configuration |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | Node resource group name |

## 🧪 Testing

This module includes comprehensive testing:

### Automated Testing
- **Unit Tests**: Terraform validation and linting
- **Integration Tests**: Terratest for infrastructure validation
- **Security Tests**: Checkov, tfsec, and Trivy scanning
- **Compliance Tests**: OPA Conftest policy validation

### Manual Testing

```bash
# Run tests
cd test
go test -v ./...

# Validate Terraform
terraform validate

# Format check
terraform fmt -check

# Security scan
checkov -f . --framework terraform
```

## 🔒 Security

This module implements multiple security layers:

### Infrastructure Security
- **Network Security**: Private clusters, network policies, and firewall rules
- **Identity Management**: Managed identity and Azure AD integration
- **Encryption**: At-rest and in-transit encryption
- **Access Control**: RBAC and least privilege principles

### DevSecOps
- **Security Scanning**: Automated vulnerability scanning in CI/CD
- **Policy as Code**: OPA policies for compliance validation
- **Secrets Management**: Secure handling of sensitive data
- **Audit Logging**: Comprehensive audit trails

See [SECURITY.md](SECURITY.md) for detailed security information.

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

### Development Setup

```bash
# Clone the repository
git clone https://github.com/AIRCLOUD-PL/azure-aks-module.git
cd azure-aks-module

# Install dependencies
terraform init

# Run tests
make test

# Format code
terraform fmt -recursive
```

## 📚 Documentation

- [Terraform Registry](https://registry.terraform.io/modules/AIRCLOUD-PL/aks/azurerm/latest)
- [Azure AKS Documentation](https://docs.microsoft.com/en-us/azure/aks/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest)

## 📄 License

This module is licensed under the MIT License. See [LICENSE](LICENSE) for details.

## 🆘 Support

- **Issues**: [GitHub Issues](https://github.com/AIRCLOUD-PL/azure-aks-module/issues)
- **Discussions**: [GitHub Discussions](https://github.com/AIRCLOUD-PL/azure-aks-module/discussions)
- **Security**: See [SECURITY.md](SECURITY.md) for security-related issues

## 🙏 Acknowledgments

- Azure Kubernetes Service team
- Terraform and AzureRM provider maintainers
- Open source security scanning tools community

## Usage

### Basic Example

```hcl
module "aks" {
  source = "./modules/compute/aks"

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
}
```

### Enterprise Example

```hcl
module "aks_enterprise" {
  source = "./modules/compute/aks"

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
    "00000000-0000-0000-0000-000000000000"
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

  # Auto-upgrade
  enable_auto_upgrade = true
  auto_upgrade_profile = {
    upgrade_channel = "stable"
  }

  # Azure Policy
  enable_policy_assignments = true
  enable_custom_policies = true
  enable_policy_initiative = true

  # Resource lock
  enable_resource_lock = true
  lock_level          = "CanNotDelete"
}
```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.80.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | >= 3.80.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_monitor_diagnostic_setting.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_resource_group_policy_assignment.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_remediation.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_remediation) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_location"></a> [location](#input\_location) | Azure region for resources | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for the location (e.g., 'eus' for East US) | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., 'dev', 'test', 'prod') | `string` | n/a | yes |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Custom name for the AKS cluster | `string` | n/a | yes |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | ID of the Virtual Network | `string` | n/a | yes |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | ID of the subnet for AKS nodes | `string` | n/a | yes |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the cluster | `string` | `"1.27.3"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the cluster (Free or Standard) | `string` | `"Free"` | no |
| <a name="input_enable_private_cluster"></a> [enable\_private\_cluster](#input\_enable\_private\_cluster) | Enable private cluster | `bool` | `false` | no |
| <a name="input_enable_api_server_authorized_ip_ranges"></a> [enable\_api\_server\_authorized\_ip\_ranges](#input\_enable\_api\_server\_authorized\_ip\_ranges) | Enable authorized IP ranges for API server | `bool` | `false` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | List of authorized IP ranges for API server access | `list(string)` | `[]` | no |
| <a name="input_enable_managed_identity"></a> [enable\_managed\_identity](#input\_enable\_managed\_identity) | Enable managed identity for the cluster | `bool` | `true` | no |
| <a name="input_user_assigned_identity_id"></a> [user\_assigned\_identity\_id](#input\_user\_assigned\_identity\_id) | ID of user-assigned managed identity | `string` | `null` | no |
| <a name="input_default_node_pool_vm_size"></a> [default\_node\_pool\_vm\_size](#input\_default\_node\_pool\_vm\_size) | VM size for default node pool | `string` | `"Standard_DS2_v2"` | no |
| <a name="input_default_node_pool_node_count"></a> [default\_node\_pool\_node\_count](#input\_default\_node\_pool\_node\_count) | Number of nodes in default node pool | `number` | `1` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable auto-scaling for default node pool | `bool` | `false` | no |
| <a name="input_default_node_pool_min_count"></a> [default\_node\_pool\_min\_count](#input\_default\_node\_pool\_min\_count) | Minimum node count for auto-scaling | `number` | `1` | no |
| <a name="input_default_node_pool_max_count"></a> [default\_node\_pool\_max\_count](#input\_default\_node\_pool\_max\_count) | Maximum node count for auto-scaling | `number` | `3` | no |
| <a name="input_default_node_pool_os_disk_size_gb"></a> [default\_node\_pool\_os\_disk\_size\_gb](#input\_default\_node\_pool\_os\_disk\_size\_gb) | OS disk size in GB for default node pool | `number` | `128` | no |
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | Map of additional node pools | `any` | `{}` | no |
| <a name="input_enable_azure_cni"></a> [enable\_azure\_cni](#input\_enable\_azure\_cni) | Enable Azure CNI networking | `bool` | `true` | no |
| <a name="input_enable_network_policy"></a> [enable\_network\_policy](#input\_enable\_network\_policy) | Enable network policy | `bool` | `false` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | Network policy to use (azure or calico) | `string` | `"azure"` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP address for DNS service | `string` | `"10.0.0.10"` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | CIDR for service IP addresses | `string` | `"10.0.0.0/16"` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | SKU for load balancer (basic or standard) | `string` | `"standard"` | no |
| <a name="input_enable_aad_rbac"></a> [enable\_aad\_rbac](#input\_enable\_aad\_rbac) | Enable Azure AD RBAC | `bool` | `false` | no |
| <a name="input_enable_azure_rbac"></a> [enable\_azure\_rbac](#input\_enable\_azure\_rbac) | Enable Azure RBAC | `bool` | `false` | no |
| <a name="input_aad_admin_group_object_ids"></a> [aad\_admin\_group\_object\_ids](#input\_aad\_admin\_group\_object\_ids) | Object IDs of AAD groups for cluster admin | `list(string)` | `[]` | no |
| <a name="input_enable_oidc_issuer"></a> [enable\_oidc\_issuer](#input\_enable\_oidc\_issuer) | Enable OIDC issuer | `bool` | `true` | no |
| <a name="input_enable_workload_identity"></a> [enable\_workload\_identity](#input\_enable\_workload\_identity) | Enable workload identity | `bool` | `true` | no |
| <a name="input_enable_key_vault_secrets_provider"></a> [enable\_key\_vault\_secrets\_provider](#input\_enable\_key\_vault\_secrets\_provider) | Enable Key Vault secrets provider | `bool` | `false` | no |
| <a name="input_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#input\_key\_vault\_secrets\_provider) | Configuration for Key Vault secrets provider | `any` | `{}` | no |
| <a name="input_key_vault_secrets_provider_key_vault_key_version"></a> [key\_vault\_secrets\_provider\_key\_vault\_key\_version](#input\_key\_vault\_secrets\_provider\_key\_vault\_key\_version) | Key version for Key Vault secrets provider | `string` | `null` | no |
| <a name="input_key_vault_secrets_provider_key_vault_secret_version"></a> [key\_vault\_secrets\_provider\_key\_vault\_secret\_version](#input\_key\_vault\_secrets\_provider\_key\_vault\_secret\_version) | Secret version for Key Vault secrets provider | `string` | `null` | no |
| <a name="input_enable_azure_monitor"></a> [enable\_azure\_monitor](#input\_enable\_azure\_monitor) | Enable Azure Monitor for containers | `bool` | `false` | no |
| <a name="input_enable_log_analytics"></a> [enable\_log\_analytics](#input\_enable\_log\_analytics) | Enable Log Analytics integration | `bool` | `false` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | ID of Log Analytics workspace | `string` | `null` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings | `bool` | `false` | no |
| <a name="input_diagnostic_settings"></a> [diagnostic\_settings](#input\_diagnostic\_settings) | Configuration for diagnostic settings | `any` | `{}` | no |
| <a name="input_enable_auto_upgrade"></a> [enable\_auto\_upgrade](#input\_enable\_auto\_upgrade) | Enable automatic upgrades | `bool` | `false` | no |
| <a name="input_auto_upgrade_profile"></a> [auto\_upgrade\_profile](#input\_auto\_upgrade\_profile) | Configuration for auto-upgrade profile | `any` | `{}` | no |
| <a name="input_enable_maintenance_window"></a> [enable\_maintenance\_window](#input\_enable\_maintenance\_window) | Enable maintenance window | `bool` | `false` | no |
| <a name="input_maintenance_window"></a> [maintenance\_window](#input\_maintenance\_window) | Configuration for maintenance window | `any` | `{}` | no |
| <a name="input_enable_http_proxy"></a> [enable\_http\_proxy](#input\_enable\_http\_proxy) | Enable HTTP proxy | `bool` | `false` | no |
| <a name="input_http_proxy_config"></a> [http\_proxy\_config](#input\_http\_proxy\_config) | Configuration for HTTP proxy | `any` | `{}` | no |
| <a name="input_enable_ingress_application_gateway"></a> [enable\_ingress\_application\_gateway](#input\_enable\_ingress\_application\_gateway) | Enable Application Gateway ingress | `bool` | `false` | no |
| <a name="input_ingress_application_gateway"></a> [ingress\_application\_gateway](#input\_ingress\_application\_gateway) | Configuration for Application Gateway ingress | `any` | `{}` | no |
| <a name="input_enable_service_mesh"></a> [enable\_service\_mesh](#input\_enable\_service\_mesh) | Enable service mesh | `bool` | `false` | no |
| <a name="input_service_mesh_profile"></a> [service\_mesh\_profile](#input\_service\_mesh\_profile) | Configuration for service mesh profile | `any` | `{}` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments | `bool` | `false` | no |
| <a name="input_enable_custom_policies"></a> [enable\_custom\_policies](#input\_enable\_custom\_policies) | Enable custom policy assignments | `bool` | `false` | no |
| <a name="input_enable_policy_initiative"></a> [enable\_policy\_initiative](#input\_enable\_policy\_initiative) | Enable policy initiative assignment | `bool` | `false` | no |
| <a name="input_policy_initiative_id"></a> [policy\_initiative\_id](#input\_policy\_initiative\_id) | ID of the policy initiative to assign | `string` | `null` | no |
| <a name="input_enable_resource_lock"></a> [enable\_resource\_lock](#input\_enable\_resource\_lock) | Enable resource lock | `bool` | `false` | no |
| <a name="input_lock_level"></a> [lock\_level](#input\_lock\_level) | Level of resource lock (CanNotDelete or ReadOnly) | `string` | `"CanNotDelete"` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | Additional tags for resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_cluster_id"></a> [aks\_cluster\_id](#output\_aks\_cluster\_id) | ID of the AKS cluster |
| <a name="output_aks_cluster_name"></a> [aks\_cluster\_name](#output\_aks\_cluster\_name) | Name of the AKS cluster |
| <a name="output_aks_kube_config_raw"></a> [aks\_kube\_config\_raw](#output\_aks\_kube\_config\_raw) | Raw Kubernetes configuration |
| <a name="output_aks_oidc_issuer_url"></a> [aks\_oidc\_issuer\_url](#output\_aks\_oidc\_issuer\_url) | OIDC issuer URL |
| <a name="output_aks_identity"></a> [aks\_identity](#output\_aks\_identity) | Identity configuration of the AKS cluster |
| <a name="output_aks_network_profile"></a> [aks\_network\_profile](#output\_aks\_network\_profile) | Network profile of the AKS cluster |
| <a name="output_aks_default_node_pool"></a> [aks\_default\_node\_pool](#output\_aks\_default\_node\_pool) | Default node pool configuration |
| <a name="output_aks_additional_node_pools"></a> [aks\_additional\_node\_pools](#output\_aks\_additional\_node\_pools) | Additional node pools configuration |
| <a name="output_aks_workload_identity_enabled"></a> [aks\_workload\_identity\_enabled](#output\_aks\_workload\_identity\_enabled) | Whether workload identity is enabled |
| <a name="output_aks_private_cluster_enabled"></a> [aks\_private\_cluster\_enabled](#output\_aks\_private\_cluster\_enabled) | Whether private cluster is enabled |
| <a name="output_aks_aad_rbac_enabled"></a> [aks\_aad\_rbac\_enabled](#output\_aks\_aad\_rbac\_enabled) | Whether AAD RBAC is enabled |
| <a name="output_aks_azure_rbac_enabled"></a> [aks\_azure\_rbac\_enabled](#output\_aks\_azure\_rbac\_enabled) | Whether Azure RBAC is enabled |
| <a name="output_aks_key_vault_secrets_provider_enabled"></a> [aks\_key\_vault\_secrets\_provider\_enabled](#output\_aks\_key\_vault\_secrets\_provider\_enabled) | Whether Key Vault secrets provider is enabled |
| <a name="output_aks_azure_monitor_enabled"></a> [aks\_azure\_monitor\_enabled](#output\_aks\_azure\_monitor\_enabled) | Whether Azure Monitor is enabled |
| <a name="output_aks_auto_upgrade_enabled"></a> [aks\_auto\_upgrade\_enabled](#output\_aks\_auto\_upgrade\_enabled) | Whether auto-upgrade is enabled |
| <a name="output_aks_maintenance_window_enabled"></a> [aks\_maintenance\_window\_enabled](#output\_aks\_maintenance\_window\_enabled) | Whether maintenance window is enabled |
| <a name="output_aks_http_proxy_enabled"></a> [aks\_http\_proxy\_enabled](#output\_aks\_http\_proxy\_enabled) | Whether HTTP proxy is enabled |
| <a name="output_aks_ingress_application_gateway_enabled"></a> [aks\_ingress\_application\_gateway\_enabled](#output\_aks\_ingress\_application\_gateway\_enabled) | Whether Application Gateway ingress is enabled |
| <a name="output_aks_service_mesh_enabled"></a> [aks\_service\_mesh\_enabled](#output\_aks\_service\_mesh\_enabled) | Whether service mesh is enabled |
| <a name="output_aks_policy_assignments_enabled"></a> [aks\_policy\_assignments\_enabled](#output\_aks\_policy\_assignments\_enabled) | Whether policy assignments are enabled |
| <a name="output_aks_resource_lock_enabled"></a> [aks\_resource\_lock\_enabled](#output\_aks\_resource\_lock\_enabled) | Whether resource lock is enabled |
| <a name="output_aks_resource_group_name"></a> [aks\_resource\_group\_name](#output\_aks\_resource\_group\_name) | Resource group name |
| <a name="output_aks_location"></a> [aks\_location](#output\_aks\_location) | Azure region |
| <a name="output_aks_tags"></a> [aks\_tags](#output\_aks\_tags) | Tags applied to resources |

## Testing

The module includes comprehensive Terratest suites for validation:

```bash
# Run all tests
cd test
go test -v

# Run specific test
go test -v -run TestAKSEnterprise

# Run with verbose output
go test -v -timeout 30m
```

## Security Considerations

- **Private Clusters**: Use private clusters for production workloads to restrict API server access
- **Network Policies**: Enable network policies to control pod-to-pod communication
- **Azure AD RBAC**: Use Azure AD integration for identity management
- **Workload Identity**: Enable workload identity for secure access to Azure resources
- **Azure Policy**: Apply security policies for compliance
- **Resource Locks**: Use resource locks to prevent accidental deletion

## Cost Optimization

- **SKU Tier**: Use Free tier for development, Standard for production
- **Auto-scaling**: Enable auto-scaling to optimize node usage
- **Spot Instances**: Consider spot instances for non-critical workloads
- **Maintenance Windows**: Schedule maintenance during off-peak hours

## Troubleshooting

### Common Issues

1. **Network Configuration**: Ensure subnet has sufficient IP addresses for nodes and pods
2. **Identity Permissions**: Verify managed identity has required permissions
3. **Azure Policy**: Check policy compliance before deployment
4. **Resource Quotas**: Verify Azure subscription has sufficient quotas

### Logs and Diagnostics

- Enable diagnostic settings for comprehensive logging
- Use Azure Monitor for container insights
- Check Kubernetes logs using kubectl
- Review Azure activity logs for deployment issues

## Contributing

1. Follow the existing code style and patterns
2. Add comprehensive tests for new features
3. Update documentation for any changes
4. Ensure backward compatibility

## License

This module is licensed under the MIT License.
## Requirements

No requirements.

## Providers

No providers.

## Modules

No modules.

## Resources

No resources.

## Inputs

No inputs.

## Outputs

No outputs.

<!-- BEGIN_TF_DOCS -->
<!-- END_TF_DOCS -->
