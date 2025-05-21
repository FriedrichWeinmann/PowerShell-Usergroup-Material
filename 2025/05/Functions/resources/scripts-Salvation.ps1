#Requires -RunAsAdministrator
#Requires -PSSnapin VMware.VimAutomation.Core
#Requires -PSSnapin VMware.VimAutomation.Vds

<#
.SYNOPSIS
    Gather data on VMs and report on them.

.DESCRIPTION
    Gather data on VMs and report on them.
    This is focused on storage consumption and snapshot requirements.

    This report can be exported to file, written to screen or provided as output.

.PARAMETER Path
    The path to a text file containing VM names to process.

.PARAMETER Name
    Explicit list of names of VMs to process.

.PARAMETER ExportPath
    Path to a folder, to which the results will be written as a mix of Text, CSV & Json files.

.PARAMETER StrictMatch
    By default, VM names are interpreted with a trailing wildcard (so any specified input will be matched against the beginning of the VM names).
    Enabling StrictMatch will make the script take the literal approach to VM retrieval.

.PARAMETER Quiet
    Disable most verbosity on screen.
    By default, results are written/presented to the console screen.

.PARAMETER PassThru
    Return results as objects.

.EXAMPLE
    PS C:\> .\vmreport.ps1

    Generate a VMReport in interactive mode, drawing results on the console screen.

.EXAMPLE
    PS C:\> .\vmreport.ps1 -Path C:\config\vmsreport.txt -ExportPath \\server\share\reports\vms -StrictMatch

    Create a report based on the VMs found in 'C:\config\vmsreport.txt' and write it to '\\server\share\reports\vms'

.NOTES
    Author: Max Mustermann, Friedrich Weinmann
    Version: 2.0.0
    Created: 2016-07-01
    Updated: 2021-07-02

    History:
    2.0.0 (2021-07-02)
    - Refactor

    1.0.0 (2016-07-01)
    - Initial release
#>
[CmdletBinding()]
param (
    [ValidateScript( {
        if (-not (Test-Path $_ -PathType Leaf)) {
            Write-Warning "Not a file: $_"
            throw "Not a file: $_"
        }
        $true
    })]
    [string]
    $Path,

    [string[]]
    $Name,

    [ValidateScript( {
            if (-not (Test-Path $_ -PathType Container)) {
                Write-Warning "Not a folder: $_"
                throw "Not a folder: $_"
            }
            $true
        })]
    [string]
    $ExportPath,

    [switch]
    $StrictMatch,

    [switch]
    $Quiet,

    [switch]
    $PassThru
)

[System.Net.ServicePointManager]::SecurityProtocol += [System.Net.SecurityProtocolType]::Tls12

#region Functions
function Get-UserInput {
    [CmdletBinding()]
    param (
        [string]
        $Message
    )

    Write-Host $Message
    Write-Host @'

Enter one value per line.
To finish input, submit an empty line.

'@
    while ($true) {
        $userInput = Read-Host -Prompt ': '
        if (-not $userInput) { return }
        $userInput
    }
}

function Show-OpenFileDialog {
    <#
    .SYNOPSIS
        Show an Open File dialog using WinForms.

    .DESCRIPTION
        Show an Open File dialog using WinForms.

    .PARAMETER InitialDirectory
        The initial directory from which the user gets to pick a file.
        Defaults to the current path.

    .PARAMETER Title
        The window title to display.

    .PARAMETER MultiSelect
        Whether the user may pick more than one file.

    .EXAMPLE
        PS C:\> Show-OpenFileDialog

        Opens a file selection dialog in the current folder
    #>
    [OutputType([string])]
    [CmdletBinding()]
    param (
        [string]
        $InitialDirectory = '.',

        [string]
        $Title,

        [switch]
        $MultiSelect
    )

    process {
        Add-Type -AssemblyName System.Windows.Forms
        $dialog = [System.Windows.Forms.OpenFileDialog]::new()
        $dialog.InitialDirectory = Resolve-Path -Path $InitialDirectory
        $dialog.MultiSelect = $MultiSelect.ToBool()
        $dialog.Title = $Title
        $null = $dialog.ShowDialog()
        $dialog.FileNames
    }
}

