# AKS Module - Azure Policy Assignments
# This file contains Azure Policy assignments for AKS security and compliance

# Data sources for built-in policies
data "azurerm_policy_definition" "aks_encryption_at_host" {
  display_name = "Azure Kubernetes Service clusters should have encryption at host enabled"
}

data "azurerm_policy_definition" "aks_private_clusters" {
  display_name = "Azure Kubernetes Service clusters should use private clusters"
}

data "azurerm_policy_definition" "aks_authorized_ip_ranges" {
  display_name = "Azure Kubernetes Service clusters should use authorized IP ranges"
}

data "azurerm_policy_definition" "aks_https_only" {
  display_name = "Azure Kubernetes Service clusters should use HTTPS only"
}

data "azurerm_policy_definition" "aks_network_policy" {
  display_name = "Azure Kubernetes Service clusters should use network policies"
}

data "azurerm_policy_definition" "aks_os_and_data_disks_encrypted" {
  display_name = "Azure Kubernetes Service clusters should have OS and data disks encrypted"
}

data "azurerm_policy_definition" "aks_azure_cni_networking" {
  display_name = "Azure Kubernetes Service clusters should use Azure CNI networking"
}

data "azurerm_policy_definition" "aks_auto_upgrade" {
  display_name = "Azure Kubernetes Service clusters should have auto-upgrade enabled"
}

data "azurerm_policy_definition" "aks_azure_monitor" {
  display_name = "Azure Kubernetes Service clusters should have Azure Monitor enabled"
}

data "azurerm_policy_definition" "aks_microsoft_defender" {
  display_name = "Azure Kubernetes Service clusters should have Microsoft Defender for Containers enabled"
}

# Policy Assignments
resource "azurerm_resource_group_policy_assignment" "aks_encryption_at_host" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-encryption-at-host"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_encryption_at_host.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_private_clusters" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-private-clusters"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_private_clusters.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_authorized_ip_ranges" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-authorized-ip-ranges"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_authorized_ip_ranges.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_https_only" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-https-only"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_https_only.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_network_policy" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-network-policy"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_network_policy.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_os_and_data_disks_encrypted" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-disk-encryption"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_os_and_data_disks_encrypted.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_azure_cni_networking" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-azure-cni"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_azure_cni_networking.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_auto_upgrade" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-auto-upgrade"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_auto_upgrade.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_azure_monitor" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-azure-monitor"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_azure_monitor.id

  parameters = jsonencode({
    effect = {
      value = "Audit"
    }
  })
}

resource "azurerm_resource_group_policy_assignment" "aks_microsoft_defender" {
  count = var.enable_policy_assignments ? 1 : 0

  name                 = "${local.aks_name}-microsoft-defender"
  resource_group_id    = var.resource_group_id
  policy_definition_id = data.azurerm_policy_definition.aks_microsoft_defender.id

  parameters = jsonencode({
    effect = {
      value = "DeployIfNotExists"
    }
  })
}

# Custom Policy Definitions for AKS
resource "azurerm_policy_definition" "aks_pod_security_standards" {
  count = var.enable_custom_policies ? 1 : 0

  name         = "aks-pod-security-standards-policy"
  policy_type  = "Custom"
  mode         = "Microsoft.Kubernetes.Data"
  display_name = "AKS clusters should enforce pod security standards"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.ContainerService/managedClusters"
    }
    then = {
      effect = "Audit"
      details = {
        type = "Microsoft.Kubernetes.Data"
        existenceCondition = {
          field  = "Microsoft.Kubernetes.Data/resources/podSecurityStandards"
          exists = true
        }
      }
    }
  })
}

resource "azurerm_policy_definition" "aks_image_pull_secrets" {
  count = var.enable_custom_policies ? 1 : 0

  name         = "aks-image-pull-secrets-policy"
  policy_type  = "Custom"
  mode         = "Microsoft.Kubernetes.Data"
  display_name = "AKS pods should use image pull secrets"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Kubernetes.Data"
      in     = ["pods"]
    }
    then = {
      effect = "Audit"
      details = {
        type = "Microsoft.Kubernetes.Data"
        existenceCondition = {
          field  = "Microsoft.Kubernetes.Data/resources/spec/imagePullSecrets"
          exists = true
        }
      }
    }
  })
}

resource "azurerm_policy_definition" "aks_resource_limits" {
  count = var.enable_custom_policies ? 1 : 0

  name         = "aks-resource-limits-policy"
  policy_type  = "Custom"
  mode         = "Microsoft.Kubernetes.Data"
  display_name = "AKS pods should have resource limits defined"

  policy_rule = jsonencode({
    if = {
      field  = "type"
      equals = "Microsoft.Kubernetes.Data"
      in     = ["pods"]
    }
    then = {
      effect = "Audit"
      details = {
        type = "Microsoft.Kubernetes.Data"
        existenceCondition = {
          allOf = [
            {
              field  = "Microsoft.Kubernetes.Data/resources/spec/containers[*].resources.limits.cpu"
              exists = true
            },
            {
              field  = "Microsoft.Kubernetes.Data/resources/spec/containers[*].resources.limits.memory"
              exists = true
            }
          ]
        }
      }
    }
  })
}

# Initiative Definition for AKS Security
resource "azurerm_policy_set_definition" "aks_security_initiative" {
  count = var.enable_policy_initiative ? 1 : 0

  name         = "aks-security-initiative"
  policy_type  = "Custom"
  display_name = "AKS Enterprise Security Initiative"

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.aks_private_clusters.id
    parameter_values = jsonencode({
      effect = {
        value = "Audit"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.aks_encryption_at_host.id
    parameter_values = jsonencode({
      effect = {
        value = "Audit"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.aks_network_policy.id
    parameter_values = jsonencode({
      effect = {
        value = "Audit"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.aks_azure_monitor.id
    parameter_values = jsonencode({
      effect = {
        value = "Audit"
      }
    })
  }

  policy_definition_reference {
    policy_definition_id = data.azurerm_policy_definition.aks_microsoft_defender.id
    parameter_values = jsonencode({
      effect = {
        value = "DeployIfNotExists"
      }
    })
  }
}

# Initiative Assignment
resource "azurerm_resource_group_policy_assignment" "aks_security_initiative" {
  count = var.enable_policy_initiative ? 1 : 0

  name                 = "${local.aks_name}-security-initiative"
  resource_group_id    = var.resource_group_id
  policy_definition_id = azurerm_policy_set_definition.aks_security_initiative[0].id

  parameters = jsonencode({})
}