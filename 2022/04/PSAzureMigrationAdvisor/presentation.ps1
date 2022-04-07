# failsafe
return

<#
Name: Fred
Job: Customer Engineer @Microsoft
Twitter: @FredWeinmann
Github: github.com/FriedrichWeinmann

Projects:
+ https://psframework.org
+ https://admf.one
#>

$presentationRoot = 'C:\Sessions\PSAzureMigrationAdvisor'

# PSAzureMigrationAdvisor
# https://github.com/FriedrichWeinmann/PSAzureMigrationAdvisor
code $presentationRoot\azuread.sample.ps1
Get-Item $presentationRoot\azuread.sample.ps1 | Read-AzScriptFile
Get-Item $presentationRoot\azuread.sample.ps1 | Read-AzScriptFile | Export-Excel .\output.xlsx
Invoke-Item .\output.xlsx

# Danger Zone: Manual Intervention needed:
Get-Item $presentationRoot\azuread.sample.ps1 | Convert-AzScriptFile

# Feature incoming imminently:
Get-AzureDevopsProject -Organization MyOrg | Get-AdsPowerShellFile | Read-AzScriptFile

<#
Intermediate Roadmap:
Scan your script for scopes/permissions needed
#>

#-> Show Data Definitions

# Refactor
# https://github.com/FriedrichWeinmann/Refactor


# Example: Refactor Command
Get-Command -Module Refactor

code $presentationRoot\commands.ps1
Read-ReScriptCommand -Path $presentationRoot\commands.ps1

Copy-Item $presentationRoot\commands.ps1 -Destination $presentationRoot\commands-demo.ps1 -Force

code $presentationRoot\command.transform.psd1
Import-ReTokenTransformationSet -Path $presentationRoot\command.transform.psd1
$result = Get-item $presentationRoot\commands-demo.ps1 | Convert-ReScriptFile -Backup
$result.Messages
$result.Results

# Example: Breaking Changes
code $presentationRoot\beer.ps1
code $presentationRoot\fridge.break.psd1

Import-ReBreakingChange -Path $presentationRoot\fridge.break.psd1
Search-ReBreakingChange -Path $presentationRoot\beer.ps1 -Module fridge -FromVersion 1.0.0 -ToVersion 1.1.0
Search-ReBreakingChange -Path $presentationRoot\beer.ps1 -Module fridge -FromVersion 1.0.0 -ToVersion 2.0.0
Search-ReBreakingChange -Path $presentationRoot\beer.ps1 -Module fridge -FromVersion 1.0.0 -ToVersion 3.0.0

$data = Search-ReBreakingChange -Path $presentationRoot\beer.ps1 -Module fridge -FromVersion 1.0.0 -ToVersion 3.0.0
$data[1] | fl *

Search-ReBreakingChange -Path $presentationRoot\beer.ps1 -Module @(
	@{ Name = 'fridge'; FromVersion = '1.0.0'; ToVersion = '3.0.0' }
)