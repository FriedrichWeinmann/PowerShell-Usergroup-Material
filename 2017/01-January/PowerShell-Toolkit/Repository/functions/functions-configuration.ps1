#region Configuration
function Get-Config
{
	<#
		.SYNOPSIS
			Retrieves configuration elements by name.
		
		.DESCRIPTION
			Retrieves configuration elements by name.
			Can be used to search the existing configuration list.
		
		.PARAMETER Name
			Default: "*"
			The name of the configuration element(s) to retrieve.
			May be any string, supports wildcards.
		
		.PARAMETER Module
			Default: "*"
			Search configuration by module.
		
		.PARAMETER Force
			Overrides the default behavior and also displays hidden configuration values.
		
		.EXAMPLE
			PS C:\> Get-Config 'Mail.To'
			
			Retrieves the configuration element for the key "Mail.To"
	
		.EXAMPLE
			PS C:\> Get-Config -Force
	
			Retrieve all configuration elements from all modules, even hidden ones.
		
		.NOTES
			Author:     Friedrich Weinmann
			Company:    Infernal Associates ltd.
			Created on: 05.01.2017
			Changed on: 05.01.2017
			Version: 1.0
			
			Version History:
			Version 1.0 (05.01.2017)
			- Initial Release
	#>
	[CmdletBinding()]
	Param (
		[string]
		$Name = "*",
		
		[string]
		$Module = "*",
		
		[switch]
		$Force
	)
	
	$Name = $Name.ToLower()
	$Module = $Module.ToLower()
	
	[Demo.Configuration.Config]::Cfg.Values | Where-Object { ($_.Name -like $Name) -and ($_.Module -like $Module) -and ((-not $_.Hidden) -or ($Force)) }
}

function Set-Config
{
	<#
		.SYNOPSIS
			Sets configuration entries.
		
		.DESCRIPTION
			This function creates or changes configuration values.
			These are used in a larger framework to provide dynamic configuration information outside the PowerShell variable system.
		
		.PARAMETER Name
			Name of the configuration entry. If an entry of exactly this non-casesensitive name already exists, its value will be overwritten.
			Duplicate names across different modules are possible and will be treated separately.
			If a name contains namespace notation and no module is set, the first namespace element will be used as module instead of name. Example:
			-Name "Nordwind.Server"
			Is Equivalent to
			-Name "Server" -Module "Nordwind"
		
		.PARAMETER Value
			The value to assign to the named configuration element.
		
		.PARAMETER Module
			This allows grouping configuration elements into groups based on the module/component they server.
			If this parameter is not set, the configuration element is stored under its name only, which increases the likelyhood of name conflicts in large environments.
		
		.PARAMETER Hidden
			Setting this parameter hides the configuration from casual discovery. Configurations with this set will only be returned by Get-Config, if the parameter "-Force" is used.
			This should be set for all system settings a user should have no business changing (e.g. for Infrastructure related settings such as mail server).
		
		.PARAMETER Default
			Setting this parameter causes the system to treat this configuration as a default setting. If the configuration already exists, no changes will be performed.
			Useful in scenarios where for some reason it is not practical to automatically set defaults before loading userprofiles.
		
		.EXAMPLE
			PS C:\> Set-Config -Name 'User' -Value "Friedrich"
	
			Creates a configuration entry named "User" with the value "Friedrich"
	
		.EXAMPLE
			PS C:\> Set-Config 'ConfigLink' 'https://www.example.com/config.xml' 'Company' -Hidden
	
			Creates a configuration entry named "ConfigLink" in the "Company" module with the value 'https://www.example.com/config.xml'.
			This entry is hidden from casual discovery using Get-Config.
	
		.EXAMPLE
			PS C:\> Set-Config 'Network.Firewall' '10.0.0.2' -Default
	
			Creates a configuration entry named "Firewall" in the "Network" module with the value '10.0.0.2'
			This is only set, if the setting does not exist yet. If it does, this command will apply no changes.
		
		.NOTES
			Author:  Friedrich Weinmann
			Company: Infernal Associates ltd.
			Created on: 05.01.2017
			Changed on: 05.01.2017
			Version: 1.0
			
			Version History:
			Version 1.0 (05.01.2017
			- Initial Release
	#>
	
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Name,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[AllowNull()]
		[AllowEmptyCollection()]
		[AllowEmptyString()]
		$Value,
		
		[Parameter(Position = 2)]
		[string]
		$Module,
		
		[switch]
		$Hidden,
		
		[switch]
		$Default
	)
	
	#region Prepare Names
	$Name = $Name.ToLower()
	if ($Module) { $Module = $Module.ToLower() }
	
	if (-not $PSBoundParameters.ContainsKey("Module") -and ($Name -match ".+\..+"))
	{
		$r = $Name | select-string "^(.+?)\..+" -AllMatches
		$Module = $r.Matches[0].Groups[1].Value
		$Name = $Name.Substring($Module.Length + 1)
	}
		
	If ($Module) { $FullName = $Module, $Name -join "." }
	else { $FullName = $Name }
	#endregion Prepare Names
	
	#region Process Record
	if (([Demo.Configuration.Config]::Cfg[$FullName]) -and (-not $Default))
	{
		if ($PSBoundParameters.ContainsKey("Hidden")) { [Demo.Configuration.Config]::Cfg[$FullName].Hidden = $Hidden }
		[Demo.Configuration.Config]::Cfg[$FullName].Value = $Value
	}
	elseif (-not [Demo.Configuration.Config]::Cfg[$FullName])
	{
		$Config = New-Object Demo.Configuration.Config
		$Config.Name = $name
		$Config.Module = $Module
		$Config.Value = $Value
		$Config.Hidden = $Hidden
		[Demo.Configuration.Config]::Cfg[$FullName] = $Config
	}
	#endregion Process Record
}

