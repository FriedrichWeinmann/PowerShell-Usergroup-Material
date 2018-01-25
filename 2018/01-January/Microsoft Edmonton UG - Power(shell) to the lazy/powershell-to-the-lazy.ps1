 #------------------------------------------------------------------------------------------------# 
 #                                   1) The PowerShell Profile                                    # 
 #------------------------------------------------------------------------------------------------# 

$profile
notepad $profile

# Always loaded on starting a console
# Perfect lcoation to place you personal customizations

# Central profile from networkshare:
# The following line as batch file:
powershell.exe -NoExit -File \\server\share\user\%USERNAME%_profile.ps1

# No SMB available? Running under admin account?
# Load from webserver using the PowerShell Toolkit!
# http://allthingspowershell.blogspot.de/2017/01/the-powershell-toolkit-concepts-benefits.html

 #------------------------------------------------------------------------------------------------# 
 #                               2) Understanding your own behavior                               # 
 #------------------------------------------------------------------------------------------------# 

# <insert from other presentation>

 #------------------------------------------------------------------------------------------------# 
 #                                      3) Creating Aliases                                       # 
 #------------------------------------------------------------------------------------------------# 

# Simple to create:
New-Alias g Get-Command
New-Alias foo Get-Bar

# Greatest enemy:
# "But I'll only have them on my machine? What if I'm somewhere else?"
# a) Roaming Profiles
# b) Networked Profiles (see later)
# c) Get-Command is your friend
# Using global defaults is no excuse for inefficiency!

 #------------------------------------------------------------------------------------------------# 
 #                                        4) Simple Tools                                         # 
 #------------------------------------------------------------------------------------------------# 
function tem
{
    Set-Location -Path C:\Temp
}

# b) Better tooling
function Invoke-Temp
{
    Set-Location -Path C:\Temp
}
New-Alias tem Invoke-Temp
# <Verb>-<Noun> is the recommended function style, making it easier to discover

 #------------------------------------------------------------------------------------------------# 
 #                                       5) Tab Completion                                        # 
 #------------------------------------------------------------------------------------------------# 

# Scenario:
# When using Connect-VIServer, you usually connect to to either vihost1, vihost2 or vihosttest
# Wouldn't it be nice to simply be able to tab through what you want?

# Note:
# This example needs the PSFramework module

Register-PSFTeppScriptblock -Name vihost -ScriptBlock { 'vihost1','vihost2','vitest' }
Register-PSFTeppArgumentCompleter -Command Connect-VIServer -Parameter Server -Name vihost

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

Typical solutions:
- PSUtil (Utility & Convenience)
- PSFramework (General scripting infrastructure, e.g. logging & configuration management)
- dbatools (MSSQL Database Administration)
- Pester & ScriptAnalyzer (Tests and QA)
- PSModuleDevelopment (Development tools)
- PSBuild (Build automation)
- psake (Deploy automation)
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

A complex way for PowerShell projects is available in a module named Plaster
Currently working on a simple way for the module PSModuleDevelopment
#>