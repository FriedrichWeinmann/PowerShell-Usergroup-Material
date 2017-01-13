#region Import the common components
$__files = @(
	"util/util-library.ps1",
	"functions/functions-configuration.ps1",
	"functions/functions-shell.ps1",
	"functions/functions-utility.ps1",
	"util/util-postconfig.ps1"
)

foreach ($file in $__files)
{
	Write-Host "$file"
	$link = "$($RT_weblink)/$($file)"
	
	$con = $Null
	$con = Get-WebContent-Loader -WebLink $link -Credentials $__cred -Config $__Config
	while ($con -notlike "#region*") { $con = $con.SubString(1) }
	
	. Invoke-Expression -Command $con
}
#endregion Import the common components

#region Import the userprofile
$__name = $__Config.UserName.Split("@")[0]

try
{
	$link = "$($RT_weblink)/profiles/profile_$($__name).ps1"
	
	$con = Get-WebContent-Loader -WebLink $link -Credentials $__cred -Config $__Config -ErrorAction Stop
	while ($con -notlike "#region*") { $con = $con.SubString(1) }
	
	. Invoke-Expression -Command $con
}
catch { }
#endregion Import the userprofile

#Remove-Variable "__Config", "__name", "cred", "__files", "link", "RT_weblink"
#Remove-Item function:\Get-WebContent-Loader