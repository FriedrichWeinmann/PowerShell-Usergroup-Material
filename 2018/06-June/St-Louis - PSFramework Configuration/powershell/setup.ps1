$promptCode = @'
$null = New-Item -Path F:\temp\demo -Force -ErrorAction Ignore -ItemType Directory
$null = New-PSDrive -Name demo -PSProvider FileSystem -Root F:\temp\demo -ErrorAction Ignore
Set-Location demo:
Get-ChildItem -Path demo:\ -ErrorAction Ignore | Remove-Item -Force -Recurse

$filesRoot = "F:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\St-Louis - PSFramework Configuration\powershell"
$moduleRoot = "F:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\St-Louis - PSFramework Configuration\modules\BeerFactory\BeerFactory"
Add-Type -Path 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.345\bin\dbatools.dll'
function prompt {
    $string = ""
    try
    {
        $history = Get-History -ErrorAction Ignore
        if ($history)
        {
            $string = "[<c='red'>$([Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime))</c>] "
        }
    }
    catch { }
    Write-PSFHostColor -String "$($string)Demo:" -NoNewLine
    
    "> "
}
Import-Module PSUtil
Set-PSFConfig psutil.path.temp F:\Temp -PassThru | Register-PSFConfig
Unregister-PSFConfig -FullName Company.Smtp.Server
Unregister-PSFConfig -FullName beerfactory.fridge.size
Remove-Item "C:\Users\Friedrich\AppData\Roaming\WindowsPowerShell\PSFramework\Config\mymodule-1.json" -Force -ErrorAction Ignore
'@
Set-Content -Value $promptCode -Path $profile.CurrentUserCurrentHost

$null = New-Item -Path F:\Temp\demo -Force -ErrorAction Ignore -ItemType Directory
$null = New-PSDrive -Name demo -PSProvider FileSystem -Root F:\Temp\demo -ErrorAction Ignore
Set-Location demo:
Get-ChildItem -Path demo:\ -ErrorAction Ignore | Remove-Item -Force -Recurse

$filesRoot = "F:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\St-Louis - PSFramework Configuration\powershell"
$moduleRoot = "F:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\St-Louis - PSFramework Configuration\modules\BeerFactory\BeerFactory"
Add-Type -Path 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.345\bin\dbatools.dll'
function prompt {
    $string = ""
    try
    {
        $history = Get-History -ErrorAction Ignore
        if ($history)
        {
            $string = "[<c='red'>$([Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime))</c>] "
        }
    }
    catch { }
    Write-PSFHostColor -String "$($string)Demo:" -NoNewLine
    
    "> "
}
Import-Module PSUtil
Set-PSFConfig psutil.path.temp F:\Temp -PassThru | Register-PSFConfig
Unregister-PSFConfig -FullName Company.Smtp.Server
Unregister-PSFConfig -FullName beerfactory.fridge.size
Remove-Item "C:\Users\Friedrich\AppData\Roaming\WindowsPowerShell\PSFramework\Config\mymodule-1.json" -Force -ErrorAction Ignore