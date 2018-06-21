Write-Host " "
Write-PSFHostColor -String "1) Configuration Setting <c='em'>before</c> module import"
Get-PSFConfig beerfactory.fridge.size | Out-String | Out-Host

Write-Host " "
Write-PSFHostColor -String "2) Importing Module: <c='sub'>BeerFactory</c>"
Import-Module "D:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\Stuttgart - PSFramework Configuration\modules\BeerFactory\BeerFactory\BeerFactory.psd1"

Write-Host " "
Write-PSFHostColor -String "3) Configuration Setting <c='em'>after</c> module import"
Get-PSFConfig beerfactory.fridge.size | Out-String | Out-Host
pause