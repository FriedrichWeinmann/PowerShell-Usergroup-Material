Write-PSFMessage -Level Host -Message "Defining configurations"

# Create regular settings
Set-PSFConfig -Module MyModule -Name Example1 -Value 42 -Validation integer -Initialize -Description "Some arbitrary example setting that will not be part of the cache"
Set-PSFConfig -Module MyModule -Name Example2 -Value $true -Validation bool -Initialize -Description "Some arbitrary example setting that will not be part of the cache"

# Create settings designed for persisting module cache (user should not mess with those)
Set-PSFConfig -Module MyModule -Name Example3 -Value @() -ModuleExport -Hidden -Initialize -Description "Some arbitrary example setting that WILL be part of the cache"
Set-PSFConfig -Module MyModule -Name Example4 -Value @() -ModuleExport -Hidden -Initialize -Description "Some arbitrary example setting that WILL be part of the cache"
Set-PSFConfig -Module MyModule -Name Example5 -Value @() -ModuleExport -Hidden -Initialize -Description "Some arbitrary example setting that WILL be part of the cache"

Write-PSFMessage -Level Host -Message "Importing Module Cache"
Import-PSFConfig -ModuleName MyModule

Write-PSFMessage -Level Host -Message "Old Example3 Values <c='em'>$((Get-PSFConfigValue -FullName 'MyModule.Example3') -join ',')</c>"

[array]$value = Get-PSFConfigValue -FullName 'MyModule.Example3'
$value += ($value.Count + 1)
Set-PSFConfig -Module MyModule -Name Example3 -Value $value
Write-PSFMessage -Level Host -Message "New Example3 Values <c='em'>$((Get-PSFConfigValue -FullName 'MyModule.Example3') -join ',')</c>"

Write-PSFMessage -Level Host -Message "Persisting Module Cache"
Export-PSFConfig -ModuleName MyModule

pause