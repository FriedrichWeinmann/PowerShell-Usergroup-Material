# failsafe
return

#-> Basic Throttling
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Throttling'

$throttle = New-PSFThrottle -Interval '3s' -Limit 5
$workflow | Add-PSFRunspaceWorker -Name S1 -InQueue Q1 -OutQueue Q2 -Count 10 -ScriptBlock {
    param ($Value)
    Start-Sleep -Milliseconds 200
    [PSCustomObject]@{
        Value = $Value
        Stage1 = Get-Date
        Stage2 = $null
    }
} -CloseOutQueue
$workflow | Add-PSFRunspaceWorker -Name S2 -InQueue Q2 -OutQueue Q3 -Count 10 -ScriptBlock {
    param ($Value)
    $Value.Stage2 = Get-Date
    $Value
} -CloseOutQueue -Throttle $throttle

$workflow | Write-PSFRunspaceQueue -Name Q1 -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName S2 -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Q3 -All
$workflow | Remove-PSFRunspaceWorkflow

$results

#-> Wait until
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Throttling2'

$throttle = New-PSFThrottle -Interval '1m' -Limit 100
$workflow | Add-PSFRunspaceWorker -Name S1 -InQueue Q1 -OutQueue Q2 -Count 1 -ScriptBlock {
    param ($Value)
    Start-Sleep -Milliseconds 200
    [PSCustomObject]@{
        Value = $Value
        Stage1 = Get-Date
        Stage2 = $null
    }
} -CloseOutQueue
$workflow | Add-PSFRunspaceWorker -Name S2 -InQueue Q2 -OutQueue Q3 -Count 2 -ScriptBlock {
    param ($Value)
    if (10 -eq $Value.Value) {
        $__PSF_Worker.Throttle.NotBefore = (Get-Date).AddSeconds(10)
    }
    $Value.Stage2 = Get-Date
    $Value
} -CloseOutQueue -Throttle $throttle

$workflow | Write-PSFRunspaceQueue -Name Q1 -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName S2 -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Q3 -All
$workflow | Remove-PSFRunspaceWorkflow

$results

#-> Queue Limits
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Throttling3'

# Limit Q2 to no more than 5 items
$workflow.Queues.Q2.MaxItemCount = 5

$workflow | Add-PSFRunspaceWorker -Name S1 -InQueue Q1 -OutQueue Q2 -Count 1 -ScriptBlock {
    param ($Value)
    [PSCustomObject]@{
        Value = $Value
        Stage1 = Get-Date
        Stage2 = $null
    }
} -CloseOutQueue
$workflow | Add-PSFRunspaceWorker -Name S2 -InQueue Q2 -OutQueue Q3 -Count 2 -ScriptBlock {
    param ($Value)
    Start-Sleep -Second 1
    $Value.Stage2 = Get-Date
    $Value
} -CloseOutQueue

$workflow | Write-PSFRunspaceQueue -Name Q1 -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName S2 -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Q3 -All
$workflow | Remove-PSFRunspaceWorkflow

$results

# Moving on: No Input
code "$presentationRoot\PSF-01-Workflows-006.ps1"