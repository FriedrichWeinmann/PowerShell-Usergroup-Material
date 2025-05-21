function Get-RandomNumber {
	[CmdletBinding()]
	param ()

	Get-Random -Minimum 10 -Maximum 99
}