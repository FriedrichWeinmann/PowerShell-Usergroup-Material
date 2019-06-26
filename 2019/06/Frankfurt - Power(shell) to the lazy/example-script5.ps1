Function Remove-ExpiredFolderContent
{
    <#
        .SYNOPSIS
            Function that cleans out old folder content.

        .DESCRIPTION
            This function searches a target folder and removes all content that is older than the specified number of days.
        
        .PARAMETER Folder
            The folder to search for expired content.
        
        .PARAMETER MaxDays
            The maximum number of days an item in the target folder may be before it is being cleaned up.
        
        .EXAMPLE
            PS C:\> Remove-ExpiredFolderContent

            Removes all files and folders in C:\temp older than 7 days
        
        .EXAMPLE
            PS C:\> Remove-ExpiredFolderContent -Folder D:\temp -MaxDays 14

            Removes all files and folders in D:\temp older than 14 days
    #>
    [CmdletBinding()]
    param (
        $folder = "C:\Temp",
        $maxDays = 7
    )

    Get-ChildItem -Path $folder | 
        Where-Object LastWriteTime -lt (Get-Date).AddDays((-1 * $maxDays)) | 
            Remove-Item -Recurse -Force
}