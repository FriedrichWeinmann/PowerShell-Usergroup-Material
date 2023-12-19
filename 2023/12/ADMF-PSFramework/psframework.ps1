# failsafe
return

# PSFramework.org
# github.com/FriedrichWeinmann/PowerShell-Usergroup-Material

$presentationRoot = 'C:\Code\github\PowerShell-Usergroup-Material\2023\12\ADMF-PSFramework'

#----------------------------------------------------------------------------# 
#                             Runspace Workflows                             # 
#----------------------------------------------------------------------------# 

code "$presentationRoot\PSF-01-Workflows-001.ps1"


#----------------------------------------------------------------------------# 
#                           Path Parameter Classes                           # 
#----------------------------------------------------------------------------# 

code "$presentationRoot\PSF-02-Pathing.ps1"


#----------------------------------------------------------------------------# 
#                                  Throttle                                  # 
#----------------------------------------------------------------------------#

# Do it live!
$throttle = New-PSFThrottle -Interval 10s -Limit 3
$throttle.GetSlot()
$throttle.NotBefore = (Get-Date).AddSeconds(5)
$throttle.GetSlot()

#----------------------------------------------------------------------------# 
#                              Support Package                               # 
#----------------------------------------------------------------------------# 

# Do it live!
New-PSFSupportPackage -Path .
Expand-Archive -Path .\powershell_support_pack_2023_12_14-21_01_32.zip -DestinationPath .
$data = Import-PSFClixml .\powershell_support_pack_2023_12_14-21_01_32.cliDat
$data.History
$data.ConsoleBuffer
$data.PSErrors
$data.Modules

Register-PSFSupportDataProvider -Name MyModule.Answer -ScriptBlock { 42 }
Remove-Item .\po*
New-PSFSupportPackage -Path .
Expand-Archive .\powershell_support_pack_2023_12_14-21_03_19.zip -DestinationPath .
$data = Import-PSFClixml .\powershell_support_pack_2023_12_14-21_03_19.cliDat
$data.'_MyModule.Answer'

#----------------------------------------------------------------------------# 
#                    Argument Transformation Scriptblock                     # 
#----------------------------------------------------------------------------# 

code "$presentationRoot\PSF-03-Transformers.ps1"


#----------------------------------------------------------------------------# 
#                             Protected Command                              # 
#----------------------------------------------------------------------------# 

code "$presentationRoot\PSF-04-UseProtection.ps1"


#----------------------------------------------------------------------------# 
#                           ConvertTo-PSFHashtable                           # 
#----------------------------------------------------------------------------#

code "$presentationRoot\PSF-05-Hashtables-Rock.ps1"


#----------------------------------------------------------------------------# 
#                               Message Colors                               # 
#----------------------------------------------------------------------------# 

# Do it live!
Write-PSFMessage -Level Host -Message "Hallelujah!"
Register-PSFMessageColorTransform -Name MyModule.Hail -Color Green -IncludeTags Hail
Write-PSFMessage -Level Host -Message "Hallelujah!"
Write-PSFMessage -Level Host -Message "Hallelujah!" -Tag hail