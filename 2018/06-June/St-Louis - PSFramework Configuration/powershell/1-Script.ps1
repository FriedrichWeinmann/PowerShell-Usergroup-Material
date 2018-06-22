[CmdletBinding()]
param (
	$MaxDays = 7,
	
	$SmtpServer = (Get-PSFConfigValue -FullName Company.Smtp.Server -Fallback "mail1.company.domain"),

	# Only for Demo
	[switch]
	$Wait
)

Write-Host "`nWill connect to $SmtpServer !"

# Do whatever else you would in the script
# ...

if ($Wait) { pause }