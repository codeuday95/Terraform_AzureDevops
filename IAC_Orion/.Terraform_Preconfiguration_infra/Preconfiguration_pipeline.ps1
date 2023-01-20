#NOT REALLY NEED # CAN BE USED AS A SECONDARY OPTION TO CREATE PRE-CONFIGURATION RESOURCES PART2 TO TRIGGER AZURE AUTOMATION
#PREREQIREMENTS : AS FOLOWS :-

# Make Sure $(variable) used are setupped in the pipline variable or variable group or pipline attached keyvault
# Make sure that Automation ac is created with a Runbook having powershell 5.1 (Preconfiguration_automate.ps1) in it to get the vaules from this file
# Automation Ac should be Enabled with a managed identity which is added in subscription scope with "Contibutor" and "useracess administaor role"
#######################################################################
# PIPEINE VARIABLES TO BE USED 
# EnvName
# Location
# SubscriptionId
# ProjectName
# AutomationAccountname
# AutomationAccountRG
# AutomationAccountRunbookName
# PipelinePermissionSP
# SPOBJID
# SPSECRET

$params = @{
    ResourceGroupName = "$(ProjectName)-$(ENVNAME)-Rg"
    Location= "$(Location)"
    SubscriptionId = "$(SubscriptionId)"
    StorageAccountName = ("$(ProjectName)$(ENVNAME)storageac").ToLower().replace("-", "")
    KeyVaultname = ("$(ProjectName)$(ENVNAME)-KV").replace("-", "")
    SPNAME = "$(ProjectName)-$(ENVNAME)-Sp"
    PipelinePermissionSP = "$(PipelinePermissionSP)" # yes/no based on pipline sp Permission
    SPOBJID = "$(SPOBJID)" # SHOULD BE USED WHEN MANUALLY SPECIFING SP TO BE USED
    SPSECRET = "$(SPSECRET)"  # SHOULD BE USED WHEN MANUALLY SPECIFING SP TO BE USED
    AutomationAccountname = "$(AutomationAccountname)"
    AutomationAccountRG = "$(AutomationAccountRG)"
   }

Start-AzAutomationRunbook -AutomationAccountName "$(AutomationAccountname)" -Name "$(AutomationAccountRunbookName)" -ResourceGroupName "$(AutomationAccountRG)"  -Parameters $params