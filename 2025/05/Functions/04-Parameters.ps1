# Failsafe
return

# Parameters!
#--------------

# Default Values
function Write-Greeting {
	param (
		$Name = 'World'
	)

	"Hello $Name"
}
Write-Greeting -Name Max
Write-Greeting

# CmdletBinding
Write-Greeting -Namez Petra # Hello World
function Write-Greeting {
	[CmdletBinding()]
	param (
		$Name = 'World'
	)

	"Hello $Name"
}
Write-Greeting -Namez Petra


# Mandatory
function Write-Greeting {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		$Name
	)

	"Hello $Name"
}
Write-Greeting
Write-Greeting -Name Mia

# Expected Types
function Write-Greeting {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]
		$Name
	)

	"Hello $Name ($($Name.SubString(0,1)))"
}
Write-Greeting -Name Max
Write-Greeting -Name 42

# Multiple Parameter
function Write-Greeting {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory)]
		[string]
		$Surname,

		[Parameter(Mandatory)]
		[string]
		$GivenName
	)

	[PSCustomObject]@{
		GivenName = $GivenName
		Surname = $Surname
		Greeting = "Hello $GivenName $Surname"
	}
}
Write-Greeting
Write-Greeting -Surname Mustermann -GivenName Max

# Mutually Exclusive
function Write-Greeting {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory, ParameterSetName = 'GNSN')]
		[string]
		$Surname,

		[Parameter(Mandatory, ParameterSetName = 'GNSN')]
		[string]
		$GivenName,

		[Parameter(Mandatory, ParameterSetName = 'Name')]
		[string]
		$Name,

		[int]
		$Age
	)

	[PSCustomObject]@{
		GivenName = $GivenName
		Surname = $Surname
		Name = $Name
		Greeting = "Hello $GivenName $Surname"
		Age = $Age
	}
}
Write-Greeting -Name Max
Write-Greeting -Name Max -Age 18
Write-Greeting -GivenName Maria -Surname Musterfrau
Write-Greeting -GivenName Maria -Surname Musterfrau -Age 23
Write-Greeting -GivenName Maria -Surname Musterfrau -Name Maria
Get-Command Write-Greeting -Syntax

Write-Greeting # Error
function Write-Greeting {
	[CmdletBinding(DefaultParameterSetName = 'GNSN')]
	param (
		[Parameter(Mandatory, ParameterSetName = 'GNSN')]
		[string]
		$Surname,

		[Parameter(Mandatory, ParameterSetName = 'GNSN')]
		[string]
		$GivenName,

		[Parameter(Mandatory, ParameterSetName = 'Name')]
		[string]
		$Name,

		[int]
		$Age
	)

	[PSCustomObject]@{
		GivenName = $GivenName
		Surname = $Surname
		Name = $Name
		Greeting = "Hello $GivenName $Surname"
		Age = $Age
	}
}
Write-Greeting

# Next: Output vs. Message - the fight for puppies has just started!
code "$presentationRoot\05-OutputVSMessage.ps1"