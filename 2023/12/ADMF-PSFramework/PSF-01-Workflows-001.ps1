# failsafe
return

# Create Workflow
$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow'
$workflow

# Add Workers
$workflow | Add-PSFRunspaceWorker -Name Processing -InQueue Input -OutQueue Processed -Count 3 -ScriptBlock {
	Start-Sleep -Milliseconds 25
    [PSCustomObject]@{
        Input = $_
        Processed = $_ * 2
        Result = $null
    }
}
$workflow | Add-PSFRunspaceWorker -Name Result -InQueue Processed -OutQueue Done -Count 2 -ScriptBlock {
    $_.Result = $_.Processed * 3
    $_
}

# Add input
$workflow | Write-PSFRunspaceQueue -Name Input -BulkValues (1..1000)

# Start Workflow
$workflow | Start-PSFRunspaceWorkflow
$workflow

# Wait for Workflow to complete and stop it
$workflow | Wait-PSFRunspaceWorkflow -Queue Done -Count 1000 -PassThru | Stop-PSFRunspaceWorkflow

# Retrieve results
$results = $workflow | Read-PSFRunspaceQueue -Name Done -All
$results.Count
$results[10,11]

# Final Cleanup
$workflow | Remove-PSFRunspaceWorkflow


# Moving on: Begin & End
code "$presentationRoot\PSF-01-Workflows-002.ps1"