 #----------------------------------------------------------------------------# 
 #                               About_Speaker                                # 
 #----------------------------------------------------------------------------# 

<#
Name: Fred
FullName: Friedrich Weinmann
Job: Premier Field Engineer @ Microsoft
Twitter: @FredWeinmann
Github: https://github.com/FriedrichWeinmann
Website: https://psframework.org

PowerShell Modules:
Owner:
PSFramework | PSModuleDevelopment | PSUtil | MailDaemon | FileType | MsgToEml | Monitoring
MSGraph | Krbtgt | PSJukeBox | ExplorerFolder | GPOTools | EbookBuilder | GPWmiFilter

Contributor:
dbatools | dbachecks | JEAnalyzer | EventList | Exch-Rest | ReportingServicesTools | ...
#>

 #----------------------------------------------------------------------------# 
 #                                 Quickstart                                 # 
 #----------------------------------------------------------------------------# 

code "$filesRoot\þnameþ.ps1"
# þ : ALT + 0254

New-PSMDTemplate -FilePath "$filesRoot\þnameþ.ps1" -TemplateName MyScript
Invoke-PSMDTemplate MyScript
code .\script.ps1
imt MyScript

 #----------------------------------------------------------------------------# 
 #                                Architecture                                # 
 #----------------------------------------------------------------------------# 

<#
Template Raws --> Recorded and stored in "Store"
Invoked templates --> Retrieve "compiled" template and execute it

Template stores are extensible
--> Modules can ship their own templates
#>

 #----------------------------------------------------------------------------# 
 #                             Setting up a store                             # 
 #----------------------------------------------------------------------------# 

# List stores
Get-PSMDTemplate

# Handle configuration
Get-PSFConfig -Module PSModuleDevelopment
Get-PSFConfig -Module PSModuleDevelopment -Name *store* | Select Name, Value
Set-PSFConfig -FullName 'PSModuleDevelopment.Template.Store.Presentation' -Value D:\temp\demo
New-PSMDTemplate -FilePath "$filesRoot\þnameþ.ps1" -TemplateName MyScript -OutStore Presentation -Version '1.0.1'
Get-PSMDTemplate MyScript
Get-PSMDTemplate MyScript -All
Invoke-PSMDTemplate MyScript

# Make PSMOduleDevelopment REMEMBER the custom store
Register-PSFConfig -FullName 'PSModuleDevelopment.Template.Store.Presentation'

# Management by policy

<#
Key:   HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WindowsPowerShell\PSFramework\Config\Default
Name:  PSModuleDevelopment.Template.Store.Company
Value: String:\\server\Share\Templates
#>


 #----------------------------------------------------------------------------# 
 #                        Creating a project template                         # 
 #----------------------------------------------------------------------------# 

# Setting up a basic module
$folder = New-Item "$filesRoot\Module" -ItemType Directory
New-ModuleManifest "$filesRoot\Module\þnameþ.psd1" -RootModule 'þnameþ.psm1'

# Record & Invoke
New-PSMDTemplate -TemplateName MyModule -ReferencePath $folder.FullName -OutStore Presentation -Version '1.0.0'  -Description "Basic module template"
Invoke-PSMDTemplate MyModule

# The optional manifest file
Invoke-PSMDTemplate PSMDTemplateReference -OutPath "$filesRoot\Module"
New-PSMDTemplate -ReferencePath $folder.FullName -OutStore Presentation

 #----------------------------------------------------------------------------# 
 #                            Template Management                             # 
 #----------------------------------------------------------------------------# 

# Template versions

# Default parameter values
Get-PSFConfig -Module PSModuleDevelopment

# Explicitly binding parameters
Invoke-PSMDTemplate MyModule -Parameters @{
    Name = 'MyModule2'
    Description = 'Does something (maybe)'
    Company = 'Customer Ltd.'
}

# The variable identifier
# þ
Get-PSFConfig -Module PSModuleDevelopment
# New Identifier: ___
Set-PSFConfig -FullName PSModuleDevelopment.Template.Identifier -Value '___'

# Encoding
Get-PSFConfigValue -FullName 'PSFramework.Text.Encoding.DefaultWrite'
Invoke-PSMDTemplate MyScript -Encoding UTF8NoBom

# Binary files
Get-PSFConfigValue 'PSModuleDevelopment.Template.BinaryExtensions'

 #----------------------------------------------------------------------------# 
 #                               The TODO List                                # 
 #----------------------------------------------------------------------------# 

<#
- Constrain parameter names to sane name content (Numbers, Letters, _, -)
- Native Multiple Choice
- Parameter Descriptions
- Optional Files & Folders
- Post-Creation Scriptblocks
- Pre- & Post-File Scriptblocks
- Nested / Chained Templates
#>

# Golden Rule:
# Always stay easy to use!


 #----------------------------------------------------------------------------# 
 #                               Documentation                                # 
 #----------------------------------------------------------------------------# 

# https://psframework.org/documentation/documents/psmoduledevelopment/templates.html


 #----------------------------------------------------------------------------# 
 #                              Custom Examples                               # 
 #----------------------------------------------------------------------------# 

# Template for Documentation
Get-PSMDTemplate
imt PSFDocumentation
code .\demodoc.md

# Templates for the book


 #----------------------------------------------------------------------------# 
 #                             Default Templates                              # 
 #----------------------------------------------------------------------------# 

Get-PSMDTemplate -Store PSModuleDevelopment
Invoke-PSMDTemplate PSFProject
