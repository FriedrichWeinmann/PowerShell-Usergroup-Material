$Tokens = @()
$ast = [System.Management.Automation.Language.Parser]::ParseFile("C:\Users\Bosparan\AppData\Roaming\Microsoft\Windows\PowerShell\PSReadline\ConsoleHost_history.txt", [ref]$Tokens, [ref]$null)
$Tokens | Where-Object TokenFlags -eq CommandName | Group-Object Text | Sort-Object Count