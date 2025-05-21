# failsafe
return

# Pattern
function Write-Hello {
	Write-Host "Hello World"
}
Write-Hello

# Order
Get-Something
function Get-Something {
	"Some", "Thing"
}
#-> First the function definition, then use it

# Parameters
function Write-Greeting {
	param (
		$Name
	)

	"Greetings, $Name"
}
Write-Greeting -Name "Max"
Write-Greeting -Name 'Maria'
$result = Write-Greeting -Name 'Maria'
$result

# Object

# Next: This is a pain, why should I be doing this?
code "$presentationRoot\02-Why.ps1"