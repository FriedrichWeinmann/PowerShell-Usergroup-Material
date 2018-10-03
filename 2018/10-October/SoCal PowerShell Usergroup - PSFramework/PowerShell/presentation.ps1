# Failsafe
break

 #----------------------------------------------------------------------------# 
 #                               Configuration                                # 
 #----------------------------------------------------------------------------# 

# It's a menu of settings
Get-PSFConfig

# Get a specific setting
Get-PSFConfig -FullName 'DemoModule.Setting1'

# Define a set of them and persist them
Set-PSFConfig -Module DemoModule -Name Setting2 -Value 24 -SimpleExport
Set-PSFConfig -Module DemoModule -Name Setting3 -Value 25 -SimpleExport
Set-PSFConfig -Module DemoModule -Name Setting4 -Value 26 -SimpleExport
Set-PSFConfig -Module DemoModule -Name Setting5 -Value 27 -SimpleExport
Set-PSFConfig -Module DemoModule -Name Setting6 -Value 28 -SimpleExport

Get-PSFConfig -Module DemoModule | Export-PSFConfig -OutPath demo:\config.json
code .\config.json

Start-Process powershell.exe -ArgumentList '-NoExit', '-NoProfile'

# Automatic Persistence
Get-PSFConfig -FullName 'DemoModule.Setting1' | Register-PSFConfig
Start-Process powershell.exe -ArgumentList '-NoExit', '-NoProfile'

 #----------------------------------------------------------------------------# 
 #                             Message / Logging                              # 
 #----------------------------------------------------------------------------# 

# Live in action is always the best
Start-Process powershell.exe -ArgumentList '-NoExit', '-NoProfile'

function Get-Test
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]
        $ComputerName
    )

    begin {
        Write-PSFMessage -Level Verbose -Message 'Getting started'
    }
    process {
        foreach ($computer in $ComputerName)
        {
            Write-PSFMessage -Level VeryVerbose -Message "Getting started with $computer" -Target $computer -Tag 'beginning'

            Write-PSFMessage -Level Debug -Message "Going wicked on $computer" -Target $computer
            $computer.ToLower()
            Write-PSFMessage -Level Verbose -Message "Finished with $computer" -Target $computer -Tag 'finished'
        }
    }
    end {
        Write-PSFMessage -Level Verbose -Message 'Wrapping things up'
    }
}

# Testing it out
"server1", "server2", "server3" | Get-Test -Debug

# Tracking messages
"server4", "SerVer5", "server6" | Get-Test | Get-Test | Get-Test

# Show the logging!

 #----------------------------------------------------------------------------# 
 #                               Tab Expansion                                # 
 #----------------------------------------------------------------------------# 

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

function Get-Water
{
    [CmdletBinding()]
    param (
        [string]
        $Type
    )
    Write-Host "This is boring"
}
Register-PSFTeppScriptblock -Name 'water-type' -ScriptBlock {
    Start-Sleep -Seconds 2
    Get-Content -Path .\water.txt
} -CacheDuration 30s
Register-PSFTeppArgumentCompleter -Command Get-Water -Parameter Type -Name water-type
'Plain','Ugh' | Set-Content .\water.txt
'Plain','Ugh','Does wine count as water?' | Set-Content .\water.txt

 #----------------------------------------------------------------------------# 
 #                              PowerShell Tasks                              # 
 #----------------------------------------------------------------------------# 

# Let's avoid having to wait on tab completion _ever_
Register-PSFTaskEngineTask -Name 'refresh-water-type' -ScriptBlock {
    Set-PSFTeppResult -TabCompletion 'water-type' -Value (Get-Content -Path .\water.txt)
} -Interval 15s

# Cleaning up some temp data so we don't clutter the temp folder
Register-PSFTaskEngineTask -Name 'Cleanup-temp' -ScriptBlock {
    Get-ChildItem $env:temp -Filter DemoModule* | Remove-Item -Force -Recurse
} -Once -Delay '1m' -Priority Low

# Doing it again
Register-PSFTaskEngineTask -Name 'Cleanup-temp' -ScriptBlock {
    Get-ChildItem $env:temp -Filter DemoModule* | Remove-Item -Force -Recurse
} -Once -ResetTask

 #----------------------------------------------------------------------------# 
 #                             Parameter Classes                              # 
 #----------------------------------------------------------------------------# 

