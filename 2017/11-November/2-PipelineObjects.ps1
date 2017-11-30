function Show-Pipeline
{
<#
	.SYNOPSIS
		Demo function that shows how the pipeline processes objects.
	
	.DESCRIPTION
		Demo function that shows how the pipeline processes objects.
	
	.PARAMETER InputObject
		The object to pass through.
	
	.PARAMETER Name
		Name of the execution. Used when reporting the workflow to screen.
	
	.PARAMETER Stagger
		Stagger all input objects to be passed along when the next input is received.
	
	.PARAMETER Fail
		When to throw an exception.
	
	.PARAMETER Wait
		How many seconds to wait when processing an item.
	
	.EXAMPLE
		PS C:\> Show-Pipeline
#>
	[CmdletBinding()]
	Param (
		[Parameter(ValueFromPipeline = $true)]
		$InputObject,
		
		[string]
		$Name,
		
		[switch]
		$Stagger,
		
		[ValidateSet('Begin','Process','End')]
		[string]
		$Fail,
		
		[int]
		$Wait
	)
	
	begin
	{
		Write-PSFMessage -Level Host -Message "[<c='green'>Begin</c>][$Name] Killing puppies and processing $InputObject"
		if ($Fail -eq "Begin") { throw "[Begin][$Name] Failing as planned!" }
		$cache = $null
	}
	
	process
	{
		foreach ($item in $InputObject)
		{
            $waiting = ""
            if ($Wait) { $waiting = " waiting for $wait seconds" }
			Write-PSFMessage -Level Host -Message "[<c='yellow'>Process</c>][$Name] Killing puppies and processing $item$($waiting)"
			if ($Fail -eq "Process") { throw "[Process][$Name] Failing as planned!" }
			if ($Wait -gt 0) { Start-Sleep -Seconds $Wait }
			
			if ($Stagger)
			{
				if ($cache) { $cache }
				$cache = $item
			}
			else { $item }
		}
	}
	
	end
	{
		Write-PSFMessage -Level Host -Message "[<c='red'>End</c>][$Name] Killing puppies and processing $InputObject"
		if ($Fail -eq "End") { throw "[End][$Name] Failing as planned!" }
		if ($Stagger) { $cache }
	}
}

$in = "a","b","c"
$in | Show-Pipeline -Name "first" | Show-Pipeline -Name "second" | Show-Pipeline -Name "third"
$in | Show-Pipeline -Name "first" | Show-Pipeline -Name "second" -Wait 3 | Show-Pipeline -Name "third"
$in | Show-Pipeline -Name "first" | Show-Pipeline -Name "second" -Wait 1 -Stagger | Show-Pipeline -Name "third"

$in | Show-Pipeline -Name "first" | Show-Pipeline -Name "second" -Fail "Begin" | Show-Pipeline -Name "third"
$in | Show-Pipeline -Name "first" | Show-Pipeline -Name "second" -Fail "Process" | Show-Pipeline -Name "third"
$in | Show-Pipeline -Name "first" | Show-Pipeline -Name "second" -Fail "End" | Show-Pipeline -Name "third"