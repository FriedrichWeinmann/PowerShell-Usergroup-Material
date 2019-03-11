$setupCode = {
    $rootPresentationPath = (Get-PSFConfigValue -FullName 'psdemo.path.presentationsroot')
    $tempPath = Get-PSFConfigValue -FullName psutil.path.temp -Fallback $env:TEMP

    $null = New-Item -Path $tempPath -Name demo -Force -ErrorAction Ignore -ItemType Directory
    $null = New-PSDrive -Name demo -PSProvider FileSystem -Root $tempPath\demo -ErrorAction Ignore
    Set-Location demo:
    Get-ChildItem -Path demo:\ -ErrorAction Ignore | Remove-Item -Force -Recurse

    $filesRoot = Join-Path $rootPresentationPath "Presentations\Introduction to the PSFramework\PowerShell"
    
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
    Unregister-PSFConfig -Module DemoModule
    Set-PSFConfig -FullName 'DemoModule.Setting1' -Value 42 -SimpleExport -Description 'Just a demo setting with no intrinsic meaning'
    Set-PSFConfig -FullName psframework.text.encoding.defaultwrite -Value ([System.Text.Encoding]::UTF8) -DisableValidation
}
. $setupCode
Set-Content -Value $setupCode -Path $profile.CurrentUserCurrentHost