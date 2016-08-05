# This uploads ARM linked templates to storage account

Param(
	[string] [Parameter(Mandatory=$true)] $ResourceGroupName,
	[string] [Parameter(Mandatory=$true)] $StorageAccountName,
	[string] [Parameter(Mandatory=$true)] $ProjectName,
	[string] [Parameter(Mandatory=$false)] $ContainerName = "templates"
)

# Login
Write-Host "Verifying credentials ..." -ForegroundColor Green

$msg = Login-AzureRmAccount

Write-Host "Credentials verified" -ForegroundColor Green

$msg = Set-AzureRmCurrentStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName

# Templates
$templates = Get-ChildItem .\src\$ProjectName\Templates\*.json -Exclude ("base-*.json", "master-*.json", "*.params.json")
foreach($template in $templates)
{
    $filePath = $template.FullName
    $fileName = $template.Name

    Write-Host "Uploading $fileName to Azure Storage Account ..." -ForegroundColor Green

    $msg = Set-AzureStorageBlobContent -Container $ContainerName -File $filePath -Force

    Write-Host "$fileName uploaded" -ForegroundColor Green
}

# Parameters
$segments = $ResourceGroupName.Split("-")
$envName = $segments[$segments.Count - 1]

$templates = Get-ChildItem .\src\$ProjectName\Templates\*.params.json -Exclude ("base-*.json", "master-*.json")
foreach($template in $templates)
{
    $filePath = $template.FullName
    $fileName = $template.Name

    $json = Get-Content -Path $filePath | ConvertFrom-Json
    $json.parameters | Add-Member -MemberType NoteProperty -Name environment -Value @{ value = $envName }

    $json | ConvertTo-Json -Depth 999 | Out-File -FilePath $filePath -Encoding utf8

    Write-Host "Uploading $fileName to Azure Storage Account ..." -ForegroundColor Green

    $msg = Set-AzureStorageBlobContent -Container $ContainerName -File $filePath -Force

    Write-Host "$fileName uploaded" -ForegroundColor Green
}

Remove-Variable segments
Remove-Variable envName
Remove-Variable json
Remove-Variable templates
Remove-Variable template
Remove-Variable filePath
Remove-Variable fileName
Remove-Variable msg
