Set-PSReadlineKeyHandler -Key Alt+w -BriefDescription SaveInHistory -LongDescription "Save current line in history but do not execute" -ScriptBlock {
		
	$line = $null
	
	# Get current line(s) of input
	[Microsoft.PowerShell.PSConsoleReadLine]::GetBufferState([ref]$line, [ref]$null)
	
	# Add them to the command history
	[Microsoft.PowerShell.PSConsoleReadLine]::AddToHistory($line)
	
	# Clear input line
	[Microsoft.PowerShell.PSConsoleReadLine]::RevertLine()
}