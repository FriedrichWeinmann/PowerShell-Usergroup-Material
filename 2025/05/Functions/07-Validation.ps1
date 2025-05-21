# Failsafe
return


function Remove-LogFile {
	[CmdletBinding()]
	param (
		[ValidateScript({
			if (Test-Path -Path $_) { return $true } # $_ = "Current Item" - here: The path to be validated

			Write-Warning "Path does exist: $_"
			throw "Path does exist: $_"
		})]
		[string]
		$Path,

		[ValidateRange(1,730)]
		[int]
		$MaxDays = 7,

		[ValidateSet('All', 'File', 'Directory')]
		[string]
		$Type = 'All'
	)

	$includeFiles = $Type -in 'All', 'File'
	$includeDirectories = $Type -in 'All', 'Directory'

	$limit = (Get-Date).AddDays(-$MaxDays)
	Write-Host "Deleting all $Type in $Path older than $limit"
	Get-ChildItem -Path $Path |	Where-Object {
		$_.LastWriteTime -lt $limit -and
		(
			($_.PSIsContainer -and $includeDirectories) -or
			(-not $_.PSIsContainer -and $includeFiles)
		)
	} |	Remove-Item
}
Remove-LogFile -Path F:\Temp\Demo -Type Filez
Remove-LogFile -Path F:\Temp\Demo -Type File
Remove-LogFile -Path F:\Temp\Demo -Type File -MaxDays -14
Remove-LogFile -Path F:\Temp\Demo -Type File -MaxDays 999
Remove-LogFile -Path F:\Temp\Demo3 -Type File

#-> Now make this harder to break!



# Next: Nothing. Even if I honestly made it here in time, I'm done, bring your questions!