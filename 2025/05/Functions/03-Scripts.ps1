# failsafe
return

# A simple script
code "$presentationRoot\resources\myscript.ps1"
& "$presentationRoot\resources\myscript.ps1"


# ExecutionPolicy

<#
More on PowerShell Security (and how to do it right):
PSConfEU: PowerShell Security
https://www.youtube.com/watch?v=M261YjSKj4w
#>


# Putting my functions into a script
code "$presentationRoot\resources\Get-RandomNumber.ps1"
"$presentationRoot\resources\Get-RandomNumber.ps1"
& "$presentationRoot\resources\Get-RandomNumber.ps1"
Get-RandomNumber

# dotsourcing:
. "$presentationRoot\resources\Get-RandomNumber.ps1"
Get-RandomNumber


# Including Files into your script The Right Way
#-> The Problem
code "$presentationRoot\resources\script1.ps1"
code "$presentationRoot\resources\script2.ps1"
'Write-Host "Script 2 fired"' | Set-Content -Path "$presentationRoot\resources\script2.ps1"
@'
Write-Host "Script 1 fired"
& .\script2.ps1
'@ | Set-Content -Path "$presentationRoot\resources\script1.ps1"

& "$presentationRoot\resources\script1.ps1"

#-> Now let's fix this
@'
Write-Host "Script 1 fired"
& $PSScriptRoot\script2.ps1
'@ | Set-Content -Path "$presentationRoot\resources\script1.ps1"

& "$presentationRoot\resources\script1.ps1"

#-> Let's do that again with that logging script
Copy-Item -Path "$presentationRoot\resources\scripts-LoggingYay.ps1" -Destination "$presentationRoot\resources\scripts-LoggingYay2.ps1"
code "$presentationRoot\resources\scripts-LoggingYay2.ps1"
code "$presentationRoot\resources\lib-logging.ps1"
& "$presentationRoot\resources\scripts-LoggingYay2.ps1"
code .\phase2.csv


# Next: Parameters are evil - let's bring the cookies
code "$presentationRoot\04-Parameters.ps1"