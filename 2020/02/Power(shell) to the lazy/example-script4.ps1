<#
    .SYNOPSIS
        Script that cleans out old folder content.

    .DESCRIPTION
        This script searches a target folder and removes all content that is older than the specified number of days.
    
    .PARAMETER Folder
        The folder to search for expired content.
    
    .PARAMETER MaxDays
        The maximum number of days an item in the target folder may be before it is being cleaned up.
    
    .EXAMPLE
        PS C:\> .\example-script4.ps1

        Removes all files and folders in C:\temp older than 7 days
    
    .EXAMPLE
        PS C:\> .\example-script4.ps1 -Folder D:\temp -MaxDays 14

        Removes all files and folders in D:\temp older than 14 days
#>
[CmdletBinding()]
param (
    $Folder = "C:\Temp",
    $MaxDays = 7
)

Get-ChildItem -Path $Folder | 
    Where-Object LastWriteTime -lt (Get-Date).AddDays((-1 * $MaxDays)) | 
        Remove-Item -Recurse -Force