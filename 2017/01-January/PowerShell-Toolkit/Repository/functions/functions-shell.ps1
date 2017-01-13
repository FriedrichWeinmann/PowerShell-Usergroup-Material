#region xyz
function Write-DebugEx
{
	[CmdletBinding()]
	Param (
		[string]
		$FunctionName = ((Get-PSCallStack)[0].Command),
		
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Message,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[int]
		$Level,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[string]
		$Tag
	)
	
	Write-Debug "[$FunctionName][$Level][$Tag] $Message"
}

function Write-Status
{
	[CmdletBinding()]
	Param (
		[string]
		$Message,
		
		[bool]
		$Silent,
		
		[Demo.Shell.StatusType]
		$Type = "Info"
	)
	
	if (-not $Silent)
	{
		$splat = @{
			Object = $Message
		}
		
		switch ($Type.ToString())
		{
			"Info" { }
			"Success" { $splat["ForeGroundColor"] = "Green" }
			"Warning" { $splat["ForeGroundColor"] = "Yellow" }
			"Failure" { $splat["ForeGroundColor"] = "Red" }
		}
		Write-Host @splat
	}
}

function Stop-Function
{
	[CmdletBinding()]
	Param (
		[string]
		$FunctionName = ((Get-PSCallStack)[0].Command),
		
		[Parameter(Mandatory = $true, Position = 1)]
		[string]
		$Message,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[int]
		$Level,
		
		[Parameter(Mandatory = $true, Position = 3)]
		[bool]
		$Silent,
		
		[Parameter(Mandatory = $false, Position = 4)]
		[System.Exception]
		$InnerException,
		
		[switch]
		$Continue,
		
		[switch]
		$SilentContinue
	)
	
	# Manage Debugging
	Write-DebugEx -FunctionName $FunctionName -Message $Message -Level $Level -Tag "Terminate"
	
	#region Silent Mode
	if ($Silent)
	{
		if ($SilentContinue) { continue }
		
		throw (New-Object System.Exception($Message, $InnerException))
	}
	#endregion Silent Mode
	
	#region Non-Silent Mode
	else
	{
		Write-Status -Message $Message -Silent $false -Type Failure
		if ($Continue) { Continue }
		else
		{
			return
		}
	}
	#endregion Non-Silent Mode
}
#endregion xyz

function Test-Error
{
	$silent = $false
	$int = 5
	$i = 0
	while ($i -lt $int)
	{
		$i++
		
		try
		{
			if ($i -eq 3) { throw "error 3" }
			
		}
		catch
		{
			Stop-Function -Message "haha" -Level 7 -Silent $Silent -InnerException $_.Exception -Continue
			return
		}
		Write-Status -Message $i
	}
}