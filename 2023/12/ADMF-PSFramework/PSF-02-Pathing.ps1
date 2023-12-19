# failsafe
return

# Path Validation Sucks:
function Get-FileContent {
	[CmdletBinding()]
	param (
		[string[]]
		$Path
	)

	foreach ($entry in $Path) {
		try { $resolvedPaths = Resolve-Path -Path $entry -ErrorAction Stop }
		catch {
			Write-Error $_
			continue
		}

		foreach ($resolvedPath in $resolvedPaths) {
			if (-not (Test-Path -Path $resolvedPath -PathType Leaf)) {
				Write-Warning "Not a file: $resolvedPath"
				continue
			}

			# Do Something
			$resolvedPath
		}
	}
}
Get-FileContent -Path C:\Windows\*.exe, C:\temp\demo, C:\temp\demo\*

# Let's make this better
function Get-FileContent {
	[CmdletBinding()]
	param (
		[PsfFile]
		$Path
	)

	foreach ($filePath in $Path) {
		# Do Something
		$filePath
	}
}
Get-FileContent -Path C:\Windows\*.exe, C:\temp\demo\*

# Or even better
function Get-FileContent {
	[CmdletBinding()]
	param (
		[PsfFile]
		$Path,

		[PsfLiteralPath]
		$LiteralPath
	)

	foreach ($filePath in $Path + $LiteralPath) {
		# Do Something
		$filePath
	}
}
Get-FileContent -Path C:\Windows\*.exe, C:\temp\demo\* -LiteralPath .\error.clixml

# Not Everything has to exist
function Export-SystemReport {
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $true)]
		[PsfNewFile]
		$OutPath
	)

	# Do Something
	$results = Get-ChildItem -Path C:\Windows -File -Force

	$results | Export-PSFClixml -Path $OutPath
}
Export-SystemReport -OutPath .\newexport.clidat
Export-SystemReport -OutPath .\foo\newexport.clidat
Export-SystemReport -OutPath .\newexport.clidat
Import-PsfClixml .\newexport.clidat

# And sometimes these errors are pesky
function Get-FileContent {
	[CmdletBinding()]
	param (
		[PsfFileLax]
		$Path
	)

	foreach ($entry in $Path.FailedInput) {
		Write-Warning "Could not resolve as file: $entry"
	}

	foreach ($filePath in $Path) {
		# Do Something
		$filePath
	}
}
Get-FileContent -Path C:\temp\demo, C:\temp\demo\*