function Get-UserChoice
{

    <#
	.SYNOPSIS
		Prompts the user to choose between a set of options.

	.DESCRIPTION
		Prompts the user to choose between a set of options.
		Returns the index of the choice picked as a number.

	.PARAMETER Options
		The options the user may pick from.
		The user selects a choice by specifying the letter associated with a choice.
		The letter assigned to a choice is picked from the character after the first '&' in any specified string.
		If there is no '&', the system will automatically pick the first letter as choice letter:
		"This &is an example" will have the character "i" bound for the choice.
		"This is &an example" will have the character "a" bound for the choice.
		"This is an example" will have the character "T" bound for the choice.

		This parameter takes both strings and hashtables (in any combination).
		A hashtable is expected to have two properties, 'Label' and 'Help'.
		Label is the text shown in the initial prompt, help what the user sees when requesting help.

	.PARAMETER Caption
		The title of the question, so the user knows what it is all about.

    .PARAMETER Vertical
        Displays the options vertically, one per line, rather than the default side-by-side display.
        Each option will be numbered.
        Option numbering starts at 1, return will always be one lower than the selected number.

	.PARAMETER Message
		A message to offer to the user. Be more specific about the implications of this choice.

	.PARAMETER DefaultChoice
		The index of the choice made by default.
		By default, the first option is selected as default choice.

	.EXAMPLE
		PS C:\> Get-UserChoice -Options "1) Create a new user", "2) Disable a user", "3) Unlock an account", "4) Get a cup of coffee", "5) Exit" -Caption "User administration menu" -Message "What operation do you want to perform?"

		Prompts the user for what operation to perform from the set of options provided
#>
    [OutputType([System.Int32])]
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)]
        [object[]]
        $Options,

        [string]
        $Caption,

        [switch]
        $Vertical,

        [string]
        $Message,

        [int]
        $DefaultChoice = 0
    )

    begin {
        #region Vertical Options Display
        if ($Vertical) {
            $optionStrings = foreach ($option in $Options) {
                if ($option -is [hashtable]) { $option.Keys }
                else { $option }
            }
            $count = 1
            $messageStrings = foreach ($optionString in $OptionStrings) {
                "$count $optionString"
                $count++
            }
            $count--
            $Message = ((@($Message) + @($messageStrings)) -join "`n").Trim()
            $choices = 1..$count | ForEach-Object { "&$_" }
        }
        #endregion Vertical Options Display

        #region Default Options Display
        else {
            $choices = @()
            foreach ($option in $Options) {
                if ($option -is [hashtable]) {
                    $label = $option.Keys -match '^l' | Select-Object -First 1
                    [string]$labelValue = $option[$label]
                    $help = $option.Keys -match '^h' | Select-Object -First 1
                    [string]$helpValue = $option[$help]

                }
                else {
                    $labelValue = "$option"
                    $helpValue = "$option"
                }
                if ($labelValue -match "&") { $choices += New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList $labelValue, $helpValue }
                else { $choices += New-Object System.Management.Automation.Host.ChoiceDescription -ArgumentList "&$($labelValue.Trim())", $helpValue }
            }
        }
        #endregion Default Options Display
    }
    process {
        # Will error on one option so we just return the value 0 (which is the result of the only option the user would have)
        # This is for cases where the developer dynamically assembles options so that they don't need to ensure a minimum of two options.
        if ($Options.Count -eq 1) { return 0 }

        $Host.UI.PromptForChoice($Caption, $Message, $choices, $DefaultChoice)
    }

}

function Get-VMList {
    [CmdletBinding()]
    param (
        [AllowEmptyString()]
        [string]
        $Path,

        [AllowEmptyCollection()]
        [AllowNull()]
        [string[]]
        $Name
    )

    #region Values provided as script parameters
    if ($Path) {
        Get-Content -Path $Path
    }
    if ($Name) {
        $Name
    }
    if ($Name -or $Path) { return }
    #endregion Values provided as script parameters

    $choice = Get-UserChoice -Caption 'Select Source of VMs to process' -Options 'Skip afterall', 'Manual Entry', 'Import from File' -Vertical
    switch ($choice) {
        0 {
            Write-Warning "Selected to not process VMs after all"
            return
        }
        1 { Get-UserInput -Message 'Enter VM names' }
        2 {
            $files = Show-OpenFileDialog -Title 'Select Text-File with VM names' -MultiSelect
            if (-not $files) {
                Write-Warning "No file selected!"
            }
            foreach ($file in $files) {
                Get-Content -Path $file
            }
        }
    }
}

