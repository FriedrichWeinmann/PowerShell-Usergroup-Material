# Failsafe
return


# How it all began
function Test-File {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path
	)

	Write-Host "Testing file: $Path"
	if (Test-Path -Path $Path -PathType Leaf) {
		return $true
	}
	else {
		return $false
	}
}
if (Test-File -Path C:\Windows\explorer.exe) { "Yay" }
if (Test-File -Path C:\Windows\explorer2.exe) { "Yay" }

# Save the Puppies!

# Extra Verbose

<#
Message vs. Output

> Message

Communication with the user / logfile
Should be used to report actions taken, current progress, issues encountered.

> Output

Result of your command, data that should be reusable by who called the command

More extensive writeup on this:
https://allthingspowershell.blogspot.com/2017/12/puppycide-done-right-output-versus.html
#>


# Next: Adding value to your functions
code "$presentationRoot\06-Output.ps1"