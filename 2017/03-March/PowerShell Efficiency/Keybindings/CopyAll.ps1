Set-PSReadlineKeyHandler -Key Ctrl+Shift+c -BriefDescription CopyAllLines -LongDescription "Copies the all lines of the current command into the clipboard" -ScriptBlock {
	
	# Get current code
	$line = $null
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$null)
	
	# Paste it to clipboard
	Set-Clipboard $line
}