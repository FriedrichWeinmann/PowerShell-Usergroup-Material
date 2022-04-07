<#
Source:
https://github.com/nordicinfrastructureconference/2017/blob/061009132c250673280be5682c78bca94625eb08/Take%20your%20Azure%20AD%20Management%20Skills%20to%20the%20Next%20Level%20with%20Azure%20AD%20Graph%20API%20and%20PowerShell/AzureADPowerShellQuickstartConnect.ps1
#>
# Azure AD v2 PowerShell Quickstart Connect

# Connect with Credential Object
$AzureAdCred = Get-Credential
Connect-MgGraph -Credential $AzureAdCred

# Connect with Modern Authentication
Connect-MgGraph

# Explore some objects
Get-MgUser -All $true

# Getting users by objectid, upn and searching
Get-MgUser -UserId '<objectid>'
Get-MgUser -UserId jan.vidar@elven.no
Get-MgUser -Search "Jan Vidar"

# Explore deeper via object variable
$AADUser = Get-MgUser -UserId jan.vidar@elven.no

$AADUser | Get-Member

$AADUser | FL
$AADuser | Update-MgUser
# Look at licenses and history for enable and disable
$AADUser.AssignedPlans
# Or
Get-MgUser -UserId jan.vidar@elven.no | Select-Object -ExpandProperty AssignedPlans

# More detail for individual licenses for plans
Get-MgUserLicenseDetail -ObjectId $AADUser.ObjectId | Select-Object -ExpandProperty ServicePlans

# Get your tenants subscriptions, and explore details
Get-MgSubscribedSku | FL
Get-MgSubscribedSku | Select SkuPartNumber -ExpandProperty PrepaidUnits
Get-MgSubscribedSku | Select SkuPartNumber -ExpandProperty ServicePlans

# Invalidate Users Refresh tokens
Invoke-MgInvalidateUserRefreshTokenByRef -ObjectId $AADUser.ObjectId


