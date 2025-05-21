function Start-Something {
	[CmdletBinding()]
	param (
		
	)

	"Starting something" | Add-Content -Path 'F:\temp\demo\phase1.txt'
	# ...
	"Starting something - Finished" | Add-Content -Path 'F:\temp\demo\phase1.txt'
}

"Starting Script" | Set-Content -Path 'F:\temp\demo\phase1.txt'
"Step 1" | Add-Content -Path 'F:\temp\demo\phase1.txt'
Start-Something
"Step 1: Starting with Max" | Add-Content -Path 'F:\temp\demo\phase1.txt'
try { 1 / 0 }
catch { "Failed badly: $_" | Add-Content -Path 'F:\temp\demo\phase1.txt' }