[PSFComputer]"server1"
[PSFComputer]"Foo bar"
[PSFComputer]"Server = server1;"
[PSFComputer](Resolve-DnsName -Name localhost -Type A)
[PSFComputer]"."

function Get-Computer
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [PSFComputer[]]
        $ComputerName = $env:COMPUTERNAME,

        [PSFDateTime]
        $LastOnline = "-7d"
    )
    process {
        foreach ($computer in $ComputerName) {
            Write-PSFMessage -Level Host -Message "Looking for $computer if it has been online since $LastOnline"
        }
    }
}

"server1", "server2", "server3" | Get-Computer -LastOnline "-14d" # (Get-Date).AddDays(-14)

# Extend it
$obj = [PSCustomObject]@{
    Name = "Server"
    Latency = 'incredible'
}
$obj | Get-Computer
# Damn, what now?

# 1) Give it a name
$obj = [PSCustomObject]@{
    PSTypeName = 'DemoModule.Computer.Latency'
    Name = "Server"
    Latency = 'incredible'
}
# 2) Tell the PSFramework what to do with it
Register-PSFParameterClassMapping -ParameterClass Computer -TypeName 'DemoModule.Computer.Latency' -Properties Name
# 3) Laugh in triumph
$obj | Get-Computer

 #----------------------------------------------------------------------------# 
 #                           Validation Attributes                            # 
 #----------------------------------------------------------------------------# 

# Scriptblock validation
function Get-Test
{
    [CmdletBinding()]
    param (
        [PsfValidateScript({ Test-path $args[0]}, ErrorMessage = 'Path does not exist: {0}')]
        [string]
        $Path
    )
}

Get-Test -Path "C:\Windows"
Get-Test -Path "C:\fakefolder"

# Pattern validation
function Get-MoreTest
{
    [CmdletBinding()]
    param (
        [PsfValidatePattern('^([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9])(\.([a-zA-Z0-9]|[a-zA-Z0-9][a-zA-Z0-9\-_]{0,61}[a-zA-Z0-9]))*$|^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)(\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)){3}$|^(?:^|(?<=\s))(([0-9a-fA-F]{1,4}:){7,7}[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,7}:|([0-9a-fA-F]{1,4}:){1,6}:[0-9a-fA-F]{1,4}|([0-9a-fA-F]{1,4}:){1,5}(:[0-9a-fA-F]{1,4}){1,2}|([0-9a-fA-F]{1,4}:){1,4}(:[0-9a-fA-F]{1,4}){1,3}|([0-9a-fA-F]{1,4}:){1,3}(:[0-9a-fA-F]{1,4}){1,4}|([0-9a-fA-F]{1,4}:){1,2}(:[0-9a-fA-F]{1,4}){1,5}|[0-9a-fA-F]{1,4}:((:[0-9a-fA-F]{1,4}){1,6})|:((:[0-9a-fA-F]{1,4}){1,7}|:)|fe80:(:[0-9a-fA-F]{0,4}){0,4}%[0-9a-zA-Z]{1,}|::(ffff(:0{1,4}){0,1}:){0,1}((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])|([0-9a-fA-F]{1,4}:){1,4}:((25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9])\.){3,3}(25[0-5]|(2[0-4]|1{0,1}[0-9]){0,1}[0-9]))(?=\s|$)$', ErrorMessage = "Could not validate as computername: {0}")]
        [string]
        $ComputerName
    )
}
Get-MoreTest -ComputerName foo
Get-MoreTest -ComputerName 'foo bar'

# ValidateSet?
function Get-Alcohol
{
    [CmdletBinding()]
    Param (
        [PsfValidateSet(TabCompletion = 'alcohol')]
        [string]
        $Type,

        [string]
        $Unit = "Pitcher"
    )

    Write-Host "Drinking a $Unit of $Type"
}

Register-PSFTeppScriptblock -Name "alcohol" -ScriptBlock { 'Beer','Mead','Whiskey','Wine','Vodka','Rum (3y)', 'Rum (5y)', 'Rum (7y)' }
Register-PSFTeppArgumentCompleter -Command Get-Alcohol -Parameter Type -Name alcohol

 #----------------------------------------------------------------------------# 
 #                                Flow Control                                # 
 #----------------------------------------------------------------------------# 

