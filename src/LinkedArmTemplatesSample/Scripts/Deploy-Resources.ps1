# This runs ARM template and its parameter file to deploy resources to Azure.

Param(
    [string] [Parameter(Mandatory=$true)] $Name,
	[string] [Parameter(Mandatory=$true)] $ResourceGroupName,
	[string] [Parameter(Mandatory=$true)] $Environment,
	[string] [Parameter(Mandatory=$true)] $TemplateFile,
	[string] [Parameter(Mandatory=$false)] $TemplateParameterFile,
    [switch] $IsBaseTemplate,
    [switch] $IsMasterTemplate,
	[string] [Parameter(Mandatory=$false)] $StorageAccountName,
	[string] [Parameter(Mandatory=$false)] $ContainerName = "templates"
)

# Login
Write-Host "Verifying credentials ..." -ForegroundColor Green

$msg = Login-AzureRmAccount

Write-Host "Credentials verified" -ForegroundColor Green

# Deploy
Write-Host "Deploying resources ..." -ForegroundColor Green

if ($IsMasterTemplate -eq $true)
{
    $msg = Set-AzureRmCurrentStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName
    $sasToken = New-AzureStorageContainerSASToken -Name $ContainerName -Permission r -Protocol HttpsOnly -ExpiryTime (Get-Date).AddMinutes(30)

    $msg = New-AzureRmResourceGroupDeployment `
               -Name $Name `
               -ResourceGroupName $ResourceGroupName `
               -TemplateFile $TemplateFile `
               -environment $Environment `
               -sasToken $sasToken `
               -Mode Incremental `
               -Verbose

    Remove-Variable sasToken
}
else
{
    $msg = New-AzureRmResourceGroupDeployment `
               -Name $Name `
               -ResourceGroupName $ResourceGroupName `
               -TemplateFile $TemplateFile `
               -TemplateParameterFile $TemplateParameterFile `
               -environment $Environment `
               -Mode Incremental `
               -Verbose
}

$msg

Write-Host "Resources deployed" -ForegroundColor Green

# Run only for base-deployment.json
if ($IsBaseTemplate -eq $true)
{
    Write-Host "Creating blob container for ARM templates ..." -ForegroundColor Green

    $msg = Set-AzureRmCurrentStorageAccount -ResourceGroupName $ResourceGroupName -Name $msg.Outputs.storageAccountName.Value
    $msg = New-AzureStorageContainer -Name $ContainerName -Permission Off

    $msg

    Write-Host "Blob container for ARM templates created" -ForegroundColor Green
}

Remove-Variable msg
