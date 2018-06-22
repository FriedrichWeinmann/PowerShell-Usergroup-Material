function Remove-Beer
{
<#
	.SYNOPSIS
		Removes beers stored in the fridge.
	
	.DESCRIPTION
		Removes beers stored in the fridge.
	
	.PARAMETER Beer
		A beer object to drink.
	
	.PARAMETER Brand
		The brand of the beer to drink. Supports wildcards.
	
	.PARAMETER Type
		What kinds of beer to drink
	
	.PARAMETER Container
		What size of container to consume
	
	.PARAMETER WhatIf
		Only pretend drinking the beer.
	
	.PARAMETER Confirm
		Get permission (or ignore permissions) before drinking beer.
	
	.EXAMPLE
		PS C:\> Get-Beer -Brand Hofbräu | Remove-Beer
	
		Returns all Hofbräu beers and drinks them.
#>
	[CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "Object", ConfirmImpact = 'High')]
	Param (
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Object")]
		[BeerFactory.Beer[]]
		$Beer,
		
		[Parameter(Mandatory = $true, ValueFromPipeline = $true, ParameterSetName = "Name")]
		[string[]]
		$Brand,
		
		[BeerFactory.BeerType[]]
		$Type,
		
		[BeerFactory.Container[]]
		$Container
	)
	
	begin
	{
		
	}
	process
	{
		foreach ($item in $Beer)
		{
			if ($PSCmdlet.ShouldProcess($item.Brand, ("Drinking a {0} of {1}" -f $item.Size, $item.Type)))
			{
				$null = $script:beerList.Remove($item)
			}
		}
		
		if ($Brand)
		{
			$paramsGetBeer = @{
				Brand  = $Brand
			}
			if (Test-PSFParameterBinding -ParameterName Type) { $paramsGetBeer["Type"] = $Type }
			if (Test-PSFParameterBinding -ParameterName Container) { $paramsGetBeer["Container"] = $Container }
			
			$paramsRemoveBeer = @{ }
			if (Test-PSFParameterBinding -ParameterName WhatIf) { $paramsRemoveBeer["WhatIf"] = $true }
			if (Test-PSFParameterBinding -ParameterName Confirm) { $paramsRemoveBeer["Confirm"] = $true }
			
			Get-Beer @paramsGetBeer | Remove-Beer @paramsRemoveBeer
		}
	}
	end
	{
	
	}
}
New-Alias -Name Drink-Beer -Value Remove-Beer