<##########################################################################
#
#     SCRIPT
#
#--------------------------------------------------------------------------
#
#      NAME: CHECK_VM_DATASTORE_AVAILABLE_SPACE_for_Snapshots__NO_DISCONNECT.ps1
#    AUTHOR: Max Mustermann
# Copyright: Contoso Corp.
#
#
# # External Code
#===================
# 		Functions: Pause
# 		Functions Author: Adam's Tech Blog
# 		URL: https://adamstech.wordpress.co/2011/05/12/how-to-properly-pause-a-powershell-script/
#
# 		Functions: Show-Menu (used as a template)
# 		Functions Author: Adam Bertram
# 		URL: http://www.tomsitpro.com/articles/powershell-interactive-menu,2-961.html
#
#
# COMMENT:
#
# VERSION HISTORY:
# 1.0 2016-07-01 - Initial release
#
###########################################################################>

$ErrorActionPreference = 'stop'


<#  Check if PowerShell is running with ELEVATED permision (As Administrator.)
 #  If TRUE:  Run the script.
 #  If FALSE: Prompt user to reopen session as Administrator then exit.
 #=========================================================================#>

If (([bool](([System.Security.Principal.WindowsIdentity]::GetCurrent()).groups -match "S-1-5-32-544")) -ne "True") {
    Clear-Host
    Write-Host "========================================================================="   -ForegroundColor green
    Write-Host "             This script requieres ADMINISTRATR priviliges               "   -ForegroundColor Yellow
    Write-Host "=========================================================================`n" -ForegroundColor Green
    Write-Host "Please launch PowerShell/PowerCLI as Administrator"
    Write-Host "then rerun the script.`n`n"
    EXIT
}



<#  Set PS session connection to TLS 1.2 (for PCI VCs)
 #=========================================================================#>

