function Get-Beer
{
<#
	.SYNOPSIS
		Lists all beers stored in the fridge.
	
	.DESCRIPTION
		Lists all beers stored in the fridge.
	
	.PARAMETER Beer
		A beer object to pass on.
	
	.PARAMETER Brand
		The brand of the beer to search. Supports wildcards.
	
	.PARAMETER Type
		What kinds of beer to return
	
	.PARAMETER Container
		What size of container to return
	
	.EXAMPLE
		PS C:\> Get-Beer
	
		Returns all beers stored
#>
	[CmdletBinding(DefaultParameterSetName = 'Name')]
	Param (
		[Parameter(ValueFromPipeline = $true, ParameterSetName = "Object")]
		[BeerFactory.Beer[]]
		$Beer,
		
		[Parameter(ValueFromPipeline = $true, ParameterSetName = "Name")]
		[string[]]
		$Brand = "*",
		
		[BeerFactory.BeerType[]]
		$Type,
		
		[BeerFactory.Container[]]
		$Container
	)
	
	begin
	{
		if ($beerList.Count -le 0)
		{
			Write-Error -Exception (New-Object BeerFactory.OutOfBeerException("All beer has been drunk!!!"))
		}
	}
	process
	{
		foreach ($item in $Beer)
		{
			$item
		}
		
		if ($Beer) { return }
		
		foreach ($beerItem in $beerList.ToArray())
		{
			$foundName = $false
			foreach ($name in $Brand)
			{
				if ($beerItem.Brand -like $name)
				{
					$foundName = $true
				}
			}
			if (-not $foundName) { continue }
			
			if (Test-PSFParameterBinding -ParameterName Type)
			{
				if ($Type -notcontains $beerItem.Type) { continue }
			}
			
			if (Test-PSFParameterBinding -ParameterName Container)
			{
				if ($Container -notcontains $beerItem.Size) { continue }
			}
			
			$beerItem
		}
	}
	end
	{
	
	}
}
