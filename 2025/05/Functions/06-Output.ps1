# Failsafe
return


# Producing Output
function Get-ExampleOutput {
	[CmdletBinding()]
	param ()

	42
	Write-Output 23
	return "Done"
	1
}
Get-ExampleOutput


# Custom Objects
function Resolve-AccountName {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$GivenName,

		[Parameter(Mandatory = $true)]
		[string]
		$Surname,

		[string]
		$Domain = 'contoso.com'
	)

	# Account Name
	$GivenName.SubString(0,1) + $Surname

	# Email Address
	'{0}.{1}@{3}' -f $GivenName, $Surname, $Domain
}
Resolve-AccountName -GivenName Max -Surname Mustermann


# Common Pattern
function Resolve-AccountNameBulk {
	[CmdletBinding()]
	param (
		[string[]]
		$GivenName,

		[string]
		$Surname
	)

	$results = @()

	foreach ($name in $GivenName) {
		$results += [PSCustomObject]@{
			GivenName = $name
			Surname = $Surname
			TimeCreated = Get-Date
		}
	}

	return $results
}
Resolve-AccountNameBulk -Surname Musterfrau -GivenName Maria, Myrte, Margit, Margaret, Miriam, Muriel, Mia, Magdalena, Mira, Morgana, Mel, Melissa, Margot

# Why this is a bad idea
# What you could have done instead
# More reasons not to do this (pipeline)


# Next: Did we really - really - make it this far?
# Seriously, Andrew, I'm sure you just never told me I went overtime
code "$presentatioNRoot\07-Validation.ps1"