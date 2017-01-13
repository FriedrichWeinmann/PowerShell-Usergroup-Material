#region Downloader Credentials
$RT_weblink = "Http://127.0.0.1:8080"

function Get-Temp
{
		<#
			.SYNOPSIS
				Returns the real temp path if possible.
				On Servers, the temp path will often be redirected to a subdirectory on a per-process base.
				This means, that the original client process and the powershell process may be using separate temp directories.
		#>
	$d = $env:temp
	while (($d -notlike "*temp") -and ($d -ne "")) { $d = Split-Path $d }
	
	if ($d -ne "") { return $d }
	else { return $env:temp }
}

try
{
	$__Config = Import-Clixml ((Get-Temp) + "\ShellData.xml") -ErrorAction 'Stop'
	Remove-Item ((Get-Temp) + "\ShellData.xml") -Force -Confirm:$false -ErrorAction 'SilentlyContinue' | Out-Null
}
catch { }
if ($__Config -eq $null)
{
	Write-Warning "Configuration File not found, terminating. Encrypted credentials may be visible, check your temp directory for ShellData.xml and delete it!"
	Read-Host
	exit
}
$__cred = New-Object System.Management.Automation.PSCredential($__Config.UserName, ($__Config.Password | ConvertTo-SecureString))
#endregion Downloader Credentials

#region Load key functions
function Get-WebContent-Loader
{
	<#
		.SYNOPSIS
			Downloads a file
	
		.DESCRIPTION
			Download any file using a valid weblink and either store it locally or return its content
		
		.PARAMETER WebLink
			The full link to the file (Example: "http://www.example.com/files/examplefile.dat"). Adds "http://" if webLink starts with "www".
	
		.PARAMETER Credentials
			The target where you want to store the file, including the filename (Example: "C:\Example\examplefile.dat"). Folder needs not exist but path must be valid. Optional.
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $True, Position = 0)]
		[string]
		$WebLink,
		
		[Parameter(Mandatory = $True, Position = 1)]
		$Credentials,
		
		$Config
	)
	
	# Correct WebLink for typical errors
	if ($webLink.StartsWith("www") -or $webLink.StartsWith("WWW")) { $webLink = "http://" + $webLink }
	
	$webclient = New-Object Net.Webclient
	$webclient.Encoding = [System.Text.Encoding]::UTF8
	$webclient.Credentials = $Credentials
	
	# Apply Proxy settings
	if ($Config.NeedsProxy)
	{
		$proxy = New-Object System.Net.WebProxy($Config.ProxyUser, $Config.ProxyPwd)
		if (($Config.ProxyUser -eq $null) -or ($Config.ProxyPwd -eq $null)) { $__cred = $null }
		else { $__cred = New-Object System.Management.Automation.PSCredential($Config.ProxyUser, ($Config.ProxyPwd | ConvertTo-SecureString)) }
		if ($__cred) { $proxy.Credentials = $__cred.GetNetworkCredential() }
		$proxy.BypassProxyOnLocal = $true
		$webclient.Proxy = $proxy
	}
	
	$file = $webclient.DownloadString($webLink)
	
	return $file
}
#endregion Load key functions

$link = $RT_weblink + "/File-Importer2.ps1"

$con = Get-WebContent-Loader -WebLink $link -Credentials $__cred -Config $__Config
while ($con -notlike "#region*") { $con = $con.SubString(1) }

. Invoke-Expression -Command $con
