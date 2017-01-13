#region Parameters

# Link used to validate Credentials. Must not throw errors.
$script:testlink = "http://127.0.0.1:8080"

# Link to the register file used to import all the rest of the shell
$script:weblink = "http://127.0.0.1:8080/File-Importer.ps1"

# The Default domain name. This allows users to skip on specifying the domain name.
$script:DomainName = "DEMO.test"

#endregion Parameters

#region Utility Functions
function Get-ExePath
{
		<#
			.SYNOPSIS
				Returns the path to the current executable.
		#>
	if ($hostinvocation -ne $null) { $hostinvocation.MyCommand.path }
	else { $script:MyInvocation.MyCommand.Path }
}

function Get-ConfigFile
{
		<#
			.SYNOPSIS
				Tries to import a configuration xml. If it fails, it will create a new configuration object.
		#>
	if (Test-Path ((Get-Temp) + "\ShellData.xml")) { return (Import-Clixml ((Get-Temp) + "\ShellData.xml")) }
	else
	{
		$obj = "" | Select-Object UserName, Password, ExePath, CurPath, History, NeedsProxy, ProxyUrl, ProxyPort, ProxyUser, ProxyPwd
		$obj.ExePath = Get-ExePath
		$obj.CurPath = (Get-Location).Path
		return $obj
	}
}

function Get-Temp
{
		<#
			.SYNOPSIS
				Returns the real temp path if possible
		#>
	$d = $env:temp
	while (($d -notlike "*temp") -and ($d -ne "")) { $d = Split-Path $d }
	
	if ($d -ne "") { return $d }
	else { return $env:temp }
}

function Set-ConfigFile
{
		<#
			.SYNOPSIS
				Write Config back to Xml file
		#>
	Param (
		$Config
	)
	
	$Config | Export-Clixml ((Get-Temp) + "\ShellData.xml") -Depth 99
}

function Set-ConsoleFile
{
		<#
			.SYNOPSIS
				Creates a blank console file to a temporary folder.
				This prevents other modules from being auto-loaded by the system (e.g.: PSReadline, starting Windows 10)
		#>	
	
	# Get temporary name of the console file
	$temp = [System.IO.Path]::GetTempFileName().Replace(".tmp", ".psc1")
	
	# Get the version of the available PowerShell.exe (Can't use $Host.Version, as the NetzwerkerShell Packager doesn't use it)
	$exe = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
	$version_raw = [System.Diagnostics.FileVersionInfo]::GetVersionInfo($exe)
	$version = [System.Version]$version_raw.FileVersion.Split(" ")[0]
	
	# Setup the limits for testing, which PS Version to use in the console file
	$VLimit5 = New-Object System.Version(10, 0, 0, 0)
	$VLimit4 = New-Object System.Version(6, 3, 0, 0)
	$VLimit3 = New-Object System.Version(6, 2, 0, 0)
	
	# Compare the limit versions with the existing version, to match the correct string
	if ($Version -ge $VLimit5) { $VersionText = "5.0" }
	elseif ($Version -ge $VLimit4) { $VersionText = "4.0" }
	elseif ($Version -ge $VLimit3) { $VersionText = "3.0" }
	else { $VersionText = "2.0" }
	
	$String = @"
<?xml version="1.0" encoding="utf-8"?>
<PSConsoleFile ConsoleSchemaVersion="1.0">
  <PSVersion>$VersionText</PSVersion>
  <PSSnapIns />
</PSConsoleFile>
"@
	
	Set-Content -Value $String -Path $temp -Force -Confirm:$false -Encoding UTF8
	
	return $temp
}

function Remove-ConfigFile
{
		<#
			.SYNOPSIS
				Removes the configuration file in case of a crash
		#>
	if (Test-Path ((Get-Temp) + "\ShellData.xml")) { Remove-Item ((Get-Temp) + "\ShellData.xml") -Force -Confirm:$false }
	if (Test-Path ((Get-Temp) + "\ShellVars.xml")) { Remove-Item ((Get-Temp) + "\ShellVars.xml") -Force -Confirm:$false }
}