[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;


<#  Set script execution start time/date variable
 #=========================================================================#>

$StartDate = (Get-Date)


<#  Set Sscript execution location to "Script Path."
#=========================================================================#>

$Script_Name = " CHECK_VM_DATASTORE_AVAILABLE_SPACE_for_Snapshots"

$Default_Location = Get-Location

$SCRIPT_ROOT = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SCRIPT_ROOT_PARENT = ((Get-Item $SCRIPT_ROOT ).parent).fullname
$SCRIPT_BASE = ((Get-Item $SCRIPT_ROOT ).parent.parent).fullname
Push-Location $SCRIPT_ROOT


<#  Set the file name for the target servers to query.
 #=============================================================================#>

$VM_List = "CHECK_DATASTORE_AVAILABLE_SPACE_FOR_SNAPSHOTS__TARGET_SERVER_LIST.txt"


<#  Collect and store the Virtual Center servers to connect to.
 #=============================================================================#>

$VC_LIST = Get-Content "$SCRIPT_BASE\vCenter_List.txt"


<#  Add required "VMWare PowerCLI" Snap-Ins.
 #=========================================================================#>

Add-PSSnapin VMware.VimAutomation.Core -ErrorAction SilentlyContinue
Add-PSSnapin VMware.VimAutomation.Vds -ErrorAction SilentlyContinue


<#  Request and store VMWare vCenter ADMIN level credentials.
 #=========================================================================#>

$Admin_Name = "$env:USERNAME@$env:USERDNSDOMAIN"
$CredsFile = $env:LOCALAPPDATA + '\' + (($Admin_Name).replace(".", "-")) + "__PS_ENCRYPTED_Creds"

if ((Test-Path $CredsFile) -eq $true) {
    Write-Host "===================================================================================================" -ForegroundColor Yellow
    Write-Host "                             Establishing connection(s) to vCenter(s)" -ForegroundColor Green
    Write-Host "===================================================================================================" -ForegroundColor Yellow
    Write-Host ""

    $password = Get-Content $CredsFile | ConvertTo-SecureString
    $VC_Creds = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $Admin_Name, $password
}


Else {
    Write-Host "===================================================================================================" -ForegroundColor Yellow
    Write-Host "                             Establishing connection(s) to vCenter(s)" -ForegroundColor Green
    Write-Host "===================================================================================================" -ForegroundColor Yellow
    Write-Host ""
    $VC_Creds = Get-Credential -Credential $null
}


<# Connect to multiple (ALL) vCenter servers.
 #=========================================================================#>
<#
	foreach ($VC in $VC_LIST)
		{
		Write-Host "Connecting to Virtual Center: " -NoNewline
		Write-Host "$vc" -ForegroundColor Green
		Set-PowerCLIConfiguration -DefaultVIServerMode Multiple -InvalidCertificateAction Ignore -Confirm:$false | out-null
		Connect-VIServer $VC -Credential $VC_Creds  -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
		}
#>

<#  Create the user menu used to set the "Server List" file name in the
 #  "$VM_List_File" variable.
 #=========================================================================#>

function Show-Menu {
    param ([string]$Title = 'Please make a selection below')
    Clear-Host
    Write-Host "      CHECK_VM_DATASTORE_AVAILABLE_SPACE_for_Snapshots.ps1         "
    Write-Host "===================================================================" -ForegroundColor Yellow
    Write-Host "                   $Title" -ForegroundColor Green
    Write-Host "===================================================================" -ForegroundColor Yellow
    Write-Host ""
    Write-Host " Press " -NoNewline
    Write-Host "'1'" -NoNewline -ForegroundColor Green
    Write-Host " to import server list from file"
    Write-Host " Press " -NoNewline
    Write-Host "'2'" -NoNewline -ForegroundColor Green
    Write-Host " for MANUAL Server name entry (one per line)"
    Write-Host ""
}


<#  Pause function with Ctrl+C exit feature
 #=========================================================================#>

Function Pause ($Message = " Press any key to continue... or Ctrl+C to exit") {
    If ($psISE) {
        # The "ReadKey" functionality is not supported in the Windows PowerShell ISE.
        $Shell = New-Object -ComObject "WScript.Shell"
        $Button = $Shell.Popup("Click OK to continue.", 0, "Script Paused", 0)
        Return
    }

    Write-Host $Message -BackgroundColor black -ForegroundColor green
    $Ignore =
    16, # Shift (left or right)
    17, # Ctrl (left or right)
    18, # Alt (left or right)
    20, # Caps lock
    91, # Windows key (left)
    92, # Windows key (right)
    93, # Menu key
    144, # Num lock
    145, # Scroll lock
    166, # Back
    167, # Forward
    168, # Refresh
    169, # Stop
    170, # Search
    171, # Favorites
    172, # Start/Home
    173, # Mute
    174, # Volume Down
    175, # Volume Up
    176, # Next Track
    177, # Previous Track
    178, # Stop Media
    179, # Play
    180, # Mail
    181, # Select Media
    182, # Application 1
    183  # Application 2

    $HOST.UI.RawUI.Flushinputbuffer()
    While ($KeyInfo.VirtualKeyCode -Eq $Null -Or $Ignore -Contains $KeyInfo.VirtualKeyCode) {
        $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    }

    Write-Host
}


<#  Manual server name entry function with loop to allow for corrections (Author: Max Mustermann)
 #=========================================================================#>

function Get-UserInput {
    Clear-Host

    Write-Host "=================================================" -ForegroundColor Yellow
    Write-Host " Type one server name per line then hit 'ENTER'" -ForegroundColor Green
    Write-Host " Hit 'ENTER' on a blank line when done" -ForegroundColor green
    Write-Host "=================================================" -ForegroundColor Yellow
    Write-Host ""

    $ServerName = $Null
    $script:Manual_List = @()
    $n = 1

    Do {
        $ServerName = Read-Host " Name of server $n"
        $script:Manual_List += $ServerName
        $n++
    }

    Until ($ServerName -eq "")


    Clear-Host

    Write-Host ""
    Write-Host " You entered the following server names:"
    Write-Host ""
    $Manual_List = $Manual_List | Where-Object { $_ -ne "" }
    $Manual_List
    Write-Host " ...is this correct?"
    Write-Host ""
    Write-Host " Enter 'y' to continue or 'n' to start over: " -BackgroundColor Black -ForegroundColor green -NoNewline
    $DefaultValue = "y"

    $confirm = if ($confirm = (Read-Host "[$DefaultValue]")) {
        $confirm
    }
    else {
        $DefaultValue
    }


    if ($confirm -ne "y") {
        Get-UserInput
    }
}


<#  Present user menu (Show-Menu function)
 #  Loop/redisplay menu if an non-applicable key is pressed
 #  Applicable keys: "1", "2", "NumPad 1", or "NumPad 2"
 #=========================================================================#>

do {
    Show-Menu
    $input = Read-Host " Please make a selection"
}

Until ($input -in 1..2)


<#  Process user input (menu selection) and pause script with an option
 #  to exit script via "CTRL + C" key combination (PAUSE Function)
 #=========================================================================#>

switch ($input) {
    '1' {
        Clear-Host
     			Set-Variable -Name VM_List_File -Value $VM_List
        Write-Host ""
        Write-Host " You are now connected to the following vCenter servers:" -ForegroundColor green -NoNewline
        $defaultviservers | Format-Table
        Write-Host " and you chose to work on " -NoNewline
        Write-Host "Servers from list file " -ForegroundColor Green
        Write-Host ""
        $Chosen_Servers = "Server List file."
    }
    '2' {
        Clear-Host
        Write-Host "===================================================================================================" -ForegroundColor Yellow
        Write-Host "                    Please provide the target VM name(s) (One VM name per line)" -ForegroundColor Green
        Write-Host "===================================================================================================" -ForegroundColor Yellow
        Write-Host ""

        Get-UserInput   # Function

        Clear-Host
        $Manual_List = $Manual_List | Where-Object { $_ -ne "" }
        Write-Host ""
        Write-Host " You are now connected to the following vCenter servers:" -ForegroundColor green -NoNewline
        Write-Host "" -NoNewline
        $defaultviservers | Format-Table
        Write-Host " and " -NoNewline
        Write-Host "manually entered the following server names to work on:" -ForegroundColor Green
        Write-Host ""
        $Manual_List
        Set-Variable -Name VM_List_File -Value $Manual_List
        $Chosen_Servers = "Manual Entry list"
    }
}

Pause



<# Store VM list path and File name
 #==========================================================================#>

IF ($VM_List_File -like "*.txt") {
    $VM_List = Get-Content "$SCRIPT_ROOT\$VM_List_File" | Sort-Object
}
ELSE {
    $VM_List = $Manual_List | Sort-Object
}



<#==========================================================================
 #==========================================================================
 # 								Script Body
 #==========================================================================
 #=========================================================================#>

Clear-Host

if ($VM_List -ne $null) {
    $VM_Found = @()
    ForEach ($VM in $VM_List) {
        $Exist = Get-VM -Name $VM* -ErrorAction Stop
        if ($exist -ne $null) {
            Foreach ($vm in $Exist) {
                Write-Host "$VM" -NoNewline
                Write-Host " FOUND " -ForegroundColor green -NoNewline
                Write-Host "in vCnter Server: " -ForegroundColor Yellow -NoNewline
                Write-Host "$(([string]$Exist.Uid.Split(":")[0].Split("@")[1]).ToUpper())" -ForegroundColor Green
                $VM_Found += $Exist
            }
        }

        Else {
            Write-Host "$VM" -NoNewline -BackgroundColor black
            Write-Host " NOT FOUND " -ForegroundColor Red -BackgroundColor black
				    }
				}


    $VM = $null

    $VM_Found = $VM_Found | Sort-Object -Unique

    <#  Text used to populate change ticket.
        ################################################>

    Write-Host "`n`n$($StartDate.ToString("yyyy-MM-dd"))"
    Write-Host "============================================================================"
    Write-Host "Preliminary validation performed on $($StartDate.ToString("yyyy-MM-dd"))"
    Write-Host "Final validation DUE: 2021-06-00 @ 15:00 EDT  -  `n`n"
    Write-Host "N O T E :`n"
    foreach ($item in $VM_Found) {
        Write-Host "-  A snapshot of $item is approved as long as it is removed at the end of the change window."
    }



    <#  Collect and display VM data
        ################################################>

    ForEach ($VM in $VM_Found) {
        $VM_Instance = $vm
        $VM_IP = $VM_Instance.Guest.IPAddress | Where-Object { $_ -like "*.*.*.*" }
        # If($VM_IP -ne $NULL) {$VM_IP = $VM_IP} Else {$VM_IP = "IP Address N/A"}
        If ($VM_IP -eq $NULL) { $VM_IP = "IP Address N/A" }
        $VM_UUID = $VM_Instance.ExtensionData.Config.Uuid
        $VM_Snaps = $VM_Instance | Get-Snapshot | Sort-Object
        $vCenter = ([string]$VM_Instance.Uid.Split(":")[0].Split("@")[1]).ToUpper()
        $VM_DATASTORE = $VM_Instance.ExtensionData.Layout.Disk.diskfile.Split("[")[1].Split("]")[0]
        $VM_Disks = $VM_Instance | Get-Harddisk
        $VM_HDD_Total_Size = ($VM_Instance | Get-Harddisk | Measure-Object CapacityGB -Sum).sum
        $VM_DataStore_Space_Free = (Get-Datastore $VM_DATASTORE).FreeSpaceGB ; $VM_DataStore_Space_Free = "{0:N2}" -f $VM_DataStore_Space_Free
        $Post_Snapshot_Space_Available = $VM_DataStore_Space_Free - ($VM_HDD_Total_Size * 1.2)
        $Snap_Max_Size = $VM_HDD_Total_Size * 1.2 ; $Snap_Max_Size = "{0:N2}" -f $Snap_Max_Size
        if ($VM_Snaps -ne $null) { $Snaps_Present = "YES" } Else { $Snaps_Present = "NO" }

        Write-Host ""
        Write-Host ""
        Write-Host " $($VM_Instance.Name)" -ForegroundColor Green -NoNewline
        Write-Host "  ($VM_IP)"
        Write-Host "============================================================================"
        Write-Host " vCenter Name                   : $($vCenter)"
        Write-Host " VM Serial #/UUID               : $VM_UUID"
        Write-Host " VM Data Store(s)               : $VM_DATASTORE"
        Write-Host " VM Hard Drives present         : $($VM_Disks.count)"
        $HDD_STATS = @()
        ForEach ($HDD in $VM_Disks) {
            $HDD_Info = New-Object System.Object
            $HDD_Info | Add-Member -MemberType NoteProperty -Name 'Name'          -Value $HDD.Name
            $HDD_Info | Add-Member -MemberType NoteProperty -Name 'Size_GB'       -Value $HDD.CapacityGB
            $HDD_Info | Add-Member -MemberType NoteProperty -Name 'Type'          -Value $HDD.Persistence
            $HDD_Info | Add-Member -MemberType NoteProperty -Name 'Format'        -Value $HDD.StorageFormat
            $HDD_Info | Add-Member -MemberType NoteProperty -Name 'DataStore'     -Value $HDD.filename.Split("[")[1].Split("]")[0]
            $HDD_Info | Add-Member -MemberType NoteProperty -Name 'DS_Space_Free' -Value ([math]::round((Get-Datastore -Name ($HDD_Info.DataStore))[0].FreeSpaceGB, 2))
            1181.67
            $HDD_STATS += $HDD_Info
        }
        Write-Host "-----------------------------------------------------------------------------------------------------------------" -ForegroundColor green
        Write-Host " Name`t`tSize`tPresistence`tSpace Free`tFormat`t`tDataStore" -ForegroundColor green
        Write-Host "-----------------------------------------------------------------------------------------------------------------" -ForegroundColor green

        foreach ($h in $hdd_stats) {
            $VM_DS_FREE = (Get-Datastore $h.DataStore).FreeSpaceGB ; $VM_DS_FREE = "{0:N2}" -f $VM_DS_FREE
            if ($h.format -like "*Eager*") { $DS_Format = "E0 Thick" }
            Else { $DS_Format = $h.format }
            Write-Output " $($h.name)`t$($h.size_GB) GB`t$($h.type)`t$($h.DS_Space_Free) GB`t$($DS_Format)`t`t$($h.DataStore)"
        }
        Write-Host ""
        Write-Host " VM TOTAL allocated SPACE       : $VM_HDD_Total_Size GB"
        Write-Host " Space required for snapshot    : $($VM_HDD_Total_Size * 1.2) GB  (TOTAL allocated SPACE + 20%)"
        Write-Host " Space remaining after snapshot : $Post_Snapshot_Space_Available GB"
        Write-Host " VM Snapshots present           : $Snaps_Present"

        <#  Collect and display VM snapshot data if present
        ####################################################>

        if ($VM_Snaps -ne $null) {
            $i = 1
            Foreach ($snap in $VM_Snaps) {
                $sizeGB = $VM_Snaps.SizeGB; $sizeGB = "{0:N2}" -f $sizeGB
                Write-Host "      Snapshot $i" -ForegroundColor yellow
                Write-Host "      ========================" -ForegroundColor yellow
                Write-Host "      Snapshot Name         : $($VM_Snaps.name)"
                Write-Host "      Snapshot Created      : $($VM_Snaps.created)"
                Write-Host "      Snapshot Description  : $($VM_Snaps.description)"
                Write-Host "      Snapshot Size (in GB) : $sizeGB"
                #$sizeMB = ($snapshot.SizeMB)/1024; $sizeMB = "{0:N2}" -f $sizeMB; $sizeMB = "$sizeMB MB"
                $i ++
            }

            Write-Host ""
            Write-Host ""
        }
    }
}

Else {
    Write-Host "There are no VMs present in the " -ForegroundColor Red -NoNewline -BackgroundColor Black
    Write-Host "$Chosen_Servers" -ForegroundColor Yellow -NoNewline -BackgroundColor Black
    Write-Host ""
}


<#  Disconnect from ALL connected vCenter servers
 #=========================================================================#>
#   Disconnect-VIServer * -force -Confirm:$false

<#if ($defaultviserver -ne $null)
			    {
			    Write-Host ""
			    Write-Host ""
			    Write-Host "The following VIServers did not disconnect propperly:"
                $defaultviservers
			    }#>


<#  Dysplay script conpletion message
 #  Dysplay script Start time
 #  Dysplay script conpletion time
 #  Dysplay total script run time
 #  Restore original working directory
 #========================================================================#>

Write-Host ""
Write-Host ""
Write-Host ""
$EndDate = (Get-Date)
$TS = New-TimeSpan –Start $StartDate –End $EndDate
Write-Host "DING! DING! DING!, no more calls we have a winner" -ForegroundColor Green
Write-Host "SCRIPT START DATE: $StartDate"
Write-Host "SCRIPT END DATE: $EndDate"
Write-Host "Total script run time in Days:Hours:Minutes:Seconds: " -NoNewline
Write-Host "$($ts.Days):$($ts.Hours):$($ts.Minutes):$($ts.Seconds)"-ForegroundColor Green
Write-Host ""
Write-Host ""
Push-Location $default_Location


<#  Pause the script to keep the PowerShell window open.
 #  The script will only exit if the 'ESC' (Escape) key is pressed.
 #  This is usefull when launching the script from a batch file.
 #========================================================================#>

If ($psISE) {
    # The "ReadKey" functionality is not supported in the Windows PowerShell ISE.
    Write-Host "Press the " -BackgroundColor Black -ForegroundColor Green -NoNewline
    Write-Host "'ESC' " -BackgroundColor Black -ForegroundColor yellow -NoNewline
    Write-Host "key to exit ..." -BackgroundColor Black -ForegroundColor Green
}

Else {
    Write-Host "Press the " -BackgroundColor Black -ForegroundColor Green -NoNewline
    Write-Host "'ESC' " -BackgroundColor Black -ForegroundColor yellow -NoNewline
    Write-Host "key to exit ..." -BackgroundColor Black -ForegroundColor Green

    $HOST.UI.RawUI.Flushinputbuffer()
    $keyinfo = $null

    While ($KeyInfo.VirtualKeyCode -ne "27") {
        $KeyInfo = $Host.UI.RawUI.ReadKey("NoEcho, IncludeKeyDown")
    }
}