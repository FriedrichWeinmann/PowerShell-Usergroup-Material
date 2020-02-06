# failsafe
return

$presentationRoot = 'D:\Code\Github\Presentations\Power(shell) to the lazy'

 #------------------------------------------------------------------------------------------------# 
 #                                   1) The PowerShell Profile                                    # 
 #------------------------------------------------------------------------------------------------# 

$profile
$profile | fl * -Force
code $profile
code "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1"

# Always loaded on starting a console
# Perfect lcoation to place you personal customizations

code "$presentationRoot\Example-Profile.ps1"

# Central profile from networkshare:
# The following line as batch file:
powershell.exe -NoExit -File \\server\share\user\%USERNAME%_profile.ps1

# No SMB available? Running under admin account?
# Load from webserver using the PowerShell Toolkit!
# http://allthingspowershell.blogspot.de/2017/01/the-powershell-toolkit-concepts-benefits.html

 #------------------------------------------------------------------------------------------------# 
 #                               2) Understanding your own behavior                               # 
 #------------------------------------------------------------------------------------------------# 

## a) Cold, hard numbers
# There's a spy on board
notepad (Get-PSReadlineOption).HistorySavePath

# Let's use him to our own ends
# This is mostly black data, but trust me, it works
$Tokens = @()
$ast = [System.Management.Automation.Language.Parser]::ParseFile("$env:APPDATA\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt", [ref]$Tokens, [ref]$null)
$Tokens | Where-Object TokenFlags -eq CommandName | Group-Object Text | Sort-Object Count

## b) Impression
<#
- Is anything particularly tiresome?
- Anything you keep typing again and again?
#>

# Example issue: Select-Object -ExpandProperty
# It's a bother to type
dir | Select-Object -ExpandProperty FullName

# So I create a function to do it for me and gave it an alias that is really short
dir | exp FullName

# This was still too long ... so I added default properties
dir | exp

 #------------------------------------------------------------------------------------------------# 
 #                                      3) Creating Aliases                                       # 
 #------------------------------------------------------------------------------------------------# 

# Simple to create:
Set-Alias g Get-Command
Set-Alias foo Get-Bar

# Greatest enemy:
# "But I'll only have them on my machine? What if I'm somewhere else?"
# a) Roaming Profiles
# b) Networked Profiles (see above)
# c) Get-Command is your friend
# Prefering global defaults due to unifomity is no excuse for inefficiency!

 #------------------------------------------------------------------------------------------------# 
 #                                        4) Simple Tools                                         # 
 #------------------------------------------------------------------------------------------------# 
function tem
{
    Set-Location -Path C:\Temp
}
tem

# b) Better tooling
Remove-Item function:\tem
function Invoke-Temp
{
    Set-Location -Path C:\Temp
}
Set-Alias tem Invoke-Temp
# <Verb>-<Noun> is the recommended function style, making it easier to discover
tem

 #------------------------------------------------------------------------------------------------# 
 #                                       5) Tab Completion                                        # 
 #------------------------------------------------------------------------------------------------# 

# Scenario:
# When using Connect-VIServer, you usually connect to to either vihost1, vihost2 or vihosttest
# Wouldn't it be nice to simply be able to tab through what you want?

# Note:
# This example needs the PSFramework module
# To Install:
#   Install-Module PSFramework
# For more information:
# http://psframework.org

Register-PSFTeppScriptblock -Name vihost -ScriptBlock { 'vihost1','vihost2','vitest' }
Register-PSFTeppArgumentCompleter -Command Connect-VIServer -Parameter Server -Name vihost

# Let's see it in action:
function Get-Alcohol
{
    [CmdletBinding()]
    Param (
        [string]
        $Type
    )

    if ($Type -eq "Mead") { Write-Host "Drinking a horn of $Type" }
    else { Write-Host "Drinking a glass of $Type" }
}

