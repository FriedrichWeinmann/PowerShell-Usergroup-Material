Import-PSFConfig -Path F:\temp\demo\config-test.json

Write-Host @"
  Project Repository: $(Get-PSFConfigValue -FullName MyProject.Build.Repository)
  Artifactory:        $(Get-PSFConfigValue -FullName MyProject.Build.Artifactory)

  Module One S1:      $(Get-PSFConfigValue -FullName SomeModule.SomeSetting)
  Module One S2:      $(Get-PSFConfigValue -FullName SomeModule.SomeSetting2)

  Module Two S1:      $(Get-PSFConfigValue -FullName SomeModule2.SomeSetting)
  Module Two S2:      $(Get-PSFConfigValue -FullName SomeModule2.SomeSetting2)
"@

pause