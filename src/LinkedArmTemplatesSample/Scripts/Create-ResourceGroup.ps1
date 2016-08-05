# This creates an Azure Resource Group based on project name, environment and location.
# Once Azure resource group is created, this returns the resource group name created.
Param(
	[string] [Parameter(Mandatory=$true)] $Environment = "dev",
	[string] [Parameter(Mandatory=$true)] $Location = "Australia East"
)

# Login
Write-Host "Verifying credentials ..." -ForegroundColor Green

$msg = Login-AzureRmAccount

Write-Host "Credentials verified" -ForegroundColor Green

# Resource Group
$rg = @{ Name = "rg-$Environment".ToLowerInvariant(); Location = $Location }

Write-Host "Creating Azure Resource Group ..." -ForegroundColor Green

$exists = Get-AzureRmResourceGroup -Name $rg.Name -Location $rg.Location -ErrorVariable ex -ErrorAction SilentlyContinue
if ($exists -eq $null)
{
    $msg = New-AzureRmResourceGroup -Name $rg.Name -Location $rg.Location
}

# Return
$rg

Write-Host "Azure Resource Group created" -ForegroundColor Green

# Release
Remove-Variable msg
Remove-Variable exists
Remove-Variable ex
Remove-Variable rg
