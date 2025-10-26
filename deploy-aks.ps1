# AKS Module Automation Script
# This script provides automation for deploying, testing, and managing AKS clusters

param(
    [Parameter(Mandatory = $false)]
    [string]$Action = "deploy",

    [Parameter(Mandatory = $false)]
    [string]$Environment = "dev",

    [Parameter(Mandatory = $false)]
    [string]$Location = "East US",

    [Parameter(Mandatory = $false)]
    [string]$ResourceGroupName,

    [Parameter(Mandatory = $false)]
    [string]$ClusterName,

    [Parameter(Mandatory = $false)]
    [switch]$SkipTests,

    [Parameter(Mandatory = $false)]
    [switch]$Cleanup,

    [Parameter(Mandatory = $false)]
    [switch]$ValidateOnly,

    [Parameter(Mandatory = $false)]
    [string]$TerraformPath = "terraform",

    [Parameter(Mandatory = $false)]
    [string]$GoPath = "go",

    [Parameter(Mandatory = $false)]
    [switch]$Verbose
)

# Configuration
$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$ModulePath = Join-Path $ScriptPath "modules\compute\aks"
$TestPath = Join-Path $ModulePath "test"

# Logging function
function Write-Log {
    param(
        [string]$Message,
        [string]$Level = "INFO"
    )

    $Timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    $LogMessage = "[$Timestamp] [$Level] $Message"

    switch ($Level) {
        "ERROR" { Write-Host $LogMessage -ForegroundColor Red }
        "WARNING" { Write-Host $LogMessage -ForegroundColor Yellow }
        "SUCCESS" { Write-Host $LogMessage -ForegroundColor Green }
        default { Write-Host $LogMessage }
    }

    if ($Verbose) {
        Add-Content -Path "aks-automation.log" -Value $LogMessage
    }
}

# Check prerequisites
function Test-Prerequisites {
    Write-Log "Checking prerequisites..."

    # Check Terraform
    try {
        $tfVersion = & $TerraformPath version | Select-String -Pattern "Terraform v(\d+\.\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
        if ([version]$tfVersion -lt [version]"1.5.0") {
            throw "Terraform version $tfVersion is not supported. Minimum required: 1.5.0"
        }
        Write-Log "Terraform version: $tfVersion" -Level "SUCCESS"
    }
    catch {
        Write-Log "Terraform not found or version check failed: $_" -Level "ERROR"
        return $false
    }

    # Check Go
    try {
        $goVersion = & $GoPath version | Select-String -Pattern "go version go(\d+\.\d+)" | ForEach-Object { $_.Matches.Groups[1].Value }
        if ([version]$goVersion -lt [version]"1.21") {
            throw "Go version $goVersion is not supported. Minimum required: 1.21"
        }
        Write-Log "Go version: $goVersion" -Level "SUCCESS"
    }
    catch {
        Write-Log "Go not found or version check failed: $_" -Level "ERROR"
        return $false
    }

    # Check Azure CLI
    try {
        $azVersion = & az version --query '"azure-cli"' -o tsv
        Write-Log "Azure CLI version: $azVersion" -Level "SUCCESS"
    }
    catch {
        Write-Log "Azure CLI not found: $_" -Level "ERROR"
        return $false
    }

    # Check Azure login
    try {
        $account = & az account show --query name -o tsv
        Write-Log "Azure account: $account" -Level "SUCCESS"
    }
    catch {
        Write-Log "Not logged in to Azure. Please run 'az login' first." -Level "ERROR"
        return $false
    }

    return $true
}

# Generate resource names
function Get-ResourceNames {
    param(
        [string]$Environment,
        [string]$Location,
        [string]$ClusterName
    )

    $locationShort = switch ($Location) {
        "East US" { "eus" }
        "West US" { "wus" }
        "Central US" { "cus" }
        "West Europe" { "weu" }
        "North Europe" { "neu" }
        default { $Location.ToLower().Replace(" ", "") }
    }

    if (-not $ClusterName) {
        $timestamp = Get-Date -Format "yyyyMMddHHmmss"
        $ClusterName = "aks-$Environment-$locationShort-$timestamp"
    }

    if (-not $ResourceGroupName) {
        $ResourceGroupName = "rg-$ClusterName"
    }

    return @{
        ResourceGroupName = $ResourceGroupName
        ClusterName = $ClusterName
        Location = $Location
        LocationShort = $locationShort
        Environment = $Environment
    }
}

