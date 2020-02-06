[CmdletBinding()]
param (
    $folder = "C:\Temp",
    $maxDays = 7
)

Write-Verbose "Some Message $maxDays"
Get-ChildItem -Path $folder | 
    Where-Object LastWriteTime -lt (Get-Date).AddDays((-1 * $maxDays)) | 
        Remove-Item -Recurse -Force