function Get-WebCredential
{
		<#
			.SYNOPSIS
				Ensures a valid set of credentials is present.
		#>
	Param (
		$Config
	)
	
	while ($true)
	{
		# If the config already has valid Credentials, return it as such
		if (Test-WebCredential -Config $Config) { return $Config }
		
		# Get Credential query
		$Cred = $null
		$Cred = Get-Credential
		
		# Enter changes into Config if applied
		if ($Cred -ne $null)
		{
			$Config.UserName = $Cred.UserName
			if ($Config.UserName -notlike "*@*") { $Config.UserName += "@$($script:DomainName)" }
			$Config.Password = $Cred.Password | ConvertFrom-SecureString
		}
		
		# If no Credentials were provided: Terminate
		else
		{
			Terminate-Execution "No Credentials provided, terminating"
		}
		
		# Ask whether the user wants to use a proxy (only runs in the second+ attempt to verify credentials, user is not asked again if answering with yes)
		if ($script:QueryForProxy -and (-not ($Config.NeedsProxy)))
		{
			$Message = "Soll ein Proxy verwendet werden?"
			$Yes = New-Object System.Management.Automation.Host.ChoiceDescription('&Ja', 'Proxy soll verwendet werden.')
			$No = New-Object System.Management.Automation.Host.ChoiceDescription('&Nein', 'Proxy soll NICHT verwendet werden.')
			$Options = [System.Management.Automation.Host.ChoiceDescription[]]($Yes, $No)
			$Config.NeedsProxy = ($Host.ui.PromptForChoice($null, $Message, $Options, 1) -eq 0)
		}
		
		# If Proxy should be used, ask for Proxy information
		if ($Config.NeedsProxy)
		{
			$Config.ProxyUrl = Get-ProxyInformation -Url
			$Config.ProxyPort = Get-ProxyInformation -Port
			$Cred = Get-ProxyInformation -Credential
			if ($Cred -ne $null)
			{
				$Config.ProxyUser = $Cred.UserName
				$Config.ProxyPwd = $Cred.Password | ConvertFrom-SecureString
			}
		}
	}
}

function Test-WebCredential
{
		<#
			.SYNOPSIS
				Tests whether the passed credentials are valid
		#>
	
	Param (
		$Config
	)
	
	# Validate the values are not null
	if ($Config.UserName.Length -lt 1) { return $false }
	if ($Config.Password.Length -lt 1) { return $false }
	
	# Build a credential object
	$test = $false
	try { $cred = New-Object System.Management.Automation.PSCredential($Config.UserName, ($Config.Password | ConvertTo-SecureString)) }
	catch { $test = $true }
	if ($Test) { return $false }
	
	# Create new WebClient
	$wc = New-Object System.Net.WebClient
	$wc.Credentials = $cred
	
	# Handle Proxy
	if ($Config.NeedsProxy)
	{
		if (-not (($Config.ProxyUrl -eq $null) -or ($Config.ProxyPort -eq $null)))
		{
			if (($Config.ProxyUser -eq $null) -or ($Config.ProxyPwd -eq $null)) { $cred = $null }
			else { $cred = New-Object System.Management.Automation.PSCredential($Config.ProxyUser, ($Config.ProxyPwd | ConvertTo-SecureString)) }
			$wc.Proxy = Get-WebProxy -ByPassLocal $true -Credential $cred -ProxyPort $Config.ProxyPort -ProxyUrl $Config.ProxyUrl
		}
	}
	
	# Test downloading the default index file
	$test = $true
	try { $wc.DownloadString($testlink) | Out-Null }
	catch
	{
		# If proxy is needed, set need-proxy flag
		$script:QueryForProxy = $true
		
		# Set test to "failed"
		$test = $false
	}
	return $test
}

function Get-Importer
{
		<#
			.SYNOPSIS
				Imports the Importer File
		#>
	Param (
		$Config
	)
	
	# Build Credential object
	$cred = New-Object System.Management.Automation.PSCredential($Config.UserName, ($Config.Password | ConvertTo-SecureString))
	
	# Create new WebClient
	$wc = New-Object System.Net.WebClient
	$wc.Credentials = $cred
	
	# Handle Proxy
	if ($Config.NeedsProxy)
	{
		if (-not (($Config.ProxyUrl -eq $null) -or ($Config.ProxyPort -eq $null)))
		{
			if (($Config.ProxyUser -eq $null) -or ($Config.ProxyPwd -eq $null)) { $cred = $null }
			else { $cred = New-Object System.Management.Automation.PSCredential($Config.ProxyUser, ($Config.ProxyPwd | ConvertTo-SecureString)) }
			$wc.Proxy = Get-WebProxy -ByPassLocal $true -Credential $cred -ProxyPort $Config.ProxyPort -ProxyUrl $Config.ProxyUrl
		}
	}
	
	# Download string
	try
	{
		# Download the file
		$String = "" + $wc.DownloadString($weblink)
		
		# Trim irregular characters out of the header of the string
		While (($String -ne "") -and ($String -notlike "#region*")) { $String = $String.SubString(1) }
		
		# If nothing is left, kill it
		if ($String -eq "") { Terminate-Execution "Failed to download Register file. Terminating ..." }
		
		# If something is left, return it
		return $String
	}
	catch
	{
		Terminate-Execution "An error occured while downloading: $($_.Exception.Message)"
	}
}

