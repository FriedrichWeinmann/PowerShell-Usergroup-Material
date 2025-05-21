[CmdletBinding()]
param (
	
)

$ErrorActionPreference = 'Stop'
trap {
	Write-Log -Status ERROR -Message "Script failed" -ErrorRecord $_
	throw $_
}

. "$PSScriptRoot\lib-logging.ps1"

#region Functions
function Start-Something {
	[CmdletBinding()]
	param (
		
	)

	Write-Log -Message "Starting something"
	# ...
	Write-Log -Message "Starting something - Finished"
}
#endregion Functions

Start-Log -Path 'F:\temp\demo\phase2.csv'
Write-Log -Message "Starting Script"
Write-Log -Message "Step 1" -Tags "foo", "bar"
Start-Something
Write-Log -Message "Step 1: Starting with Max" -Target Max
try { 1 / 0 }
catch { Write-Log -Message "Failed badly" -ErrorRecord $_ }
Stop-Log