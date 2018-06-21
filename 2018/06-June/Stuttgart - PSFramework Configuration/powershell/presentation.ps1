# Failsafe
break

 #----------------------------------------------------------------------------# 
 #                                 1) Basics                                  # 
 #----------------------------------------------------------------------------# 

# Values
Get-PSFConfig psutil.keybinding.*

# Get Specific setting
Get-PSFConfig psutil.path.temp
# Check in other process
Start-Process -WorkingDirectory $filesRoot -FilePath powershell.exe -ArgumentList @('-File', 'basic.ps1')

# Change setting and check again
Set-PSFConfig psutil.path.temp C:\Temp
Get-PSFConfig psutil.path.temp
Get-PSFConfigValue -FullName psutil.path.temp
Start-Process -WorkingDirectory $filesRoot -FilePath powershell.exe -ArgumentList @('-File', 'basic.ps1')

# Register Setting and check again
Register-PSFConfig -FullName psutil.path.temp
Start-Process -WorkingDirectory $filesRoot -FilePath powershell.exe -ArgumentList @('-File', 'basic.ps1')

# --> Back to presentation!


 #----------------------------------------------------------------------------# 
 #                            2) Script Management                            # 
 #----------------------------------------------------------------------------# 

# The script
code "$filesRoot\1-Script.ps1"

# Run it
& "$filesRoot\1-Script.ps1"

# Change setting and try gain
Set-PSFConfig Company.Smtp.Server smtp.beerfactory.org
& "$filesRoot\1-Script.ps1"
Start-Process -WorkingDirectory $filesRoot -FilePath powershell.exe -ArgumentList @('-File', '1-script.ps1', '-Wait')
# Still the old value!
# --> Register new value (or deploy by GPO)

# Register and try again
Set-PSFConfig Company.Smtp.Server smtp.beerfactory.org -PassThru | Register-PSFConfig
Start-Process -WorkingDirectory $filesRoot -FilePath powershell.exe -ArgumentList @('-File', '1-script.ps1', '-Wait')


 #----------------------------------------------------------------------------# 
 #                             3) Module Options                              # 
 #----------------------------------------------------------------------------# 

# Let's take a look
Import-Module "$moduleRoot\BeerFactory.psd1"
Get-PSFConfig -Module beerfactory

# The definition
code "$moduleRoot\internal\configurations\configuration.ps1"

# Use it later in the module
code "$moduleRoot\functions\New-Beer.ps1"

# Update the setting and persist it
Set-PSFConfig beerfactory.fridge.size 12 -PassThru | Register-PSFConfig

# See the magic happening
Start-Process powershell.exe -ArgumentList @('-File', ".\2-Module-Demo.ps1") -WorkingDirectory $filesRoot


 #----------------------------------------------------------------------------# 
 #                                  4) CI/CD                                  # 
 #----------------------------------------------------------------------------# 

# Define Settings
$configToExport = @()
$configToExport += Set-PSFConfig -FullName "MyProject.Build.Repository" -Value "foo" -SimpleExport -PassThru
$configToExport += Set-PSFConfig -FullName "MyProject.Build.Artifactory" -Value "bar" -SimpleExport -PassThru
$configToExport += Set-PSFConfig -FullName "SomeModule.SomeSetting" -Value "1" -SimpleExport -PassThru
$configToExport += Set-PSFConfig -FullName "SomeModule.SomeSetting2" -Value 2 -SimpleExport -PassThru
$configToExport += Set-PSFConfig -FullName "SomeModule2.SomeSetting" -Value "3" -SimpleExport -PassThru
$configToExport += Set-PSFConfig -FullName "SomeModule2.SomeSetting2" -Value $true -SimpleExport -PassThru

# Write the configuration file
$configToExport | Export-PSFConfig -OutPath .\config-test.json

code .\config-test.json
code "$filesRoot\3-CI-CD-Script.ps1"

Start-Process powershell.exe -ArgumentList @('-File', ".\3-CI-CD-Script.ps1") -WorkingDirectory $filesRoot