function Terminate-Execution
{
		<#
			.SYNOPSIS
				Terminates script execution
		#>
	Param (
		$Message
	)
	
	Remove-ConfigFile
	Write-Warning $Message
	Read-Host
	exit
}

function Start-Shell
{
		<#
			.SYNOPSIS
				Launches the Custom Shell
		#>
	Param (
		$Register,
		
		$Console
	)
	
	$encoded = [convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($Register))
	
	# Prepare Arguments, making sure it's running in a Multi-Threaded Apartment (Default for PS2, but not for later versions)
	# Disable local profiles to avoid contamination
	# Disable local console defaults to avoid contamination
	if ($host.Version.Major -gt 2) { $Arguments = "-PSConsoleFile `"$Console`" -MTA -WindowStyle normal -NoLogo -NoProfile -ExecutionPolicy Unrestricted -NoExit -EncodedCommand $encoded" }
	else { $Arguments = "-PSConsoleFile `"$Console`" -WindowStyle normal -NoLogo -NoProfile -ExecutionPolicy Unrestricted -NoExit -EncodedCommand $encoded" }
	
	# Test to check whether execution as admin was denied
	$NoAdmin = $false
	
	# Test whether store as file mode should be executed
	$StoreFile = $false
	
	# Try launching the Shell as Admin
	Try { Start-Process PowerShell.exe -Verb "RunAs" -ErrorAction 'Stop' -ArgumentList $Arguments }
	
	Catch
	{
		# If user denied execution as admin, switch to no admin
		if (($_.Exception.Message -like "*benutzer*") -or ($_.Exception.Message -like "*benutzer*")) { $NoAdmin = $true }
		
		# Else toggle File Parameter mode (launch as Encoded command can fail on Windows 6.0 or earlier, due to limit on maximum parameter length)
		else { $StoreFile = $true }
	}
	
	if ($StoreFile)
	{
		try
		{
			# Store launch script in file
			$FilePath = Join-Path (Get-Temp) "Temp_123746121"
			Set-Content -Path $FilePath -Value $Register
			
			# Prepare Arguments
			$Arguments = @("-WindowStyle normal", "-NoLogo", "-ExecutionPolicy Unrestricted", "-NoExit", "-File", ('"' + $FilePath + '"'))
			
			# Launch Powershell
			Start-Process PowerShell.exe -Verb "RunAs" -ErrorAction 'Stop' -ArgumentList $Arguments
		}
		catch
		{
		}
		finally
		{
			Start-Sleep -Seconds 2
			Remove-Item $FilePath -Force -Confirm:$false
		}
	}
	
	# If launching as Admin was denied, launch regular (not recommended)
	if ($NoAdmin) { Start-Process PowerShell.exe -ArgumentList $Arguments }
	
	# Finally, clean up the console file
	Start-Sleep 1
	Remove-Item $Console -Force -Confirm:$false
}

function Get-WebProxy
{
	[CmdletBinding()]
	Param (
		[string]
		$ProxyUrl,
		
		[int]
		$ProxyPort,
		
		[AllowNull()]
		[System.Management.Automation.PSCredential]
		$Credential,
		
		[bool]
		$ByPassLocal = $true
	)
	
	$proxy = New-Object System.Net.WebProxy($ProxyUrl, $ProxyPort)
	if ($Credential) { $proxy.Credentials = $Credential.GetNetworkCredential() }
	$proxy.BypassProxyOnLocal = $ByPassLocal
	
	return $proxy
}

function Get-ProxyInformation
{
		<#
			.SYNOPSIS
				Asks the user for individual pieces of Information
		#>
	Param (
		[switch]
		$Url,
		
		[switch]
		$Port,
		
		[switch]
		$Credential
	)
	
	# Process Url request
	if ($Url)
	{
		return (Read-Host "Enter Proxy Url  ")
	}
	# Process Port request
	if ($Port)
	{
		return (Read-Host "Enter Proxy Port ")
	}
	
	# Process Credentials request
	if ($Credential)
	{
		Write-Host "Enter Proxy Credentials"
		$cred = Get-Credential
		return $cred
	}
}
#endregion Utility Functions

#region Process

# Step 1: Get Configuration
$Config = Get-ConfigFile

# Step 2: Ensure Credential
$Config = Get-WebCredential -Config $Config

# Step 3: Get Register file
$String = Get-Importer -Config $Config

# Step 4: Write Config back to file
Set-ConfigFile $Config

# Step 5: Write Console File to disable loading modules from the system
$Console = Set-ConsoleFile

# Step 6: Launch NW Shell
Start-Shell -Register $String -Console $Console

#endregion Process