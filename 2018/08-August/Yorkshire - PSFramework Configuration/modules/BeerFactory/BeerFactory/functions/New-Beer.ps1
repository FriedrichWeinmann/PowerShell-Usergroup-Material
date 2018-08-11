function New-Beer
{
<#
	.SYNOPSIS
		Creates a new beer and adds it to the fridge.
	
	.DESCRIPTION
		Creates a new beer and adds it to the fridge.
	
	.PARAMETER Brand
		The brand of the beer to create.
	
	.PARAMETER Type
		The type of beer to add.
		Bei default, a Weizenbier will be created.
	
	.PARAMETER Container
		What size is the beer?
		By default, an entire barrel of beer will be created.
	
	.PARAMETER PassThru
		Pass through the beer object created.
	
	.EXAMPLE
		PS C:\> New-Beer -Brand 'Hofbräu'
	
		Creates a barrel of Hofbräu Weizenbier.
	
	.EXAMPLE
		PS C:\> Get-Content beer.txt | New-Beer -Type Pils -Container Horn
	
		Creates a horn of Pils for each brand stored in beer.txt.
#>
	[CmdletBinding()]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true)]
		[string[]]
		$Brand,
		
		[BeerFactory.BeerType]
		$Type = "Weizenbier",
		
		[BeerFactory.Container]
		$Container = "Barrel",
		
		[switch]
		$PassThru
	)
	
	begin
	{
		if ((Get-PSFConfigValue -FullName BeerFactory.Fridge.Size -Fallback 10) -le $script:beerList.Count)
		{
			Write-Error -Exception (New-Object BeerFactory.BeerGettingWarmException(("Can't store anymore beer, the fridge is full! Current limit: {0}"-f (Get-PSFConfigValue -FullName BeerFactory.Fridge.Size -Fallback 10)))) -ErrorAction Stop
		}
	}
	process
	{
		foreach ($item in $Brand)
		{
			$beer = New-Object BeerFactory.Beer($item, $Type, $Container)
			$null = $script:beerList.Add($beer)
			if ($PassThru) { $beer }
		}
	}
	end
	{
	
	}
}
