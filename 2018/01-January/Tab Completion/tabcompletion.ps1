# 1) Live Demo PSReadline Tab Completion
## a) Tab it and CTRL-SPACE it!
## b) Rebinding Tab Completion Keys

# Key Actions:
# Browse: MenuComplete
# Cycle forwards: TabCompleteNext
# Cycle backwards: TabCompletePrevious
Set-PSReadlineKeyHandler -Chord Tab -Function MenuComplete
Set-PSReadlineKeyHandler -Chord Ctrl+Spacebar -Function TabCompleteNext
Set-PSReadlineKeyHandler -Chord Shift+Ctrl+Spacebar -Function TabCompletePrevious

# 2) Where does tab completion come from?
## a) Parameters: Tabbing priority and parameter aliases
# It knows, because the command is stored in the system and it has access to the parameter definitions
function Get-Test
{
    [CmdletBinding()]
    Param (
        [Alias('Foo')]
        $Bar,

        $Fred
    )
}
# Tab it!
# Get-Test -<TAB>
# Get-Test -F<TAB>

## b) Parameter Values: Filesystem
# Get-Test -Bar <TAB>

## c) Parameter Values: ValidateSet
function Get-Test
{
    [CmdletBinding()]
    Param (
        [ValidateSet('Test','Foo','Bar')]
        [string]
        $Bar
    )
}
# Get-Test -Bar <TAB>

## d) Parameter Values: Enumerations
function Get-Test
{
    [CmdletBinding()]
    Param (
        [DayOfWeek]
        $Bar
    )
}
# Get-Test -Bar <TAB>

<#
And what if we want other completion forms?
What if we need conditional completion?

--> Enter custom tabcompletion
#>

# 3) Custom Tabcompletion
# Note: This chapter requires the PSFramework module
# First of all a function to complete:
function Get-Alcohol
{
    [CmdletBinding()]
    Param (
        [string]
        $Type,

        [string]
        $Unit = "Pitcher"
    )

    Write-Host "Drinking a $Unit of $Type"
}

# a) Offering common custom tabcompletion
# Create scriptblock that collects information and name it
Register-PSFTeppScriptblock -Name "alcohol" -ScriptBlock { 'Beer','Mead','Whiskey','Wine','Vodka','Rum (3y)', 'Rum (5y)', 'Rum (7y)' }

# Assign scriptblock to function
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Type -Name alcohol

# Tab it:
# Get-Alcohol -Type <TAB>

# b) Offering conditional custom tabcompletion
# Create scriptblock that checks what was bound to '-Type' so far and name it
Register-PSFTeppScriptblock -Name "alcohol-unit" -ScriptBlock {
    switch ($fakeBoundParameter.Type)
    {
        'Mead' { 'Mug', 'Horn', 'Barrel' }
        'Wine' { 'Glas', 'Bottle' }
        'Beer' { 'Halbes Maß', 'Maß' }
        default { 'Glas', 'Pitcher' }
    }
}

# Assign scriptblock to function
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Unit -Name "alcohol-unit"

# Tab it:
# Get-Alcohol -Type <TAB> -Unit <TAB>