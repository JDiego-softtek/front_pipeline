# ==========================================================
# MOT Platform Setup CLI
# Environments: dev | qa | staging-uat | prod
# ==========================================================

Clear-Host

function Title($text) {
    Write-Host "`n========================================" -ForegroundColor Cyan
    Write-Host $text -ForegroundColor Cyan
    Write-Host "========================================" -ForegroundColor Cyan
}
function Info($text) { Write-Host $text -ForegroundColor Yellow }
function Ok($text)   { Write-Host $text -ForegroundColor Green }
function Err($text)  { Write-Host $text -ForegroundColor Red }

Title "MOT Platform Setup"
Info "Login to Azure..."
az login --use-device-code | Out-Null
$account = az account show | ConvertFrom-Json
Ok "Logged in as: $($account.user.name)"

function RunSetup() {
    Title "Select Subscription"
    $subs = az account list | ConvertFrom-Json
    for ($i = 0; $i -lt $subs.Count; $i++) { Write-Host "[$i] $($subs[$i].name)" }
    $subIdx = Read-Host "Select subscription number"
    $script:subscriptionId = $subs[$subIdx].id
    az account set --subscription $script:subscriptionId
    Ok "Using subscription: $script:subscriptionId"

    Title "Project Selection"
    $projects = @("MOT-Ecomm","MOT-Membership","MOT-Platform")
    for ($i = 0; $i -lt $projects.Count; $i++) { Write-Host "[$i] $($projects[$i])" }
    $pIdx = Read-Host "Select project"
    $script:project = $projects[$pIdx]
    Ok "Project: $script:project"

    Title "Environment"
    $envOptions = @("dev","qa","staging-uat","prod")
    for ($i = 0; $i -lt $envOptions.Count; $i++) { Write-Host "[$i] $($envOptions[$i])" }
    $envIdx = Read-Host "Select environment"
    $script:environment = $envOptions[$envIdx]
    Ok "Environment: $script:environment"

    Title "Tags & Naming Convention"
    $tags = @{ environment = $script:environment; project = $script:project }
    $script:tagString = ""
    foreach ($k in $tags.Keys) { $script:tagString += "$k=$($tags[$k]) " }
    $script:storage = ("st$($script:project.Replace('-','').ToLower())$script:environment" + "tfstate")
    if ($script:storage.Length -gt 24) { $script:storage = $script:storage.Substring(0,24) }
    $script:spname = "sp-$script:project-$script:environment-terraform".ToLower()
    Write-Host "Storage Account  : $script:storage"
    Write-Host "Service Principal: $script:spname"

    Title "Resource Group Selection"
    $resourceGroups = az group list | ConvertFrom-Json
    for ($i = 0; $i -lt $resourceGroups.Count; $i++) {
        Write-Host "[$i] $($resourceGroups[$i].name) (`"$($resourceGroups[$i].location)`")"
    }
    $rgIdx           = Read-Host "Select resource group number"
    $script:rg       = $resourceGroups[$rgIdx].name
    $script:location = $resourceGroups[$rgIdx].location
    Ok "Selected Resource Group: $script:rg"
    Ok "Location: $script:location"

    ShowConfig
}

function ShowConfig() {
    Title "Current Configuration"
    Write-Host "Subscription ID  : $script:subscriptionId"
    Write-Host "Project          : $script:project"
    Write-Host "Environment      : $script:environment"
    Write-Host "Resource Group   : $script:rg"
    Write-Host "Location         : $script:location"
    Write-Host "Storage Account  : $script:storage"
    Write-Host "Service Principal: $script:spname"
}

function Menu() {
    Write-Host "`n=========== MENU ===========" -ForegroundColor Cyan
    Write-Host "1 - Create Terraform Backend"
    Write-Host "2 - Create Service Principal"
    Write-Host "3 - List Resources"
    Write-Host "4 - Full Setup"
    Write-Host "5 - Revalidate (re-run configuration)"
    Write-Host "6 - Show Current Config"
    Write-Host "7 - Exit"
}

function CreateBackend() {
    Title "Terraform Backend"
    Info "Creating storage account..."
    az storage account create `
        --name $script:storage `
        --resource-group $script:rg `
        --location $script:location `
        --sku Standard_LRS `
        --kind StorageV2 `
        --tags $script:tagString | Out-Null
    $key = (az storage account keys list `
        --resource-group $script:rg `
        --account-name $script:storage `
        --query "[0].value" `
        -o tsv)
    Info "Creating tfstate container..."
    az storage container create `
        --name tfstate `
        --account-name $script:storage `
        --account-key $key | Out-Null
    Ok "Terraform backend ready"
    Write-Host "`nUse this backend in Terraform:" -ForegroundColor Cyan
    Write-Host @"
backend "azurerm" {
  resource_group_name  = "$script:rg"
  storage_account_name = "$script:storage"
  container_name       = "tfstate"
  key                  = "$script:environment.terraform.tfstate"
}
"@
}

function CreateSP() {
    Title "Service Principal"
    $sp = az ad sp create-for-rbac `
        --name $script:spname `
        --role Contributor `
        --scopes /subscriptions/$script:subscriptionId `
        --sdk-auth
    Ok "Service Principal created"
    Write-Host "`nSave this JSON in GitHub Secret:"
    Write-Host "AZURE_CREDENTIALS`n"
    Write-Host $sp
}

RunSetup

do {
    Menu
    $choice = Read-Host "Select option"
    switch ($choice) {
        "1" { CreateBackend }
        "2" { CreateSP }
        "3" { az resource list --resource-group $script:rg -o table }
        "4" { CreateBackend; CreateSP }
        "5" { RunSetup }
        "6" { ShowConfig }
        "7" { break }
        default { Err "Invalid option. Please select a valid menu number." }
    }
} while ($choice -ne "7")

Ok "Setup completed."