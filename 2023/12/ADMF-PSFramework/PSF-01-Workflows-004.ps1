# failsafe
return

#-> Signalling the end
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Closing'

$workflow | Add-PSFRunspaceWorker -Name Processing -InQueue Input -OutQueue Processed -Count 3 -ScriptBlock {
    param ($Value)

    [PSCustomObject]@{
        Input = $Value
        Processed = $Value * 2
        Result = $null
    }
} -CloseOutQueue
$workflow | Add-PSFRunspaceWorker -Name Result -InQueue Processed -OutQueue Done -Count 2 -ScriptBlock {
    param ($Value)

    $Value.Result = $Value.Processed * 3
    $Value
} -CloseOutQueue

$workflow | Write-PSFRunspaceQueue -Name Input -BulkValues (1..1000) -Close
$workflow | Start-PSFRunspaceWorkflow

$workflow | Wait-PSFRunspaceWorkflow -WorkerName Result -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Done -All
$workflow | Remove-PSFRunspaceWorkflow

# Moving on: Now don't be too hasty!
code "$presentationRoot\PSF-01-Workflows-005.ps1"