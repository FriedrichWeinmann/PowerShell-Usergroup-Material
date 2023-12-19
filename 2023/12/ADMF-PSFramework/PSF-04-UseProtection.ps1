# failsafe
return

# Ugh
function Remove-File {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		[PsfFile]
		$Path
	)

	process {
		foreach ($item in $Path) {
			if ($PSCmdlet.ShouldProcess($item, "Delete")) {
				try {
					Write-PSFMessage -Message "Deleting $item" -Target $item
					Remove-Item -Path $item -Recurse -Force -Confirm:$false -ErrorAction Stop
					Write-PSFMessage -Message "Successfully deleted $item" -Target $item
				}
				catch {
					Write-PSFMessage -Level Warning -Message "Failed to delete $item" -Target $item -ErrorRecord $_
					Write-Error $_
					continue
				}
			}
		}
	}
}
Remove-File -Path .\error.clixml -WhatIf
Remove-File -Path .\error.clixml


# Better
function Remove-File {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		[PsfFile]
		$Path,

		[switch]
		$EnableException
	)

	process {
		foreach ($item in $Path) {
			Invoke-PSFProtectedCommand -Action Delete -Target $item -ScriptBlock {
				Remove-Item -Path $item -Recurse -Force -Confirm:$false -ErrorAction Stop
			} -EnableException $EnableException -Continue
		}
	}
}
Remove-File -Path .\error.clixml -WhatIf


# What's new?
function Remove-File {
	[CmdletBinding(SupportsShouldProcess = $true)]
	param (
		[Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true)]
		[string[]]
		$Path,

		[switch]
		$EnableException
	)

	process {
		foreach ($item in $Path) {
			Invoke-PSFProtectedCommand -Action Delete -Target $item -ScriptBlock {
				Remove-Item -Path $item -Recurse -Force -Confirm:$false -ErrorAction Stop
			} -EnableException $EnableException -Continue -RetryCount 4 -RetryWait 1 -RetryWaitEscalation 1.5
		}
	}
}
Remove-File -Path .\foo.txt -Verbose