# Testing your environment
Test-PSFPowerShell -Elevated -PSMinVersion '4.0' -PSMaxVersion '6.0' -Edition Desktop -OperatingSystem Windows

# Opt-in exceptions
function Get-Flow
{
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $InputObject,

        [switch]
        $DieBegin,

        [switch]
        $DieEnd,

        [switch]
        $EnableException
    )

    begin {
        if ($DieBegin) {
            Stop-PSFFunction -Message 'Terminating execution on command' -EnableException $EnableException
            return
        }
    }
    process {
        if (Test-PSFFunctionInterrupt) { return }

        foreach ($item in $InputObject)
        {
            if ($item -eq 2) { Stop-PSFFunction -Message "Detected an evil number 2, not going to work with THAT!" -Continue -EnableException $EnableException }
            $item
        }
    }
    end {
        if (Test-PSFFunctionInterrupt) { return }

        if ($DieEnd) {
            Stop-PSFFunction -Message 'Terminating execution on command' -EnableException $EnableException
            return
        }
    }
}
1..3 | Get-Flow -DieBegin
1..3 | Get-Flow -DieBegin -EnableException
try { 1..3 | Get-Flow -DieBegin -EnableException }
catch { Write-PSFMessage -Level Warning -Message "Something went wrong" -ErrorRecord $_ }
1..3 | Get-Flow
1..3 | Get-Flow -EnableException
1..3 | Get-Flow -DieEnd
1..3 | Get-Flow -DieEnd -EnableException

# Do we really want to do this?
function Get-Tentative
{
    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        [PSFComputer]
        $ComputerName
    )
    if (Test-PSFShouldProcess -PSCmdlet $PSCmdlet -Target $ComputerName -Action "Doing nefarious deeds with") {
        Write-PSFMessage -Level Host -Message "1337"
    }
}

 #----------------------------------------------------------------------------# 
 #                               Serialization                                # 
 #----------------------------------------------------------------------------# 

Get-ChildItem -Path C:\Windows | Export-Clixml -Path .\bigandnasty.clixml
Get-ChildItem -Path C:\Windows | Export-PSFClixml -Path .\slimandnice.clidat
Get-ChildItem

 #----------------------------------------------------------------------------# 
 #                                Miscellanea                                 # 
 #----------------------------------------------------------------------------# 

# Select-PSFObject
Get-ChildItem | Select-Object Name, Length
Get-ChildItem | Select-Object Name, @{
    Name = "Size"
    Expression = { $_.Length }
}

Get-ChildItem | Select-PSFObject Name, 'Length as Size'
Get-ChildItem | Select-PSFObject Name, 'Length as Size size KB:2:1'

Import-Csv "$filesRoot\..\files.csv" | Select-Object Name, Length | Sort-Object Length
Import-Csv "$filesRoot\..\files.csv" | Select-PSFObject Name, 'Length to long' | Sort-Object Length
Import-Csv "$filesRoot\..\files.csv" | 
  Select-PSFObject *, 'Length to long as Size' -ShowProperty Name, Size |
  Sort-Object Size
Import-Csv "$filesRoot\..\files.csv" | 
  Select-PSFObject *, 'Length to long as Size' -ShowProperty Name, Size |
  Sort-Object Size |
  Format-Table * -AutoSize

$list = @()
$list += [PSCustomObject]@{ FileLength = 839710; Text = "Nasty thing" }
$list += [PSCustomObject]@{ FileLength = 692; Text = "Bossy thing" }
$list += [PSCustomObject]@{ FileLength = 11906; Text = "Nice thing" }
$list += [PSCustomObject]@{ FileLength = 1111; Text = "Safely resolving thing" }
$list += [PSCustomObject]@{ FileLength = 12; Text = "Watery thing" }
$list += [PSCustomObject]@{ FileLength = 666; Text = "The end of all things" }

Import-Csv "$filesRoot\..\files.csv" | Select-PSFObject Name, 'Length to long', 'Text from list where FileLength = Length'