Register-PSFTeppScriptblock -Name "alcohol" -ScriptBlock { 'Beer','Mead','Whiskey','Wine','Vodka','Rum (3y)', 'Rum (5y)', 'Rum (7y)' }
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Type -Name alcohol

# For older OS: TabExpansionPlusPlus

 #------------------------------------------------------------------------------------------------# 
 #                                        6) Default Value                                        # 
 #------------------------------------------------------------------------------------------------# 

# Usually connect to the same computer?
# Why not set it as the default value?
$PSDefaultParameterValues.Add("Connect-VIServer:Server", 'vihost1')

# Connection Credentials?
# Run this once (you may need to create the folder first):
Get-Credential | Export-Clixml "$env:APPDATA\WindowsPowerShell\cred.xml"

# Put this in profile:
$cred = Import-Clixml -Path "$env:APPDATA\WindowsPowerShell\cred.xml"
$PSDefaultParameterValues.Add("Connect-VIServer:User", $cred.UserName)
$PSDefaultParameterValues.Add("Connect-VIServer:Password", $cred.GetNetworkCredential().Password)

# Default values in practice
function Get-Test
{
    [CmdletBinding()]
    Param (
        $Foo,
        $Bar
    )
    Write-Host "$Foo is $Bar"
}
$PSDefaultParameterValues.Add("Get-Test:Foo", "DefaultValue")
Get-Test -Bar "Something"
Get-Test -Bar "Foo" -Foo "Bar"

 #------------------------------------------------------------------------------------------------# 
 #                                  7) Stealing is best practice                                  # 
 #------------------------------------------------------------------------------------------------# 

<#
For many problems, there already is a solution.
Maybe even a simple one.

There is no shame in reusing them.
Search for them and keep up with the available options.
Not always is it necessary to create it anew.

A few solutions to common problems:
- PSUtil (Utility & Convenience)
- PSFramework (General scripting infrastructure, e.g. logging & configuration management)
- dbatools (MSSQL Database Administration)
- Pester & ScriptAnalyzer (Tests and QA)
- PSModuleDevelopment (Development tools)
- PSDeploy (Deploy automation)
- psake (Build automation)
#>

 #------------------------------------------------------------------------------------------------# 
 #                                         8) Toolmaking                                          # 
 #------------------------------------------------------------------------------------------------# 

# Show example scripts 1-5
# From a simple batch-style script to a reusable function
# Next step after examples: Package it into a module and publish it.

 #------------------------------------------------------------------------------------------------# 
 #                                      9) Create Templates!                                      # 
 #------------------------------------------------------------------------------------------------# 

<#
If you keep creating the same kind of document - powershell or not - design a simple templating system:
- Setup a layout once
- Create it with a simple command available in your default console

Existing templating solutions:
- plaster : Complex project, quite a bit overhead, flexible template product
- PSModuleDevelopment : Simple and easy to use at the cost of some of the power of plaster
#>

# Creating a template
code C:\Temp\þnameþ.ps1

New-PSMDTemplate -FilePath C:\Temp\þnameþ.ps1 -TemplateName MyFunction -Force


 #----------------------------------------------------------------------------# 
 #                               10) PSReadline                               # 
 #----------------------------------------------------------------------------# 

<#
Can be copied to older OS!!!
Commonly unknown keybindings
Creating keybindings
#>

code D:\Code\Github\PSUtil\PSUtil\internal\keybindings\addToHistory.ps1

 #------------------------------------------------------------------------------------------------# 
 #                                             Notes                                              # 
 #------------------------------------------------------------------------------------------------# 

<#
about_speaker:
Github: https://github.com/FriedrichWeinmann
Twitter: @FredWeinmann
Blog: https://allthingspowershell.blogspot.de
Website: https://psframework.org
slack: https://psframework.slack.com
#>

# Afterwords:
# Being lazy about headers:
"Demo Header" | New-PSMDHeader -Width 80 | cast String