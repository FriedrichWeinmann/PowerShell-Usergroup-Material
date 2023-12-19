# failsafe
return

# Register the scriptblock
Register-PSFArgumentTransformationScriptblock -Name 'MyModule.Answer' -Scriptblock {
    if ('Answer' -eq $_) { 42 }
    # Can be as long as needed, only the first output object will be used
}

# Apply to function
function Get-Number {
    [CmdletBinding()]
    param (
        [PSFramework.Utility.ScriptTransformation('MyModule.Answer', [int])]
        [int]
        $Number
    )
    $Number
}

# Test things
Get-Number -Number 12
Get-Number -Number '12'
Get-Number -Number foo
Get-Number -Number Answer