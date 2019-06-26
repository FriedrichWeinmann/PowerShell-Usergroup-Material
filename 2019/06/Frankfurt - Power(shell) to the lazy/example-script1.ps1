###################################
# Edit Parameters here

$folder = "C:\Temp"
$maxDays = 7

# Don't change anything below here
####################################

Get-ChildItem -Path $folder | 
    Where-Object LastWriteTime -lt (Get-Date).AddDays((-1 * $maxDays)) | 
        Remove-Item -Recurse -Force