﻿[CmdletBinding()]
param (
	
)

$ErrorActionPreference = 'Stop'
trap {
	Write-Log -Status ERROR -Message "Script failed" -ErrorRecord $_
	throw $_
}

#region Functions
#region Logging
function Start-Log {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[string]
		$Path
	)

	$script:_Logger = { Export-Csv -Path $Path }.GetSteppablePipeline()
	$script:_Logger.Begin($true) # $true = Pipeline INput wird erwartet
}
function Write-Log {
	[CmdletBinding()]
	param (
		[string]
		$Message,

		[ValidateSet('ERROR', 'WARNING', 'INFO', 'DEBUG')]
		[string]
		$Status = 'INFO',

		[string]
		$Target,

		[string[]]
		$Tags,

		[System.Management.Automation.ErrorRecord]
		$ErrorRecord
	)

	if ($ErrorRecord) {
		$Message = '{0} | {1}' -f $Message, $ErrorRecord

		if ($PSBoundParameters.Keys -notcontains 'Status') {
			$Status = 'ERROR'
		}
	}

	$messageText = '{0:HH:mm:ss} {1}' -f (Get-Date), $Message
	switch ($Status) {
		'INFO' { Write-Verbose $messageText }
		'WARNING' { Write-Warning $messageText }
		'ERROR' { Write-Warning $messageText }
	}

	if (-not $script:_Logger -and -not $script:_LoggingWarningShown) {
		Write-Warning "Logging not enabled, use Start-Log to configure logging!"
		$script:_LoggingWarningShown = $true
		return
	}

	$caller = (Get-PSCallStack)[1]

	$data = [PSCustomObject]@{
		Timestamp   = (Get-Date).ToUniversalTime().ToString('yyyy-MM-dd HH:mm:ss.fff')
		Status      = $Status
		Message     = $Message
		Target      = $Target
		Tags        = $Tags -join ', '
		User        = $env:USERNAME
		Computer    = $env:COMPUTERNAME
		Command     = $caller.FunctionName
		Line        = $caller.ScriptLineNumber
		ScriptName  = $caller.Location
		ErrorRecord = $ErrorRecord
	}

	$script:_Logger.Process($data)
}
function Stop-Log {
	[CmdletBinding()]
	param ()

	if (-not $script:_Logger) {
		Write-Verbose "[Stop-Log] Logging not enabled, terminating function"
		return
	}

	$script:_Logger.End()
	$script:_Logger = $null
}
#endregion Logging

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