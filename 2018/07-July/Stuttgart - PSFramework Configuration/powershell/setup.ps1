$setupCode = {
    #TODO: Update per Computer, do not copy for other presentations
    Set-PSFConfig psutil.path.temp D:\Temp -PassThru | Register-PSFConfig

    $rootPresentationPath = Get-PSFConfigValue -FullName PSDemo.Path.PresentationsRoot -Fallback "F:\Code\Github"
    $tempPath = Get-PSFConfigValue -FullName psutil.path.temp -Fallback C:\temp

    $null = New-Item -Path $tempPath\demo -Force -ErrorAction Ignore -ItemType Directory
    $null = New-PSDrive -Name demo -PSProvider FileSystem -Root $tempPath\demo -ErrorAction Ignore
    Set-Location demo:
    Get-ChildItem -Path demo:\ -ErrorAction Ignore | Remove-Item -Force -Recurse

    $filesRoot = Join-Path $rootPresentationPath "PowerShell-Usergroup-Material\2018\07-July\Stuttgart - PSFramework Configuration\powershell"
    $moduleRoot = Join-Path $rootPresentationPath "PowerShell-Usergroup-Material\2018\07-July\Stuttgart - PSFramework Configuration\modules\BeerFactory\BeerFactory"
    Add-Type -Path (Join-Path (Get-Module dbatools -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase "bin\dbatools.dll")
    function prompt {
        $string = ""
        try
        {
            $history = Get-History -ErrorAction Ignore
            if ($history)
            {
                $insert = ([Sqlcollaborative.Dbatools.Utility.DbaTimeSpanPretty]($history[-1].EndExecutionTime - $history[-1].StartExecutionTime)).ToString().Replace(" s", " s ")
                $padding = ""
                if ($insert.Length -lt 9) { $padding = " " * (9 - $insert.Length) }
                $string = "$padding[<c='red'>$insert</c>] "
            }
        }
        catch { }
        Write-PSFHostColor -String "$($string)Demo:" -NoNewLine
        
        "> "
    }
    Import-Module PSUtil
    
    Unregister-PSFConfig -FullName Company.Smtp.Server
    Unregister-PSFConfig -FullName beerfactory.fridge.size
    Remove-Item "$env:USERPROFILE\AppData\Roaming\WindowsPowerShell\PSFramework\Config\mymodule-1.json" -Force -ErrorAction Ignore
}
. $setupCode
Set-Content -Value $setupCode -Path $profile.CurrentUserCurrentHost