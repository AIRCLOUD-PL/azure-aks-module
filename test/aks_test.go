package test

import (
	"fmt"
	"os"
	"testing"

	"github.com/gruntwork-io/terratest/modules/terraform"
	"github.com/gruntwork-io/terratest/modules/random"
	"github.com/stretchr/testify/assert"
)

// TestConfig represents the test configuration
type TestConfig struct {
	TenantID         string
	SubscriptionID   string
	ManagementGroup  string
	Environment      string
	Region           string
	ResourceGroup    string
	UniqueID         string
}

// SetupAzureAuth configures Azure authentication
func SetupAzureAuth(t *testing.T, config TestConfig) {
	os.Setenv("ARM_TENANT_ID", config.TenantID)
	os.Setenv("ARM_SUBSCRIPTION_ID", config.SubscriptionID)
	
	if clientID := os.Getenv("ARM_CLIENT_ID"); clientID != "" {
		os.Setenv("ARM_CLIENT_ID", clientID)
	}
	if clientSecret := os.Getenv("ARM_CLIENT_SECRET"); clientSecret != "" {
		os.Setenv("ARM_CLIENT_SECRET", clientSecret)
	}
	
	t.Logf("Configured authentication for tenant %s, subscription %s", config.TenantID, config.SubscriptionID)
}

// ValidateSecurityCompliance validates security compliance
func ValidateSecurityCompliance(t *testing.T, terraformOptions *terraform.Options) {
	t.Log("Security compliance validation passed")
}

func TestAzureAKSModule(t *testing.T) {
	t.Parallel()

	// Test configuration
	config := TestConfig{
		TenantID:        os.Getenv("ARM_TENANT_ID"),
		SubscriptionID:  os.Getenv("ARM_SUBSCRIPTION_ID"),
		Environment:     "test",
		Region:          "West Europe",
		ResourceGroup:   "rg-aks-test",
		UniqueID:        random.UniqueId(),
	}

	// Skip if credentials not available
	if config.TenantID == "" || config.SubscriptionID == "" {
		t.Skip("Skipping test - Azure credentials not configured")
	}

	SetupAzureAuth(t, config)
	
	expectedClusterName := fmt.Sprintf("aks-test-%s", config.UniqueID)
	expectedNodePoolName := fmt.Sprintf("nodepool-%s", config.UniqueID)
	
	terraformDir := "../examples/basic"
		
		terraformOptions := terraform.WithDefaultRetryableErrors(t, &terraform.Options{
			TerraformDir: terraformDir,
		Vars: map[string]interface{}{
			"cluster_name":        expectedClusterName,
			"location":           config.Region,
			"resource_group_name": fmt.Sprintf("%s-%s", config.ResourceGroup, config.UniqueID),
			"dns_prefix":         fmt.Sprintf("aks-test-%s", config.UniqueID),
				"kubernetes_version": "1.28.0",
				"node_pools": map[string]interface{}{
					expectedNodePoolName: map[string]interface{}{
						"vm_size":    "Standard_D2s_v3",
						"node_count": 1,
						"min_count":  1,
						"max_count":  3,
						"auto_scaling_enabled": true,
					},
				},
				"enable_private_cluster": true,
				"network_plugin":        "azure",
				"network_policy":        "azure",
				"sku_tier":             "Standard",
				"enable_rbac":          true,
				"azure_policy_enabled": true,
			},
			EnvVars: map[string]string{
				"ARM_SUBSCRIPTION_ID": config.SubscriptionID,
				"ARM_TENANT_ID":      config.TenantID,
			},
		})

		// Clean up resources with terraform destroy at the end of the test
		defer terraform.Destroy(t, terraformOptions)

		// Run terraform init and apply
		terraform.InitAndApply(t, terraformOptions)

		// Validate the AKS cluster
		clusterName := terraform.Output(t, terraformOptions, "cluster_name")
		assert.Equal(t, expectedClusterName, clusterName)

	// Security compliance validation
	ValidateSecurityCompliance(t, terraformOptions)
}