# Create terraform.tfvars file
function New-TerraformVars {
    param(
        [hashtable]$Names,
        [string]$VnetId,
        [string]$SubnetId
    )

    $varsContent = @"
resource_group_name = "$($Names.ResourceGroupName)"
location = "$($Names.Location)"
location_short = "$($Names.LocationShort)"
environment = "$($Names.Environment)"
custom_name = "$($Names.ClusterName)"

# VNet configuration
vnet_id = "$VnetId"
vnet_subnet_id = "$SubnetId"

# Cluster configuration
kubernetes_version = "1.27.3"
sku_tier = "Free"

# Identity
enable_managed_identity = true

# Default node pool
default_node_pool_vm_size = "Standard_DS2_v2"
default_node_pool_node_count = 1
enable_auto_scaling = false
default_node_pool_os_disk_size_gb = 128

# Network
enable_azure_cni = true
enable_network_policy = false
dns_service_ip = "10.0.0.10"
service_cidr = "10.0.0.0/16"
load_balancer_sku = "standard"

# Security features
enable_oidc_issuer = true
enable_workload_identity = true

# Monitoring
enable_azure_monitor = false
enable_log_analytics = false

# Disable enterprise features for basic deployment
enable_private_cluster = false
enable_aad_rbac = false
enable_azure_rbac = false
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
"@

    $varsFile = Join-Path $ModulePath "terraform.tfvars"
    $varsContent | Out-File -FilePath $varsFile -Encoding UTF8
    Write-Log "Created terraform.tfvars file"
}

# Create VNet and subnet
function New-VirtualNetwork {
    param(
        [hashtable]$Names
    )

    Write-Log "Creating virtual network and subnet..."

    $vnetName = "vnet-$($Names.ClusterName)"
    $subnetName = "snet-aks"

    try {
        # Create resource group
        & az group create --name $Names.ResourceGroupName --location $Names.Location --output none
        Write-Log "Created resource group: $($Names.ResourceGroupName)"

        # Create VNet
        $vnetResult = & az network vnet create `
            --resource-group $Names.ResourceGroupName `
            --name $vnetName `
            --address-prefix 10.0.0.0/16 `
            --subnet-name $subnetName `
            --subnet-prefix 10.0.0.0/24 `
            --output json | ConvertFrom-Json

        $vnetId = $vnetResult.id
        $subnetId = $vnetResult.subnets[0].id

        Write-Log "Created VNet: $vnetName"
        Write-Log "Created subnet: $subnetName"

        return @{
            VnetId = $vnetId
            SubnetId = $subnetId
        }
    }
    catch {
        Write-Log "Failed to create virtual network: $_" -Level "ERROR"
        return $null
    }
}

# Deploy AKS cluster
function Deploy-AKS {
    param(
        [hashtable]$Names,
        [switch]$ValidateOnly
    )

    Write-Log "Deploying AKS cluster..."

    Push-Location $ModulePath

    try {
        # Initialize Terraform
        Write-Log "Initializing Terraform..."
        & $TerraformPath init
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform init failed"
        }

        # Validate configuration
        Write-Log "Validating Terraform configuration..."
        & $TerraformPath validate
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform validate failed"
        }

        # Plan deployment
        Write-Log "Planning Terraform deployment..."
        & $TerraformPath plan -out=tfplan
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform plan failed"
        }

        if ($ValidateOnly) {
            Write-Log "Validation completed successfully. Use -Action deploy to apply changes." -Level "SUCCESS"
            return $true
        }

        # Apply deployment
        Write-Log "Applying Terraform deployment..."
        & $TerraformPath apply -auto-approve tfplan
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform apply failed"
        }

        Write-Log "AKS cluster deployed successfully!" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Deployment failed: $_" -Level "ERROR"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Run tests
