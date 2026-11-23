<p align="center">
  <a href="https://aircloud.com.pl"><img src=".github/assets/banner.png" alt="AIRCLOUD: DevOps, cloud and AI engineering" width="100%"></a>
</p>

# azure-aks-module

**Azure Kubernetes Service (AKS) Terraform module — parameterised, azurerm 4.x, CI-validated.**

[![CI](https://github.com/AIRCLOUD-PL/azure-aks-module/actions/workflows/ci.yml/badge.svg)](https://github.com/AIRCLOUD-PL/azure-aks-module/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Release](https://img.shields.io/github/v/release/AIRCLOUD-PL/azure-aks-module?sort=semver)](https://github.com/AIRCLOUD-PL/azure-aks-module/releases)

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

Pin the module to a release tag:

```hcl
module "aks" {
  source = "git::https://github.com/AIRCLOUD-PL/azure-aks-module.git?ref=v1.0.0"

  # required inputs
  environment         = "..."
  location            = "..."
  location_short      = "..."
  resource_group_name = "..."
  vnet_id             = "..."
  vnet_subnet_id      = "..."
}
```

All inputs and outputs are listed in the generated reference below ([Inputs](#inputs), [Outputs](#outputs)). Worked examples live in [`examples/`](examples/).

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
  source = "git::https://github.com/AIRCLOUD-PL/azure-aks-module.git?ref=v1.0.0"

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
  source = "git::https://github.com/AIRCLOUD-PL/azure-aks-module.git?ref=v1.0.0"

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

## Reference

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.5.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | ~> 4.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 4.81.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [azurerm_kubernetes_cluster.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster) | resource |
| [azurerm_kubernetes_cluster_node_pool.additional](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster_node_pool) | resource |
| [azurerm_log_analytics_workspace.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/log_analytics_workspace) | resource |
| [azurerm_management_lock.this](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/management_lock) | resource |
| [azurerm_monitor_diagnostic_setting.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/monitor_diagnostic_setting) | resource |
| [azurerm_policy_definition.aks_image_pull_secrets](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.aks_pod_security_standards](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_definition.aks_resource_limits](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_definition) | resource |
| [azurerm_policy_set_definition.aks_security_initiative](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/policy_set_definition) | resource |
| [azurerm_resource_group_policy_assignment.aks_authorized_ip_ranges](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_auto_upgrade](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_azure_cni_networking](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_encryption_at_host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_https_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_microsoft_defender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_network_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_os_and_data_disks_encrypted](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_private_clusters](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_security](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_resource_group_policy_assignment.aks_security_initiative](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group_policy_assignment) | resource |
| [azurerm_role_assignment.aks_identity_managed_identity_operator](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_role_assignment.aks_identity_network_contributor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_user_assigned_identity.aks](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |
| [azurerm_policy_definition.aks_authorized_ip_ranges](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_auto_upgrade](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_azure_cni_networking](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_azure_monitor](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_encryption_at_host](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_https_only](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_microsoft_defender](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_network_policy](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_os_and_data_disks_encrypted](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |
| [azurerm_policy_definition.aks_private_clusters](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/policy_definition) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aad_admin_group_object_ids"></a> [aad\_admin\_group\_object\_ids](#input\_aad\_admin\_group\_object\_ids) | List of Azure AD group object IDs for cluster admins | `list(string)` | `[]` | no |
| <a name="input_additional_node_pools"></a> [additional\_node\_pools](#input\_additional\_node\_pools) | Map of additional node pools to create | <pre>map(object({<br/>    name                = string<br/>    vm_size             = string<br/>    node_count          = number<br/>    min_count           = optional(number, 1)<br/>    max_count           = optional(number, 10)<br/>    enable_auto_scaling = optional(bool, true)<br/>    os_disk_size_gb     = optional(number, 128)<br/>    os_disk_type        = optional(string, "Managed")<br/>    vnet_subnet_id      = optional(string)<br/>    max_pods            = optional(number, 110)<br/>    node_labels         = optional(map(string), {})<br/>    node_taints         = optional(list(string), [])<br/>    tags                = optional(map(string), {})<br/>  }))</pre> | `{}` | no |
| <a name="input_additional_tags"></a> [additional\_tags](#input\_additional\_tags) | Additional tags to add to resources | `map(string)` | `{}` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | List of authorized IP ranges for API server | `list(string)` | `[]` | no |
| <a name="input_api_server_subnet_id"></a> [api\_server\_subnet\_id](#input\_api\_server\_subnet\_id) | Subnet ID for API server VNet integration | `string` | `null` | no |
| <a name="input_created_by"></a> [created\_by](#input\_created\_by) | Identifier of who created this resource | `string` | `"terraform"` | no |
| <a name="input_custom_name"></a> [custom\_name](#input\_custom\_name) | Custom name for the AKS cluster. If provided, name\_prefix and name\_suffix are ignored | `string` | `""` | no |
| <a name="input_default_node_pool_labels"></a> [default\_node\_pool\_labels](#input\_default\_node\_pool\_labels) | Labels for the default node pool | `map(string)` | `{}` | no |
| <a name="input_default_node_pool_max_count"></a> [default\_node\_pool\_max\_count](#input\_default\_node\_pool\_max\_count) | Maximum number of nodes in the default node pool | `number` | `10` | no |
| <a name="input_default_node_pool_max_pods"></a> [default\_node\_pool\_max\_pods](#input\_default\_node\_pool\_max\_pods) | Maximum number of pods per node in the default node pool | `number` | `110` | no |
| <a name="input_default_node_pool_min_count"></a> [default\_node\_pool\_min\_count](#input\_default\_node\_pool\_min\_count) | Minimum number of nodes in the default node pool | `number` | `1` | no |
| <a name="input_default_node_pool_name"></a> [default\_node\_pool\_name](#input\_default\_node\_pool\_name) | Name of the default node pool | `string` | `"default"` | no |
| <a name="input_default_node_pool_node_count"></a> [default\_node\_pool\_node\_count](#input\_default\_node\_pool\_node\_count) | Number of nodes in the default node pool | `number` | `3` | no |
| <a name="input_default_node_pool_os_disk_size_gb"></a> [default\_node\_pool\_os\_disk\_size\_gb](#input\_default\_node\_pool\_os\_disk\_size\_gb) | OS disk size in GB for the default node pool | `number` | `128` | no |
| <a name="input_default_node_pool_os_disk_type"></a> [default\_node\_pool\_os\_disk\_type](#input\_default\_node\_pool\_os\_disk\_type) | OS disk type for the default node pool | `string` | `"Managed"` | no |
| <a name="input_default_node_pool_taints"></a> [default\_node\_pool\_taints](#input\_default\_node\_pool\_taints) | Taints for the default node pool | `list(string)` | `[]` | no |
| <a name="input_default_node_pool_vm_size"></a> [default\_node\_pool\_vm\_size](#input\_default\_node\_pool\_vm\_size) | VM size for the default node pool | `string` | `"Standard_DS2_v2"` | no |
| <a name="input_diagnostic_logs"></a> [diagnostic\_logs](#input\_diagnostic\_logs) | List of diagnostic logs to enable | `list(string)` | <pre>[<br/>  "kube-apiserver",<br/>  "kube-audit",<br/>  "kube-audit-admin",<br/>  "kube-controller-manager",<br/>  "kube-scheduler",<br/>  "cluster-autoscaler",<br/>  "guard"<br/>]</pre> | no |
| <a name="input_diagnostic_metrics"></a> [diagnostic\_metrics](#input\_diagnostic\_metrics) | List of diagnostic metrics to enable | `list(string)` | <pre>[<br/>  "AllMetrics"<br/>]</pre> | no |
| <a name="input_dns_prefix"></a> [dns\_prefix](#input\_dns\_prefix) | DNS prefix for the AKS cluster | `string` | `""` | no |
| <a name="input_dns_service_ip"></a> [dns\_service\_ip](#input\_dns\_service\_ip) | IP address for the DNS service | `string` | `"10.0.0.10"` | no |
| <a name="input_enable_aad_rbac"></a> [enable\_aad\_rbac](#input\_enable\_aad\_rbac) | Enable Azure AD RBAC for the cluster | `bool` | `true` | no |
| <a name="input_enable_api_server_authorized_ip_ranges"></a> [enable\_api\_server\_authorized\_ip\_ranges](#input\_enable\_api\_server\_authorized\_ip\_ranges) | Enable authorized IP ranges for API server | `bool` | `true` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable auto-scaling for the default node pool | `bool` | `true` | no |
| <a name="input_enable_auto_upgrade"></a> [enable\_auto\_upgrade](#input\_enable\_auto\_upgrade) | Enable automatic cluster upgrades | `bool` | `true` | no |
| <a name="input_enable_azure_cni"></a> [enable\_azure\_cni](#input\_enable\_azure\_cni) | Enable Azure CNI networking | `bool` | `true` | no |
| <a name="input_enable_azure_monitor"></a> [enable\_azure\_monitor](#input\_enable\_azure\_monitor) | Enable Azure Monitor for containers | `bool` | `true` | no |
| <a name="input_enable_azure_rbac"></a> [enable\_azure\_rbac](#input\_enable\_azure\_rbac) | Enable Azure RBAC for Kubernetes authorization | `bool` | `true` | no |
| <a name="input_enable_custom_policies"></a> [enable\_custom\_policies](#input\_enable\_custom\_policies) | Enable custom Azure Policy definitions | `bool` | `false` | no |
| <a name="input_enable_diagnostic_settings"></a> [enable\_diagnostic\_settings](#input\_enable\_diagnostic\_settings) | Enable diagnostic settings | `bool` | `true` | no |
| <a name="input_enable_http_proxy"></a> [enable\_http\_proxy](#input\_enable\_http\_proxy) | Enable HTTP proxy configuration | `bool` | `false` | no |
| <a name="input_enable_ingress_application_gateway"></a> [enable\_ingress\_application\_gateway](#input\_enable\_ingress\_application\_gateway) | Enable Application Gateway ingress controller | `bool` | `false` | no |
| <a name="input_enable_key_vault_secrets_provider"></a> [enable\_key\_vault\_secrets\_provider](#input\_enable\_key\_vault\_secrets\_provider) | Enable Key Vault secrets provider | `bool` | `true` | no |
| <a name="input_enable_load_balancer_profile"></a> [enable\_load\_balancer\_profile](#input\_enable\_load\_balancer\_profile) | Enable load balancer profile | `bool` | `false` | no |
| <a name="input_enable_log_analytics"></a> [enable\_log\_analytics](#input\_enable\_log\_analytics) | Enable Log Analytics workspace creation | `bool` | `true` | no |
| <a name="input_enable_maintenance_window"></a> [enable\_maintenance\_window](#input\_enable\_maintenance\_window) | Enable maintenance window | `bool` | `false` | no |
| <a name="input_enable_managed_identity"></a> [enable\_managed\_identity](#input\_enable\_managed\_identity) | Enable system-assigned managed identity | `bool` | `true` | no |
| <a name="input_enable_network_policy"></a> [enable\_network\_policy](#input\_enable\_network\_policy) | Enable network policy | `bool` | `true` | no |
| <a name="input_enable_oidc_issuer"></a> [enable\_oidc\_issuer](#input\_enable\_oidc\_issuer) | Enable OIDC issuer | `bool` | `true` | no |
| <a name="input_enable_policy_assignments"></a> [enable\_policy\_assignments](#input\_enable\_policy\_assignments) | Enable Azure Policy assignments | `bool` | `true` | no |
| <a name="input_enable_policy_initiative"></a> [enable\_policy\_initiative](#input\_enable\_policy\_initiative) | Enable Azure Policy initiative for AKS security | `bool` | `true` | no |
| <a name="input_enable_private_cluster"></a> [enable\_private\_cluster](#input\_enable\_private\_cluster) | Enable private cluster | `bool` | `true` | no |
| <a name="input_enable_resource_lock"></a> [enable\_resource\_lock](#input\_enable\_resource\_lock) | Enable resource lock for the AKS cluster | `bool` | `true` | no |
| <a name="input_enable_service_mesh"></a> [enable\_service\_mesh](#input\_enable\_service\_mesh) | Enable service mesh | `bool` | `false` | no |
| <a name="input_enable_workload_identity"></a> [enable\_workload\_identity](#input\_enable\_workload\_identity) | Enable workload identity | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (dev, test, prod, etc.) | `string` | n/a | yes |
| <a name="input_http_proxy_trusted_ca"></a> [http\_proxy\_trusted\_ca](#input\_http\_proxy\_trusted\_ca) | Trusted CA for HTTP proxy | `string` | `""` | no |
| <a name="input_http_proxy_url"></a> [http\_proxy\_url](#input\_http\_proxy\_url) | HTTP proxy URL | `string` | `""` | no |
| <a name="input_https_proxy_url"></a> [https\_proxy\_url](#input\_https\_proxy\_url) | HTTPS proxy URL | `string` | `""` | no |
| <a name="input_ingress_application_gateway_id"></a> [ingress\_application\_gateway\_id](#input\_ingress\_application\_gateway\_id) | Existing Application Gateway ID | `string` | `null` | no |
| <a name="input_ingress_application_gateway_name"></a> [ingress\_application\_gateway\_name](#input\_ingress\_application\_gateway\_name) | Name for new Application Gateway | `string` | `null` | no |
| <a name="input_ingress_application_gateway_subnet_cidr"></a> [ingress\_application\_gateway\_subnet\_cidr](#input\_ingress\_application\_gateway\_subnet\_cidr) | Subnet CIDR for Application Gateway | `string` | `null` | no |
| <a name="input_ingress_application_gateway_subnet_id"></a> [ingress\_application\_gateway\_subnet\_id](#input\_ingress\_application\_gateway\_subnet\_id) | Existing subnet ID for Application Gateway | `string` | `null` | no |
| <a name="input_key_vault_secret_rotation_enabled"></a> [key\_vault\_secret\_rotation\_enabled](#input\_key\_vault\_secret\_rotation\_enabled) | Enable secret rotation for Key Vault provider | `bool` | `true` | no |
| <a name="input_key_vault_secret_rotation_interval"></a> [key\_vault\_secret\_rotation\_interval](#input\_key\_vault\_secret\_rotation\_interval) | Secret rotation interval | `string` | `"2m"` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version for the AKS cluster | `string` | `"1.27.3"` | no |
| <a name="input_load_balancer_sku"></a> [load\_balancer\_sku](#input\_load\_balancer\_sku) | SKU for the load balancer | `string` | `"standard"` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure region for the AKS cluster | `string` | n/a | yes |
| <a name="input_location_short"></a> [location\_short](#input\_location\_short) | Short name for the location (e.g., 'eus' for East US) | `string` | n/a | yes |
| <a name="input_log_analytics_retention_days"></a> [log\_analytics\_retention\_days](#input\_log\_analytics\_retention\_days) | Retention period for Log Analytics data | `number` | `30` | no |
| <a name="input_log_analytics_sku"></a> [log\_analytics\_sku](#input\_log\_analytics\_sku) | SKU for Log Analytics workspace | `string` | `"PerGB2018"` | no |
| <a name="input_log_analytics_workspace_id"></a> [log\_analytics\_workspace\_id](#input\_log\_analytics\_workspace\_id) | Existing Log Analytics workspace ID | `string` | `null` | no |
| <a name="input_maintenance_window_allowed"></a> [maintenance\_window\_allowed](#input\_maintenance\_window\_allowed) | List of allowed maintenance windows | <pre>list(object({<br/>    day   = string<br/>    hours = list(number)<br/>  }))</pre> | `[]` | no |
| <a name="input_maintenance_window_not_allowed"></a> [maintenance\_window\_not\_allowed](#input\_maintenance\_window\_not\_allowed) | List of not allowed maintenance windows | <pre>list(object({<br/>    start = string<br/>    end   = string<br/>  }))</pre> | `[]` | no |
| <a name="input_managed_outbound_ip_count"></a> [managed\_outbound\_ip\_count](#input\_managed\_outbound\_ip\_count) | Number of managed outbound IPs | `number` | `1` | no |
| <a name="input_name_prefix"></a> [name\_prefix](#input\_name\_prefix) | Prefix for resource naming. If empty, defaults to 'aks-{environment}-{location\_short}' | `string` | `""` | no |
| <a name="input_name_suffix"></a> [name\_suffix](#input\_name\_suffix) | Suffix for resource naming | `string` | `""` | no |
| <a name="input_no_proxy_list"></a> [no\_proxy\_list](#input\_no\_proxy\_list) | List of addresses to exclude from proxy | `list(string)` | `[]` | no |
| <a name="input_node_resource_group"></a> [node\_resource\_group](#input\_node\_resource\_group) | Resource group for cluster nodes. If empty, defaults to {resource\_group\_name}-aks-nodes | `string` | `""` | no |
| <a name="input_outbound_ip_address_ids"></a> [outbound\_ip\_address\_ids](#input\_outbound\_ip\_address\_ids) | List of outbound IP address IDs | `list(string)` | `[]` | no |
| <a name="input_outbound_ip_prefix_ids"></a> [outbound\_ip\_prefix\_ids](#input\_outbound\_ip\_prefix\_ids) | List of outbound IP prefix IDs | `list(string)` | `[]` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Name of the project | `string` | `"enterprise"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | Resource group ID for policy assignments | `string` | `null` | no |
| <a name="input_resource_group_name"></a> [resource\_group\_name](#input\_resource\_group\_name) | Name of the resource group | `string` | n/a | yes |
| <a name="input_resource_lock_level"></a> [resource\_lock\_level](#input\_resource\_lock\_level) | Level of the resource lock | `string` | `"CanNotDelete"` | no |
| <a name="input_service_cidr"></a> [service\_cidr](#input\_service\_cidr) | CIDR for the service network | `string` | `"10.0.0.0/16"` | no |
| <a name="input_service_mesh_mode"></a> [service\_mesh\_mode](#input\_service\_mesh\_mode) | Service mesh mode | `string` | `"Istio"` | no |
| <a name="input_sku_tier"></a> [sku\_tier](#input\_sku\_tier) | SKU tier for the AKS cluster (Free or Paid) | `string` | `"Free"` | no |
| <a name="input_upgrade_channel"></a> [upgrade\_channel](#input\_upgrade\_channel) | Upgrade channel for automatic upgrades | `string` | `"stable"` | no |
| <a name="input_upgrade_max_surge"></a> [upgrade\_max\_surge](#input\_upgrade\_max\_surge) | Maximum surge for upgrades | `string` | `"10%"` | no |
| <a name="input_vnet_id"></a> [vnet\_id](#input\_vnet\_id) | Virtual network ID for the AKS cluster | `string` | n/a | yes |
| <a name="input_vnet_subnet_id"></a> [vnet\_subnet\_id](#input\_vnet\_subnet\_id) | Subnet ID for the AKS cluster nodes | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_aad_rbac_enabled"></a> [aks\_aad\_rbac\_enabled](#output\_aks\_aad\_rbac\_enabled) | Whether Azure AD RBAC is enabled |
| <a name="output_aks_additional_node_pools"></a> [aks\_additional\_node\_pools](#output\_aks\_additional\_node\_pools) | Map of additional node pools created |
| <a name="output_aks_api_server_authorized_ip_ranges"></a> [aks\_api\_server\_authorized\_ip\_ranges](#output\_aks\_api\_server\_authorized\_ip\_ranges) | The authorized IP ranges for API server access |
| <a name="output_aks_auto_scaling_enabled"></a> [aks\_auto\_scaling\_enabled](#output\_aks\_auto\_scaling\_enabled) | Whether auto-scaling is enabled for the default node pool |
| <a name="output_aks_auto_upgrade_enabled"></a> [aks\_auto\_upgrade\_enabled](#output\_aks\_auto\_upgrade\_enabled) | Whether auto-upgrade is enabled |
| <a name="output_aks_azure_monitor_enabled"></a> [aks\_azure\_monitor\_enabled](#output\_aks\_azure\_monitor\_enabled) | Whether Azure Monitor is enabled |
| <a name="output_aks_azure_rbac_enabled"></a> [aks\_azure\_rbac\_enabled](#output\_aks\_azure\_rbac\_enabled) | Whether Azure RBAC is enabled |
| <a name="output_aks_client_certificate"></a> [aks\_client\_certificate](#output\_aks\_client\_certificate) | The client certificate for the AKS cluster |
| <a name="output_aks_client_key"></a> [aks\_client\_key](#output\_aks\_client\_key) | The client key for the AKS cluster |
| <a name="output_aks_cluster_ca_certificate"></a> [aks\_cluster\_ca\_certificate](#output\_aks\_cluster\_ca\_certificate) | The cluster CA certificate for the AKS cluster |
| <a name="output_aks_cluster_fqdn"></a> [aks\_cluster\_fqdn](#output\_aks\_cluster\_fqdn) | The FQDN of the AKS cluster |
| <a name="output_aks_cluster_id"></a> [aks\_cluster\_id](#output\_aks\_cluster\_id) | The ID of the AKS cluster |
| <a name="output_aks_cluster_name"></a> [aks\_cluster\_name](#output\_aks\_cluster\_name) | The name of the AKS cluster |
| <a name="output_aks_cluster_portal_fqdn"></a> [aks\_cluster\_portal\_fqdn](#output\_aks\_cluster\_portal\_fqdn) | The portal FQDN of the AKS cluster |
| <a name="output_aks_cluster_private_fqdn"></a> [aks\_cluster\_private\_fqdn](#output\_aks\_cluster\_private\_fqdn) | The private FQDN of the AKS cluster |
| <a name="output_aks_default_node_pool"></a> [aks\_default\_node\_pool](#output\_aks\_default\_node\_pool) | The default node pool configuration |
| <a name="output_aks_diagnostic_setting_id"></a> [aks\_diagnostic\_setting\_id](#output\_aks\_diagnostic\_setting\_id) | The ID of the diagnostic setting |
| <a name="output_aks_host"></a> [aks\_host](#output\_aks\_host) | The Kubernetes cluster server host |
| <a name="output_aks_http_proxy_enabled"></a> [aks\_http\_proxy\_enabled](#output\_aks\_http\_proxy\_enabled) | Whether HTTP proxy is enabled |
| <a name="output_aks_identity"></a> [aks\_identity](#output\_aks\_identity) | The identity configuration of the AKS cluster |
| <a name="output_aks_ingress_application_gateway_enabled"></a> [aks\_ingress\_application\_gateway\_enabled](#output\_aks\_ingress\_application\_gateway\_enabled) | Whether Application Gateway ingress is enabled |
| <a name="output_aks_key_vault_secrets_provider_enabled"></a> [aks\_key\_vault\_secrets\_provider\_enabled](#output\_aks\_key\_vault\_secrets\_provider\_enabled) | Whether Key Vault secrets provider is enabled |
| <a name="output_aks_kube_config"></a> [aks\_kube\_config](#output\_aks\_kube\_config) | The kubeconfig for the AKS cluster |
| <a name="output_aks_kube_config_raw"></a> [aks\_kube\_config\_raw](#output\_aks\_kube\_config\_raw) | The raw kubeconfig for the AKS cluster |
| <a name="output_aks_kubernetes_version"></a> [aks\_kubernetes\_version](#output\_aks\_kubernetes\_version) | The Kubernetes version of the AKS cluster |
| <a name="output_aks_location"></a> [aks\_location](#output\_aks\_location) | The location of the AKS cluster |
| <a name="output_aks_log_analytics_workspace_id"></a> [aks\_log\_analytics\_workspace\_id](#output\_aks\_log\_analytics\_workspace\_id) | The ID of the Log Analytics workspace |
| <a name="output_aks_log_analytics_workspace_name"></a> [aks\_log\_analytics\_workspace\_name](#output\_aks\_log\_analytics\_workspace\_name) | The name of the Log Analytics workspace |
| <a name="output_aks_maintenance_window_enabled"></a> [aks\_maintenance\_window\_enabled](#output\_aks\_maintenance\_window\_enabled) | Whether maintenance window is enabled |
| <a name="output_aks_network_policy_enabled"></a> [aks\_network\_policy\_enabled](#output\_aks\_network\_policy\_enabled) | Whether network policy is enabled |
| <a name="output_aks_network_profile"></a> [aks\_network\_profile](#output\_aks\_network\_profile) | The network profile of the AKS cluster |
| <a name="output_aks_node_resource_group"></a> [aks\_node\_resource\_group](#output\_aks\_node\_resource\_group) | The resource group containing the AKS cluster nodes |
| <a name="output_aks_oidc_issuer_url"></a> [aks\_oidc\_issuer\_url](#output\_aks\_oidc\_issuer\_url) | The OIDC issuer URL of the AKS cluster |
| <a name="output_aks_policy_assignment_id"></a> [aks\_policy\_assignment\_id](#output\_aks\_policy\_assignment\_id) | The ID of the Azure Policy assignment |
| <a name="output_aks_private_cluster_enabled"></a> [aks\_private\_cluster\_enabled](#output\_aks\_private\_cluster\_enabled) | Whether the AKS cluster is private |
| <a name="output_aks_resource_group_name"></a> [aks\_resource\_group\_name](#output\_aks\_resource\_group\_name) | The resource group name of the AKS cluster |
| <a name="output_aks_resource_lock_id"></a> [aks\_resource\_lock\_id](#output\_aks\_resource\_lock\_id) | The ID of the resource lock |
| <a name="output_aks_service_mesh_enabled"></a> [aks\_service\_mesh\_enabled](#output\_aks\_service\_mesh\_enabled) | Whether service mesh is enabled |
| <a name="output_aks_sku_tier"></a> [aks\_sku\_tier](#output\_aks\_sku\_tier) | The SKU tier of the AKS cluster |
| <a name="output_aks_tags"></a> [aks\_tags](#output\_aks\_tags) | Tags applied to the AKS cluster |
| <a name="output_aks_upgrade_channel"></a> [aks\_upgrade\_channel](#output\_aks\_upgrade\_channel) | The upgrade channel for the AKS cluster |
| <a name="output_aks_user_assigned_identity_client_id"></a> [aks\_user\_assigned\_identity\_client\_id](#output\_aks\_user\_assigned\_identity\_client\_id) | The client ID of the user-assigned identity |
| <a name="output_aks_user_assigned_identity_id"></a> [aks\_user\_assigned\_identity\_id](#output\_aks\_user\_assigned\_identity\_id) | The ID of the user-assigned identity |
| <a name="output_aks_user_assigned_identity_principal_id"></a> [aks\_user\_assigned\_identity\_principal\_id](#output\_aks\_user\_assigned\_identity\_principal\_id) | The principal ID of the user-assigned identity |
| <a name="output_aks_workload_identity_enabled"></a> [aks\_workload\_identity\_enabled](#output\_aks\_workload\_identity\_enabled) | Whether workload identity is enabled |
<!-- END_TF_DOCS -->

---

## Part of the AIRCLOUD Azure module catalog

Browse all modules with usage snippets in the [module catalog](https://aircloud-pl.github.io/) or on [github.com/AIRCLOUD-PL](https://github.com/AIRCLOUD-PL). Built and maintained by [AIRCLOUD](https://aircloud.com.pl): DevOps, cloud and AI engineering. Need a hand with Azure landing zones or platform engineering? See [aircloud.com.pl/consulting](https://aircloud.com.pl/consulting).