function Get-VirtualMachine {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]
        $Name,

        [switch]
        $StrictMatch,

        [switch]
        $Quiet
    )

    process {
        foreach ($entry in $Name) {
            $nameValue = $entry
            if (-not $StrictMatch) { $nameValue = "$entry*" }

            try { $vms = Get-VM -Name $entry -ErrorAction Stop }
            catch {
                Write-Warning "Error retrieving VM $entry : $_"
                Write-Error $_
                continue
            }

            #region Non-Quiet: Write to Screen
            if (-not $Quiet) {
                if (-not $vms) {
                    Write-Host "$entry" -NoNewline -BackgroundColor black
                    Write-Host " NOT FOUND " -ForegroundColor Red -BackgroundColor black
                    continue
                }

                Foreach ($vm in $vms) {
                    Write-Host "$vm" -NoNewline
                    Write-Host " FOUND " -ForegroundColor green -NoNewline
                    Write-Host "in vCnter Server: " -ForegroundColor Yellow -NoNewline
                    Write-Host "$(([string]$vm.Uid.Split(":")[0].Split("@")[1]).ToUpper())" -ForegroundColor Green
                }
            }
            #endregion Non-Quiet: Write to Screen

            $vms
        }
    }
}

function Write-ChangeText {
    [CmdletBinding()]
    param (
        $VirtualMachines,

        [switch]
        $Quiet,

        [string]
        $Path
    )

    $messageFormat = @'


{0:yyyy-MM-dd}
============================================================================
Preliminary validation performed on {0:yyyy-MM-dd}
Final validation DUE: 2021-06-00 @ 15:00 EDT  -


N O T E :

{1}
'@
    $vmStrings = foreach ($virtualMachine in $VirtualMachines) {
        "-  A snapshot of $virtualMachine is approved as long as it is removed at the end of the change window."
    }
    $finishedMessage = $messageFormat -f (Get-Date), ($vmStrings -join "`n")

    if (-not $Quiet) {
        Write-Host $finishedMessage
    }
    if ($Path) {
        $finishedMessage | Set-Content -Path (Join-Path -Path $Path -ChildPath 'change.txt')
    }
}

function Convert-VMData {
    [CmdletBinding()]
    param (
        $VirtualMachine
    )

    Write-Verbose "Processing: $($VirtualMachine.Name)"

    #region Process VM Object itself
    $result = [PSCustomObject][ordered]@{
        VMObject                   = $VirtualMachine
        VMName                     = $VirtualMachine.Name
        IPAddress                  = $VirtualMachine.Guest.IPAddress | Where-Object { $_ -like "*.*.*.*" }
        UUID                       = $VirtualMachine.ExtensionData.Config.Uuid
        Snapshots                  = $VirtualMachine | Get-Snapshot | Sort-Object
        SnapshotInfo               = @()
        HasSnapshots               = $false
        VCenter                    = ([string]$VirtualMachine.Uid.Split(":")[0].Split("@")[1]).ToUpper()
        Disks                      = $VirtualMachine | Get-Harddisk
        DiskInfo                   = @()
        HddTotalSize               = $null
        Datastore                  = $VirtualMachine.ExtensionData.Layout.Disk.diskfile.Split("[")[1].Split("]")[0]
        DatastoreSpaceFree         = '{0:N2}' -f (Get-Datastore $VM_DATASTORE).FreeSpaceGB

        SnapshotMaxSize            = 0
        PostSnapshotSpaceAvailable = 0
    }
    $result.HasSnapshots = $result.Snapshots -as [bool]
    $result.HddTotalSize = ($result.Disks | Measure-Object CapacityGB -Sum).Sum
    $result.SnapshotMaxSize = '{0:N2}' -f ($result.HddTotalSize * 1.2)
    $result.PostSnapshotSpaceAvailable = $result.DatastoreSpaceFree - ($result.HddTotalSize * 1.2)
    if (-not $result.IPAddress) { $result.IPAddress = 'IP Address N/A' }
    #endregion Process VM Object itself

    #region Adding DiskInfo
    $result.DiskInfo = foreach ($disk in $result.Disks) {
        $datastore = $disk.filename.Split("[")[1].Split("]")[0]
        $diskInfo = [PSCustomObject]@{
            VMName             = $result.VMName
            Name               = $disk.Name
            SizeGB             = $disk.CapacityGB
            Type               = $disk.Persistence
            Format             = $disk.StorageFormat
            DataStore          = $datastore
            DataStoreSpaceFree = '{0:N2}' -f (Get-Datastore -Name $datastore)[0].FreeSpaceGB
        }
        if ($diskInfo.Format -like "*Eager*") { $diskInfo.Format = "E0 Thick" }
        $diskInfo
    }
    #endregion Adding DiskInfo

    #region Adding SnapshotInfo
    $index = 1
    $result.SnapshotInfo = foreach ($snapshot in $result.Snapshots) {
        [PSCustomObject]@{
            VMName      = $result.VMName
            Index       = $index
            Name        = $snapshot.Name
            Created     = $snapshot.Created
            Description = $snapshot.Description
            SizeGB      = '{0:N2}' -f $snapshot.SizeGB
        }
        $index++
    }
    #endregion Adding SnapshotInfo

    $result
}

