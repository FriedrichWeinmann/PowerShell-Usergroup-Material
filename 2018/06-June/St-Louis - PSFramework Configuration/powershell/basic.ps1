Import-Module PSUtil
Write-Host " "
Write-Host "Current value for 'PSUtil.Path.Temp' is $(Get-PSFConfigValue -FullName psutil.path.temp)"
pause