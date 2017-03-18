<#
A key example on how to cut down on repetitive actions.
Often it's always the same content within a type of object that is of interest to us.
With this function, I can extract it with a lot less typing.
#>

function Expand-Object
{
	<#
		.SYNOPSIS
			A comfortable replacement for Select-Object -ExpandProperty.
		
		.DESCRIPTION
			A comfortable replacement for Select-Object -ExpandProperty.
			Allows extracting properties with less typing and more flexibility:
	
            Default Mode:
            When not specifying a property-name, this function will work in default mode, which is processed in the following order:
            | Preferred Type |
            #----------------#
            When the input object is of a specific type, a custom extract is performed:
            - Output of Select-String: Will automatically expand all captures
            - Output of Get-Member: Will automatically axpand the definitions, one line per overload
    
			| Preferred Properties |
            #----------------------#
            When there is no coded preferred type, then it will compare the first object with a list of proeprty names and select the first exact match.
            Then it will, for each object passed to it expand the property if it exists.
			By defining a list of property-names in $DefaultExpandedProperties the user can determine his own list of preferred properties to expand.
            
			Defined Property Mode:
			The user can specify the exact property to extract. This is the same behavior as Select-Object -ExpandProperty, with less typing (dir | exp length).
	
			- Like / Match comparison:
			Specifying either like or match allows extracting any number of matching properties from each object.
			Note that this is a somewhat more CPU-expensive operation (which shouldn't matter unless with gargantuan numbers of objects).
            Only used in Defined Property Mode.
		
		.PARAMETER Name
			ParSet: Equals, Like, Match
			The name of the Property to expand.
		
		.PARAMETER Like
			ParSet: Like
			Expands all properties that match the -Name parameter using -like comparison.
		
		.PARAMETER Match
			ParSet: Match
			Expands all properties that match the -Name parameter using -match comparison.
		
		.PARAMETER InputObject
			The objects whose properties are to be expanded.
	
		.PARAMETER RestoreDefaults
			Restores $DefaultExpandedProperties to the default list of property-names.
		
		.EXAMPLE
			PS C:\> dir | exp
	
			Expands the property whose name is the first on the defaults list ($DefaultExpandedProperties).
			By default, FullName would be expanded.
	
		.EXAMPLE
			PS C:\> dir | exp length
	
			Expands the length property of all objects returned by dir. Simply ignores those that do not have the property (folders).
	
		.EXAMPLE
			PS C:\> dir | exp name -match
	
			Expands all properties from all objects returned by dir that match the string "name" ("PSChildName", "FullName", "Name", "BaseName" for directories)
		
		.NOTES
			Author:       Friedrich Weinmann
			Company:      die netzwerker Computernetze GmbH
			Created:      21.03.2015
			LastChanged:  18.03.2017
			Version:      1.2
	        
            Release 1.2 (18.03.2017, Friedrich Weinmann)
            - Added parser: When accepting input from the result of Get-Member, it will now expand the definition and split it into a single row per overload
    
			Release 1.1 (02.02.2017, Friedrich Weinmann)
			- Added parser: When accepting input from the result of Select-String, it will now expand caught results.
	
			Release 1.0 (21.03.2015, Friedrich Weinmann)
			- Initial Release
	#>
    [CmdletBinding(DefaultParameterSetName = "Equals")]
    Param (
        [Parameter(Position = 0, ParameterSetName = "Equals")]
        [Parameter(Position = 0, ParameterSetName = "Like", Mandatory = $true)]
        [Parameter(Position = 0, ParameterSetName = "Match", Mandatory = $true)]
        [string]
        $Name,
        
        [Parameter(ParameterSetName = "Like", Mandatory = $true)]
        [switch]
        $Like,
        
        [Parameter(ParameterSetName = "Match", Mandatory = $true)]
        [switch]
        $Match,
        
        [Parameter(ValueFromPipeline = $true)]
        [object]
        $InputObject,
        
        [switch]
        $RestoreDefaults
    )
    
    Begin
    {
        # Get active ParameterSet
        $ParSet = $PSCmdlet.ParameterSetName
        
        # Null the local scoped variable (So later checks for existence don't return super-scoped variables)
        $n9ZPiBh8CI = $null
        [bool]$____found = $false
        
        # Restore to default if necessary
        if ($RestoreDefaults) { $global:DefaultExpandedProperties = @("Definition", "Guid", "DisinguishedName", "FullName", "Name", "Length") }
    }
    
    Process
    {
        :main foreach ($Object in $InputObject)
        {
            switch ($ParSet)
            {
                #region Equals
                "Equals"
                {
                    if (($Object.GetType().FullName -eq "Microsoft.PowerShell.Commands.MatchInfo") -and (-not $PSBoundParameters.ContainsKey("Name")))
                    {
                        foreach ($item in $Object.Matches)
                        {
                            $item.Groups[1 .. ($item.Groups.Count - 1)].Value
                        }
                        continue main
                    }
                    
                    if (($Object.GetType().FullName -eq "Microsoft.PowerShell.Commands.MemberDefinition") -and (-not $PSBoundParameters.ContainsKey("Name")))
                    {
                        $Object.Definition.Replace("), ", ")þ").Split("þ")
                    }
                    
                    # If we already have determined the property to use, return it
                    if ($____found)
                    {
                        try
                        {
                            $null = $Object.$n9ZPiBh8CI.ToString()
                            $Object.$n9ZPiBh8CI
                        }
                        catch { }
                        continue main
                    }
                    
                    # If a property was specified, set it and return it
                    if ($PSBoundParameters.ContainsKey("Name"))
                    {
                        $n9ZPiBh8CI = $Name
                        $____found = $true
                        try
                        {
                            $Object.$n9ZPiBh8CI.ToString() | Out-Null
                            $Object.$n9ZPiBh8CI
                        }
                        catch { }
                        continue main
                    }
                    
                    # Otherwise, search through defaults and try to match
                    foreach ($Def in $DefaultExpandedProperties)
                    {
                        if (Get-Member -InputObject $Object -MemberType 'Properties' -Name $Def)
                        {
                            $n9ZPiBh8CI = $Def
                            $____found = $true
                            try
                            {
                                $Object.$n9ZPiBh8CI.ToString() | Out-Null
                                $Object.$n9ZPiBh8CI
                            }
                            catch { }
                            break
                        }
                    }
                    continue main
                }
                #endregion Equals
                
                #region Like
                "Like"
                {
                    # Return all properties whose name are similar
                    foreach ($prop in (Get-Member -InputObject $Object -MemberType 'Properties' | Where-Object { $_.Name -like $Name } | Select-Object -ExpandProperty Name))
                    {
                        try
                        {
                            $Object.$prop.ToString() | Out-Null
                            $Object.$prop
                        }
                        catch { }
                    }
                    continue
                }
                #endregion Like
                
                #region Match
                "Match"
                {
                    # Return all properties whose name match
                    foreach ($prop in (Get-Member -InputObject $Object -MemberType 'Properties' | Where-Object { $_.Name -match $Name } | Select-Object -ExpandProperty Name))
                    {
                        try
                        {
                            $Object.$prop.ToString() | Out-Null
                            $Object.$prop
                        }
                        catch { }
                    }
                    continue main
                }
                #endregion Match
            }
        }
    }
    
    End
    {
        
    }
}
New-Alias -Name exp -Value Expand-Object
$global:DefaultExpandedProperties = @("Definition", "Guid", "DisinguishedName", "FullName", "Name", "Length")