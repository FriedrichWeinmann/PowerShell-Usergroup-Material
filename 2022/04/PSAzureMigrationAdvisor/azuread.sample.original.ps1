<#
Source:
https://github.com/nordicinfrastructureconference/2017/blob/061009132c250673280be5682c78bca94625eb08/Take%20your%20Azure%20AD%20Management%20Skills%20to%20the%20Next%20Level%20with%20Azure%20AD%20Graph%20API%20and%20PowerShell/AzureADPowerShellQuickstartConnect.ps1
#>
# Azure AD v2 PowerShell Quickstart Connect

# Connect with Credential Object
$AzureAdCred = Get-Credential
Connect-AzureAD -Credential $AzureAdCred

# Connect with Modern Authentication
Connect-AzureAD

# Explore some objects
Get-AzureADUser -All $true

# Getting users by objectid, upn and searching
Get-AzureADUser -ObjectId '<objectid>'
Get-AzureADUser -ObjectId jan.vidar@elven.no
Get-AzureADUser -SearchString "Jan Vidar"

# Explore deeper via object variable
$AADUser = Get-AzureADUser -ObjectId jan.vidar@elven.no

$AADUser | Get-Member

$AADUser | FL
$AADuser | Set-AzureADUser
# Look at licenses and history for enable and disable
$AADUser.AssignedPlans
# Or
Get-AzureADUser -ObjectId jan.vidar@elven.no | Select-Object -ExpandProperty AssignedPlans

# More detail for individual licenses for plans
Get-AzureADUserLicenseDetail -ObjectId $AADUser.ObjectId | Select-Object -ExpandProperty ServicePlans

# Get your tenants subscriptions, and explore details
Get-AzureADSubscribedSku | FL
Get-AzureADSubscribedSku | Select SkuPartNumber -ExpandProperty PrepaidUnits
Get-AzureADSubscribedSku | Select SkuPartNumber -ExpandProperty ServicePlans

# Invalidate Users Refresh tokens
Revoke-AzureADUserAllRefreshToken -ObjectId $AADUser.ObjectId


