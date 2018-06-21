$promptCode = @'
$null = New-Item -Path D:\temp\demo -Force -ErrorAction Ignore -ItemType Directory
$null = New-PSDrive -Name demo -PSProvider FileSystem -Root D:\temp\demo -ErrorAction Ignore
Set-Location demo:

$filesRoot = "D:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\Stuttgart - PSFramework Configuration\powershell"
$moduleRoot = "D:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\Stuttgart - PSFramework Configuration\modules\BeerFactory\BeerFactory"
Add-Type -Path 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.348\bin\dbatools.dll'
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
Set-PSFConfig psutil.path.temp D:\Temp -PassThru | Register-PSFConfig
Unregister-PSFConfig -FullName Company.Smtp.Server
Unregister-PSFConfig -FullName beerfactory.fridge.size
'@
Set-Content -Value $promptCode -Path $profile.CurrentUserCurrentHost

$null = New-Item -Path D:\temp\demo -Force -ErrorAction Ignore -ItemType Directory
$null = New-PSDrive -Name demo -PSProvider FileSystem -Root D:\temp\demo -ErrorAction Ignore
Set-Location demo:

$filesRoot = "D:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\Stuttgart - PSFramework Configuration\powershell"
$moduleRoot = "D:\Code\Github\PowerShell-Usergroup-Material\2018\06-June\Stuttgart - PSFramework Configuration\modules\BeerFactory\BeerFactory"
Add-Type -Path 'C:\Program Files\WindowsPowerShell\Modules\dbatools\0.9.348\bin\dbatools.dll'
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
Set-PSFConfig psutil.path.temp D:\Temp -PassThru | Register-PSFConfig
Unregister-PSFConfig -FullName Company.Smtp.Server
Unregister-PSFConfig -FullName beerfactory.fridge.size