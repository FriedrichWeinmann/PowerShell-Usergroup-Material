# Uses Scriptblocks and will take longer
Measure-Command { 1 .. 100000 | Where-Object { $_ -gt 50000 } }

# Uses LINQ and is usually a lot faster. PowerShell 4+ only
Measure-Command { (1 .. 100000).Where({ $_ -gt 50000 }) }