function Export-VMData {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $VMData,

        [string]
        $Path
    )

    begin {
        $vmSummaryPath = Join-Path -Path $Path -ChildPath 'VMSummary.csv'
        $diskSummaryPath = Join-Path -Path $Path -ChildPath 'DiskSummary.csv'
        $snapshotSummaryPath = Join-Path -Path $Path -ChildPath 'SnapshotSummary.csv'

        Remove-Item -Path $vmSummaryPath -Force -ErrorAction Ignore
        Remove-Item -Path $diskSummaryPath -Force -ErrorAction Ignore
        Remove-Item -Path $snapshotSummaryPath -Force -ErrorAction Ignore
    }
    process {
        $VMData | Export-Csv -Path $vmSummaryPath -Append
        $VMData.DiskInfo | Export-Csv -Path $diskSummaryPath -Append
        $VMData.SnapshotInfo | Export-Csv -Path $snapshotSummaryPath -Append
        $VMData | ConvertTo-Json -Depth 4 | Set-Content -Path (Join-Path -Path $Path -ChildPath "$($VMData.VMName).json") -Encoding UTF8
    }
}

function Write-VMData {
    [CmdletBinding()]
    param (
        [Parameter(ValueFromPipeline = $true)]
        $VMData,

        [switch]
        $Quiet
    )

    process {
        if ($Quiet) { return }

        Write-Host ""
        Write-Host ""
        Write-Host " $($VMData.VMName)" -ForegroundColor Green -NoNewline
        Write-Host "  ($VMData.IPAddress)"
        Write-Host @"
============================================================================
 vCenter Name                   : $($VMData.VCenter)
 VM Serial #/UUID               : $($VMData.UUID)
 VM Data Store(s)               : $($VMData.Datastore)
 VM Hard Drives present         : $($($VMData.Disks).count)
"@

        Write-Host @'

  Disks
-----------------------------------------------------------------------------------------------------------------
'@ -ForegroundColor Green
        $VMData.DiskInfo | Format-Table Name, SizeGB, Type, DataStoreSpaceFree, Format, Datastore | Out-Host

        Write-Host @"

 VM TOTAL allocated SPACE       : $($VMData.HddTotalSize) GB
 Space required for snapshot    : $($VMData.SnapshotMaxSize) GB  (TOTAL allocated SPACE + 20%)
 Space remaining after snapshot : $($VMData.PostSnapshotSpaceAvailable) GB
 VM Snapshots present           : $($VMData.HasSnapshots)
"@
        if ($VMData.HasSnapshots) {
            Write-Host @'

  Snapshots
-----------------------------------------------------------------------------------------------------------------
'@ -ForegroundColor Green
        }

        foreach ($snapshot in $VMData.SnapshotInfo) {
            Write-Host @"

      Snapshot $($snapshot.Index)
      ========================
      Snapshot Name         : $($snapshot.Name)
      Snapshot Created      : $($snapshot.Created)
      Snapshot Description  : $($snapshot.Description)
      Snapshot Size (in GB) : $($snapshot.SizeGB)
"@
        }
    }
}
#endregion Functions

$virtualMachines = Get-VMList -Path $Path -Name $Name | Get-VirtualMachine -StrictMatch:$StrictMatch -Quiet:$Quiet | Sort-Object -Unique
Write-ChangeText -VirtualMachines $virtualMachines -Quiet:$Quiet -Path $ExportPath
foreach ($virtualMachine in $virtualMachines) {
    $vmData = Convert-VMData -VirtualMachine $virtualMachine
    $vmData | Export-VMData -Path $ExportPath
    $vmData | Write-VMData -Quiet:$Quiet
    if ($PassThru) { $vmData }
}