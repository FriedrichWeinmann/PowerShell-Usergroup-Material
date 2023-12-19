# failsafe
return

$workflow = New-PSFRunspaceWorkflow -Name 'ExampleWorkflow-FirstStepData'

# First Worker: Get Mailboxes
$variables = @{
	exAppID        = $exAppID
	exOrganization = $exOrganization
	exCert         = $exCert
}
$begin = {
	Connect-ExchangeOnline -AppId $exAppID -Organization $exOrganization -Certificate $exCert
}
$process = {
	# This is currently ugly, I know, but there'll be an update to fix that
	Get-EXOMailbox | Write-PSFRunspaceQueue -Name Mailboxes -WorkerName '' -InputObject $null
}
$end = {
	Disconnect-ExchangeOnline
}
$workflow | Add-PSFRunspaceWorker -Name Mailboxes -InQueue Input -OutQueue Mailboxes -Begin $begin -ScriptBlock $process -End $end -Count 1 -Variables $variables -Modules ExchangeOnlineManagement -KillToStop -CloseOutQueue

# Second Worker: Match Information from Active Directory
$process2 = {
	param ($Value)
	$adUser = Get-ADUser -LDAPFilter "(mail=$($Value.PrimarySmtpAddress))"

	[PSCustomObject]@{
		SamAccountName    = $adUser.SamAccountName
		SID               = $adUser.ObjectSID
		DistinguishedName = $adUser.DistinguishedName
		Mail              = $Value.PrimarySmtpAddress
		ProxyAddresses    = $value.ProxyAddresses -join ','
	}
}
$workflow | Add-PSFRunspaceWorker -Name ADUser -InQueue Mailboxes -OutQueue ADUser -ScriptBlock $process2 -Count 10 -Modules ActiveDirectory -CloseOutQueue

# Third Worker: Write Results to CSV
$variables3 = @{ Path = 'C:\temp\users.csv' }
$begin3 = {
	$global:command = { Export-Csv -Path $Path }.GetSteppablePipeline()
	$global:command.Begin($true)
}
$process3 = {
	$global:command.Process($_)
}
$end3 = {
	$global:command.End()
}
$workflow | Add-PSFRunspaceWorker -Name CSV -InQueue ADUser -OutQueue Nothing -Begin $begin3 -ScriptBlock $process3 -End $end3 -Count 1 -Variables $variables3 -CloseOutQueue

# Add one piece of input because we need to run Mailbox exactly once
$workflow | Write-PSFRunspaceQueue -Name Input -Value 1 -Close

$workflow | Start-PSFRunspaceWorkflow
$workflow | Wait-PSFRunspaceWorkflow -WorkerName CSV -Closed -PassThru | Remove-PSFRunspaceWorkflow

# Back to central
code "$presentationRoot\psframework.ps1"