Import-PSFConfig -Path D:\temp\demo\config-test.json

Write-PSFHostColor @"
  Project Repository: <c='em'>$(Get-PSFConfigValue -FullName MyProject.Build.Repository)</c>
  Artifactory:        <c='em'>$(Get-PSFConfigValue -FullName MyProject.Build.Artifactory)</c>

  Module One S1:      <c='em'>$(Get-PSFConfigValue -FullName SomeModule.SomeSetting)</c>
  Module One S2:      <c='em'>$(Get-PSFConfigValue -FullName SomeModule.SomeSetting2)</c>

  Module Two S1:      <c='em'>$(Get-PSFConfigValue -FullName SomeModule2.SomeSetting)</c>
  Module Two S2:      <c='em'>$(Get-PSFConfigValue -FullName SomeModule2.SomeSetting2)</c>
"@

pause