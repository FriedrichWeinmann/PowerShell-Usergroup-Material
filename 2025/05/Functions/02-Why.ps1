# failsafe
return

<#
Why do we do functions?

- Reusable Code
- Readable Code
#>

# Reusable Code
#-> If you like to suffer
code "$presentationRoot\resources\scripts-LoggingOuch.ps1"
& "$presentationRoot\resources\scripts-LoggingOuch.ps1"
code 'F:\temp\demo\phase1.txt'

#-> Imagine a better world
code "$presentationRoot\resources\scripts-LoggingYay.ps1"
& "$presentationRoot\resources\scripts-LoggingYay.ps1"
code 'F:\temp\demo\phase2.csv'


# Readable Code
#-> Brace yourself before opening
code "$presentationRoot\resources\scripts-TheNightmare.ps1"

#-> You probably need something to sooth your fried nerves right now
code "$presentationRoot\resources\scripts-Salvation.ps1"

<#
Want to go deeper into those examples?
Recording: PSConfEU 2023: Script Design
https://www.youtube.com/watch?v=EWIu0Ywrtsk
#>

# Next: Weren't we talking about functions? Why do we look at scripts now?!
code "$presentationRoot\03-Scripts.ps1"