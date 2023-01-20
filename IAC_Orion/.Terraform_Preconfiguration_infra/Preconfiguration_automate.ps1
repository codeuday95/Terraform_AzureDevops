#NOT REALLY NEED # CAN BE USED AS A SECONDARY OPTION TO CREATE PRE-CONFIGURATION RESOURCES @PART1 AZURE AUTOMATION 
#PREREQIREMENTS : AS FOLOWS :-
# This Script need to be ran to create Preconfigration before creating Infrasture
# Make sure that Automation ac is created with a Runbook having powershell 5.1 (Preconfiguration_automate.ps1) in it to get the vaules from this file Preconfiguration_pipline.ps1
# Automation Ac should be Enabled with a manged identity which is added in subscription scope with Contibutor and useracess administaor role
################################################################################################
# CODE USE FULL IN DEBUGING
# code for completly delete keyvault
# az keyvault purge --subscription 8748e8f0-XXXXX -n "Orion-Test-Dev-Keyvault"


################################################################################################

param(
    [string]$ResourceGroupName,
    [string]$SubscriptionId,
    [string]$Location,
    [string]$StorageAccountName,
    [string]$KeyVaultName,
    [string]$AutomationAccountName,
    [string]$AutomationAccountRG,
    [string]$PipelinePermissionSP,
    [string]$SPNAME,
    [string]$SPOBJID,
    [string]$SPSECRET
)
Connect-AzAccount -Identity
Select-AzSubscription -SubscriptionId $SubscriptionId

$ContainerName = 'tfstate'
##########################HARD CODED VAULE USE THIS IF NEED TO PASS #################################################
# $ResourceGroupName = "Orion-Test-DEV-Rg"
# $Location= "EastUS"
# $StorageAccountName = ("OriontestDEVstorageac").ToLower()
# $KeyVaultname = "Orion-Test-DEV-Keyvault"
# $SPNAME = "Orion-Test-DEV-Sp"
# $PipelinePermissionSP = "NO" # NO (Depend on the pipeline SP)
# $SPOBJID = "3885b1b0-XXX"
# $SPSECRET = "zsV8Q~cXXX" 
# $AutomationAccountname = "MeshVM"
# $AutomationAccountRG = "OMEGA-RG-DEV"
# $AutomationAccountid = "9d01a97a-XXX"
##############################################################################

# check if resource group exists
if(!(Get-AzResourceGroup -Name $ResourceGroupName -ErrorAction SilentlyContinue))
{
    # resource group does not exist, create it
    New-AzResourceGroup -Name $ResourceGroupName -Location $Location
}

# check if storage account exists
if(!(Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -ErrorAction SilentlyContinue))
{
    # storage account does not exist, create it
    New-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName -Location $Location -SkuName Standard_LRS
}

Function CreateStorageContainer  
{  
    Write-Host -ForegroundColor Green "Creating storage container.."  
    ## Get the storage account in which container has to be created  
    $storageAcc = Get-AzStorageAccount -ResourceGroupName $ResourceGroupName -Name $StorageAccountName      
    ## Get the storage account context  
    $ctx = $storageAcc.Context      
 
    ## Check if the storage container exists  
    if(Get-AzStorageContainer -Name $ContainerName -Context $ctx -ErrorAction SilentlyContinue)  
    {  
        Write-Host -ForegroundColor Magenta $ContainerName "- container already exists."  
    }  
    else  
    {  
       Write-Host -ForegroundColor Magenta $ContainerName "- container does not exist."   
       ## Create a new Azure Storage Account  
       New-AzStorageContainer -Name $ContainerName -Context $ctx -Permission Container  
    }       
} 

#calling function  CreateStorageContainer
CreateStorageContainer

#GET RESOURCE GROUP ID
$resourceGroup = Get-AzResourceGroup -Name $ResourceGroupName 
$resourceGroupId = $resourceGroup.ResourceId

#SP NEW CODE
if ($PipelinePermissionSP -eq "YES" ) {
    # CREATE NEW SP
    $sp = New-AzADServicePrincipal -DisplayName $SPNAME -role "Contributor" -Scope $resourceGroupId
    # CREATE NEW SP SECRET WITH 1 YEAR
    $sp = Get-AzureRmADServicePrincipal -DisplayName $SPNAME 
    $FetchAPPID = $sp.AppID
    $applicationId = $FetchAPPID
    $startDate = Get-Date
    $endDate = $startDate.AddYears(1)
    $newAppCredential = Get-AzADApplication -ApplicationId $applicationId | New-AzADAppCredential -StartDate $startDate -EndDate $endDate
    $SPSECRET = $newAppCredential.SecretText
}

#ASSIGN ROLE TO RG FOR SP CREATED OR USED FOR TERRAFORM
New-AzRoleAssignment -ObjectId $SPOBJID -RoleDefinitionName Contributor -Scope $resourceGroupId

# CREATE A NEW KEYVAULT WITH RABC
New-AzKeyVault -VaultName $KeyVaultname -ResourceGroupName $ResourceGroupName -Location $Location -EnableRbacAuthorization

# GET KEYVAULT ID
$KeyVault = Get-AzKeyVault -VaultName $KeyVaultname -ResourceGroupName $ResourceGroupName
$KeyVaultId = $KeyVault.ResourceId

# GET AUTOMATION AC ID
$principalID = (Get-AzAutomationAccount -ResourceGroupName OMEGA-RG-DEV -Name MeshVM).Identity.PrincipalId

# ASSIGN TERRAFORM SP ACCESS
New-AzRoleAssignment -ObjectId $SPOBJID -RoleDefinitionName "Key Vault Secrets Officer" -Scope $KeyVaultId
New-AzRoleAssignment -ObjectId $principalID -RoleDefinitionName "Key Vault Secrets Officer" -Scope $KeyVaultId
Start-Sleep -Seconds 120

# GET STORAGE AC KEY
$STORAGE_ACCOUNT_KEY=(Get-AzStorageAccountKey -ResourceGroupName $ResourceGroupName -Name $StorageAccountName)[0].value
#$env:ARM_ACCESS_KEY=$STORAGE_ACCOUNT_KEY

$Secret1 = ConvertTo-SecureString -String $STORAGE_ACCOUNT_KEY -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KeyVaultname -Name $StorageAccountName-secret -SecretValue $Secret1

$Secret2 = ConvertTo-SecureString -String $SPSECRET -AsPlainText -Force
Set-AzKeyVaultSecret -VaultName $KeyVaultname -Name $SPNAME-secret -SecretValue $Secret2

#Set-AzKeyVaultAccessPolicy -VaultName testumesh001 -ObjectId $SPOBJID -PermissionsToSecrets all -PermissionsToKeys all -PermissionsToCertificates all
#Set-AzKeyVaultAccessPolicy -VaultName 'testumesh001' -ServicePrincipalName '9ab7e300-e8d0-4e39-81ef-30923a23b8fb' -PermissionsToSecrets Get,Set