function Get-ConfigValue
{
	<#
		.SYNOPSIS
			Returns theconfiguration value stored under the specified name.
		
		.DESCRIPTION
			Returns theconfiguration value stored under the specified name.
			It requires the full name (<Module>.<Name>) and is usually only called by functions.
		
		.PARAMETER Name
			The full name (<Module>.<Name>) of the configured value to return.
	
		.PARAMETER Fallback
			A fallback value to use, if no value was registered to a specific configuration element.
			This basically is a default value that only applies on a "per call" basis, rather than a system-wide default.
		
		.PARAMETER NotNull
			By default, this function returns null if one tries to retrieve the value from either a Configuration that does not exist or a Configuration whose value was set to null.
			However, sometimes it may be important that some value was returned.
			By specifying this parameter, the function will throw an error if no value was found at all.
		
		.EXAMPLE
			PS C:\> Get-ConfigValue -Name 'System.MailServer'
	
			Returns the configured value that was assigned to the key 'System.MailServer'
	
		.EXAMPLE
			PS C:\> Get-ConfigValue -Name 'Default.CoffeeMilk' -Fallback 0
	
			Returns the configured value for 'Default.CoffeeMilk'. If no such value is configured, it returns '0' instead.
		
		.NOTES
			Author:     Friedrich Weinmann
			Company:    Infernal Associates ltd.
			Created on: 10.01.2017
			Changed on: 10.01.2017
			Version: 1.0
			
			Version History:
			Version 1.0 (10.01.2017)
			- Initial Release
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true)]
		[string]
		$Name,
		
		[object]
		$Fallback,
		
		[switch]
		$NotNull
	)
	
	$Name = $Name.ToLower()
	
	$temp = $null
	$temp = [Demo.Configuration.Config]::Cfg[$Name].Value
	if ($temp -eq $null) { $temp = $Fallback }
	
	if ($NotNull -and ($temp -eq $null))
	{
		throw "No Configuration Value available for $Name"
	}
	else
	{
		return $temp
	}
}
#endregion Configuration


