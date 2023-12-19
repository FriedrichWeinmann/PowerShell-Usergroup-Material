# failsafe
return

#-> Getting Started
function Get-CustomUser {
	[CmdletBinding()]
	param (
		$Server,
		[PSCredential]$Credential,
		$Filter,
		$LdapFilter,
		$Identity
	)

	$param = $PSBoundParameters | ConvertTo-PSFHashtable
	$param
	# Get-ADUser @param
}
Get-CustomUser -Server contoso.com -Identity max

#-> Problem
function Get-CustomUser {
	[CmdletBinding()]
	param (
		$Server,
		[PSCredential]$Credential,
		$Filter,
		$LdapFilter,
		$Identity,
		$Foo
	)

	$param = $PSBoundParameters | ConvertTo-PSFHashtable
	$param
	Get-ADUser @param
}
Get-CustomUser -Identity Fred -Foo Bar

#-> Solution
function Get-CustomUser {
	[CmdletBinding()]
	param (
		$Server,
		[PSCredential]$Credential,
		$Filter,
		$LdapFilter,
		$Identity,
		$Foo
	)

	$param = $PSBoundParameters | ConvertTo-PSFHashtable -ReferenceCommand Get-ADUser
	$param
	# Get-ADUser @param
}
Get-CustomUser -Identity Fred -Foo Bar

#-> New Awesome update
function Get-CustomUser {
	[CmdletBinding()]
	param (
		$Server,
		[PSCredential]$Credential,
		$Filter,
		$LdapFilter,
		$Identity,
		$Foo
	)

	$param = $PSBoundParameters | ConvertTo-PSFHashtable -ReferenceCommand Get-ADUser -ReferenceParameterSetName LdapFilter
	$param
	# Get-ADUser @param
}
Get-CustomUser -Identity Fred -Foo Bar
Get-CustomUser -Identity Fred -Foo Bar -LdapFilter '(name=Fred)'