# Load Dbatools DLL
Add-Type -Path ((Get-Module dbatools -ListAvailable | Sort-Object Version -Descending | Select-Object -First 1).ModuleBase + "\bin\net452\Dbatools.dll")
# Load custom prompt that uses dbatools
. 'D:\Code\Github\PSSTemplates\prompts\Fred.prompt.ps1'
Clear-Host

Set-Alias grep Select-String

Import-Module PSUtil

function Invoke-Temp { Set-Location C:\Temp }
Set-Alias tem Invoke-Temp