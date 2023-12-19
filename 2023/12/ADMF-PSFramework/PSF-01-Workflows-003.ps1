# failsafe
return

#-> Variables
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Variables'

$variables = @{
    Multiplier = 3
}
$workflow | Add-PSFRunspaceWorker -Name Multiply -InQueue Numbers -OutQueue Results -Count 5 -ScriptBlock {
    param ($Value)
    Start-Sleep -Milliseconds 200
    [PSCustomObject]@{
        Input = $Value
        Multiplier = $Multiplier
        Result = $Value * $Multiplier
    }
} -Variables $variables -CloseOutQueue

$workflow | Write-PSFRunspaceQueue -Name Numbers -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName Multiply -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Results -All
$workflow | Remove-PSFRunspaceWorkflow

$results

#-> Functions
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Functions'

function Get-RandomNumber {
	[CmdletBinding()]
	param()
	Get-Random -Minimum 10 -Maximum 99
}
$functions = @{
	'Get-RandomNumber' = (Get-Command Get-RandomNumber).Definition
}

$workflow | Add-PSFRunspaceWorker -Name Multiply -InQueue Numbers -OutQueue Results -Count 5 -ScriptBlock {
    param ($Value)
    Start-Sleep -Milliseconds 200
    [PSCustomObject]@{
        Input = $Value
        Random = Get-RandomNumber
    }
} -Functions $functions -CloseOutQueue

$workflow | Write-PSFRunspaceQueue -Name Numbers -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName Multiply -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Results -All
$workflow | Remove-PSFRunspaceWorkflow

$results

#-> Modules
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-Modules'

$workflow | Add-PSFRunspaceWorker -Name Multiply -InQueue Numbers -OutQueue Results -Count 5 -ScriptBlock {
    param ($Value)
    Start-Sleep -Milliseconds 200
    [PSCustomObject]@{
        Input = $Value
        Random = Get-RandomNumber
    }
} -Modules C:\scripts\modules\MyModule\MyModule.psd1 -CloseOutQueue

$workflow | Write-PSFRunspaceQueue -Name Numbers -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName Multiply -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Results -All
$workflow | Remove-PSFRunspaceWorkflow

$results

#-> Initial Sessionstate geht auch

#-> Variablen v2: Unterschiedliche Variablen pro Worker Instanz
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-PerRunspaceVars'

$variables = @{
    ID = 1,2,3,4,5
}
$workflow | Add-PSFRunspaceWorker -Name Multiply -InQueue Numbers -OutQueue Results -Count 5 -ScriptBlock {
    param ($Value)
    Start-Sleep -Milliseconds 200
    [PSCustomObject]@{
        Input = $Value
        Index = $ID
        Result = $Value * $ID
    }
} -VarPerRunspace $variables -CloseOutQueue

$workflow | Write-PSFRunspaceQueue -Name Numbers -BulkValues (1..20) -Close
$workflow | Start-PSFRunspaceWorkflow -PassThru | Wait-PSFRunspaceWorkflow -WorkerName Multiply -Closed -PassThru | Stop-PSFRunspaceWorkflow
$results = $workflow | Read-PSFRunspaceQueue -Name Results -All
$workflow | Remove-PSFRunspaceWorkflow

$results


# Moving on: Ending things gracefully
code "$presentationRoot\PSF-01-Workflows-004.ps1"