function Test-AKS {
    Write-Log "Running AKS tests..."

    Push-Location $TestPath

    try {
        # Initialize Go module
        & $GoPath mod init test
        & $GoPath mod tidy

        # Install dependencies
        & $GoPath get github.com/gruntwork-io/terratest/modules/terraform
        & $GoPath get github.com/gruntwork-io/terratest/modules/azure
        & $GoPath get github.com/stretchr/testify/assert
        & $GoPath get github.com/stretchr/testify/require

        # Run validation tests
        Write-Log "Running validation tests..."
        & $GoPath test -v -run TestAKSValidation -timeout 10m
        if ($LASTEXITCODE -ne 0) {
            throw "Validation tests failed"
        }

        Write-Log "Tests completed successfully!" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Tests failed: $_" -Level "ERROR"
        return $false
    }
    finally {
        Pop-Location
    }
}

# Get cluster information
function Get-AKSInfo {
    param(
        [hashtable]$Names
    )

    Write-Log "Getting AKS cluster information..."

    try {
        $cluster = & az aks show --resource-group $Names.ResourceGroupName --name $Names.ClusterName --output json | ConvertFrom-Json

        Write-Log "Cluster Name: $($cluster.name)"
        Write-Log "Location: $($cluster.location)"
        Write-Log "Kubernetes Version: $($cluster.kubernetesVersion)"
        Write-Log "Provisioning State: $($cluster.provisioningState)"
        Write-Log "Node Resource Group: $($cluster.nodeResourceGroup)"
        Write-Log "Private Cluster: $($cluster.apiServerAccessProfile.enablePrivateCluster)"
        Write-Log "OIDC Issuer: $($cluster.oidcIssuerProfile.enabled)"

        # Get kubeconfig
        Write-Log "Getting kubeconfig..."
        & az aks get-credentials --resource-group $Names.ResourceGroupName --name $Names.ClusterName --overwrite-existing

        Write-Log "Cluster information retrieved successfully!" -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Failed to get cluster information: $_" -Level "ERROR"
        return $false
    }
}

# Cleanup resources
function Remove-AKSResources {
    param(
        [hashtable]$Names
    )

    Write-Log "Cleaning up AKS resources..."

    try {
        # Destroy Terraform resources
        Push-Location $ModulePath
        & $TerraformPath destroy -auto-approve
        Pop-Location

        # Delete resource group
        & az group delete --name $Names.ResourceGroupName --yes --no-wait
        Write-Log "Cleanup initiated. Resources will be deleted asynchronously." -Level "SUCCESS"
        return $true
    }
    catch {
        Write-Log "Cleanup failed: $_" -Level "ERROR"
        return $false
    }
}

# Main execution
function Invoke-Main {
    if (-not (Test-Prerequisites)) {
        exit 1
    }

    $names = Get-ResourceNames -Environment $Environment -Location $Location -ClusterName $ClusterName

    switch ($Action.ToLower()) {
        "deploy" {
            Write-Log "Starting AKS deployment process..."

            # Create networking
            $network = New-VirtualNetwork -Names $names
            if (-not $network) {
                exit 1
            }

            # Create terraform vars
            New-TerraformVars -Names $names -VnetId $network.VnetId -SubnetId $network.SubnetId

            # Deploy AKS
            if (-not (Deploy-AKS -Names $names)) {
                exit 1
            }

            # Run tests if not skipped
            if (-not $SkipTests) {
                if (-not (Test-AKS)) {
                    Write-Log "Tests failed, but deployment completed. Check test results." -Level "WARNING"
                }
            }

            # Get cluster info
            Get-AKSInfo -Names $names
        }

        "test" {
            if (-not (Test-AKS)) {
                exit 1
            }
        }

        "validate" {
            Write-Log "Starting AKS validation..."

            # Create networking
            $network = New-VirtualNetwork -Names $names
            if (-not $network) {
                exit 1
            }

            # Create terraform vars
            New-TerraformVars -Names $names -VnetId $network.VnetId -SubnetId $network.SubnetId

            # Validate only
            if (-not (Deploy-AKS -Names $names -ValidateOnly)) {
                exit 1
            }
        }

        "info" {
            Get-AKSInfo -Names $names
        }

        "cleanup" {
            Remove-AKSResources -Names $names
        }

        default {
            Write-Log "Invalid action: $Action. Valid actions: deploy, test, validate, info, cleanup" -Level "ERROR"
            exit 1
        }
    }

    if ($Cleanup) {
        Write-Log "Cleanup requested..."
        Remove-AKSResources -Names $names
    }

    Write-Log "AKS automation completed!" -Level "SUCCESS"
}

# Execute main function
Invoke-Main