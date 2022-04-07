[CmdletBinding()]
param (
	[string]
	$UsersPath
)

if (-not (Get-AzContext)) {
	throw "Connect with azure first! Connect-AzAccount ftw"
}

$users = Get-AzADUser
$userConfig = Import-Csv $UsersPath

$param = @{
	'Country2'       = 'USA'
	'CompanyName' = 'Contoso'
	"Foo"         = 42
}

dir @param

# Dummy code to simulate different hashtable assignments
$property = 'EmployeeHireDate'
$properties = @{ Name = 'MailNickname' }

foreach ($entry in $userConfig) {
	if ($entry.UPN -notin $users.UserPrincipalName) { continue }
	$param.EmployeeID2 = $entry.ID
	$param['EmployeeID2'] = $entry.ID
	$param.$property = $entry.JoinedAt
	$param[$property] = $entry.JoinedAt
	$param["$property"] = $entry.JoinedAt
	$param.Add('MailNickname2', $entry.MailNickname)
	$param.Add($properties.Name, $entry.MailNickname)
	$param.$($properties.Name) = $entry.MailNickname
	$param[$($properties.Name)] = $entry.MailNickname

	Set-AzADUser -UPNOrObjectId $entry.UPN @param
}

return

# Some dummy code for this test
Get-AzureADApplication | Set-MgADApplication -IsDisabled $false -Public $false