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

# Set bad value (not an integer)
Set-PSFConfig -FullName beerfactory.fridge.size -Value "foo"

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


 #----------------------------------------------------------------------------# 
 #                         5) Persisting Module Cache                         # 
 #----------------------------------------------------------------------------# 

# Create common settings (as seen in 3. Module Options )
Set-PSFConfig -Module MyModule -Name Example1 -Value 42 -Validation integer -Initialize -Description "Some arbitrary example setting that will not be part of the cache"
Set-PSFConfig -Module MyModule -Name Example2 -Value $true -Validation bool -Initialize -Description "Some arbitrary example setting that will not be part of the cache"

# Create settings designed for persisting module cache (user should not directly mess with those)
Set-PSFConfig -Module MyModule -Name Example3 -Value @() -ModuleExport -Hidden -Initialize -Description "Some arbitrary example setting that WILL be part of the cache"
Set-PSFConfig -Module MyModule -Name Example4 -Value @() -ModuleExport -Hidden -Initialize -Description "Some arbitrary example setting that WILL be part of the cache"
Set-PSFConfig -Module MyModule -Name Example5 -Value @() -ModuleExport -Hidden -Initialize -Description "Some arbitrary example setting that WILL be part of the cache"

# Show regular settings
Get-PSFConfig -Module MyModule

# Show all settings
Get-PSFConfig -Module MyModule -Force

code "$filesRoot\4-cache.ps1"

# Let's run it!
Start-Process powershell.exe -ArgumentList @('-File', ".\4-Cache.ps1") -WorkingDirectory $filesRoot


 #----------------------------------------------------------------------------# 
 #                               Bonus Material                               # 
 #----------------------------------------------------------------------------# 

 #----------------------------------------------------------------------------# 
 #                                 Validation                                 # 
 #----------------------------------------------------------------------------# 

Register-PSFConfigValidation -Name "foobar" -ScriptBlock {
	Param (
		$Value
	)
	
	$Result = New-Object PSOBject -Property @{
		Success = $True
		Value = $null
		Message = ""
	}
	
	if ($Value -notin "foo", "bar")
	{
		$Result.Message = "Neither foo nor bar!: $Value"
		$Result.Success = $False
		return $Result
	}
	
	$Result.Value = $Value
	
	return $Result
}

Set-PSFConfig -Module Foo -Name Bar -Value "Foo" -Validation foobar
Set-PSFConfig -FullName 'Foo.Bar' -Value 42
Get-PSFConfig -FullName 'Foo.Bar'
Set-PSFConfig -FullName 'Foo.Bar' -Value "bar"
Get-PSFConfig -FullName 'Foo.Bar'


 #----------------------------------------------------------------------------# 
 #                          Handler / Change Events                           # 
 #----------------------------------------------------------------------------# 

$splat = @{
    Module = "Foo"
    Name = "Test"
    Value = 42
    Handler = { Write-PSFMessage -Level Host -Message "Changed setting to $($args[0])" }
}
Set-PSFConfig @splat
Get-PSFConfig 'Foo.Test'
Set-PSFConfig 'Foo.Test' 'Something Else'