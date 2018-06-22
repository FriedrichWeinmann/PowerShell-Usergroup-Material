function Set-Beer
{
<#
	.SYNOPSIS
		Changes beers stored in the fridge.
	
	.DESCRIPTION
		Changes beers stored in the fridge.
	
	.PARAMETER Beer
		A beer object to pass on.
	
	.PARAMETER Brand
		The brand of the beer to change. Supports wildcards.
	
	.PARAMETER Type
		What kinds of beer to change
	
	.PARAMETER Container
		What size of container to change
	
	.PARAMETER NewBrand
		A description of the NewBrand parameter.
	
	.PARAMETER NewType
		The new brand to assign.
		Faking beer should be punishable by death!
	
	.PARAMETER NewContainer
		Refill the beer into another container.
		If you can fill a barrel with a glass, get me in contact with your glasses vendor.
	
	.PARAMETER PassThru
		Return the updated beers.
	
	.EXAMPLE
		PS C:\> Get-Beer Hofbräu | Set-Beer -NewBrand Becks
	
		Turns all stored Hofbräu in your fridge into Becks beer.
		Don't tell your friends before serving.
#>
	[CmdletBinding()]
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
		$Container,
		
		[string]
		$NewBrand,
		
		[BeerFactory.BeerType]
		$NewType,
		
		[BeerFactory.Container]
		$NewContainer,
		
		[switch]
		$PassThru
	)
	
	begin
	{
		if (Test-PSFParameterBinding -ParameterName NewType, NewContainer, NewBrand -Not)
		{
			Write-Error -Message "No changing parameter was specified. Specify at least one of the following parameters: NewBrand, NewType, NewContainer" -ErrorAction Stop
		}
	}
	process
	{
		foreach ($item in $Beer)
		{
			if ($NewBrand) { $item.Brand = $NewBrand }
			if (Test-PSFParameterBinding -ParameterName NewType) { $item.Type = $NewType }
			if (Test-PSFParameterBinding -ParameterName NewContainer) { $item.Size = $NewContainer }
			if ($PassThru) { $item }
		}
		
		if ($Brand)
		{
			$paramsGetBeer = @{
				Brand   = $Brand
			}
			if (Test-PSFParameterBinding -ParameterName Type) { $paramsGetBeer["Type"] = $Type }
			if (Test-PSFParameterBinding -ParameterName Container) { $paramsGetBeer["Container"] = $Container }
			
			$paramsSetBeer = @{ }
			if (Test-PSFParameterBinding -ParameterName NewBrand) { $paramsRemoveBeer["NewBrand"] = $NewBrand }
			if (Test-PSFParameterBinding -ParameterName NewType) { $paramsRemoveBeer["NewType"] = $NewType }
			if (Test-PSFParameterBinding -ParameterName NewContainer) { $paramsRemoveBeer["NewContainer"] = $NewContainer }
			
			Get-Beer @paramsGetBeer | Set-Beer @paramsSetBeer
		}
	}
	end
	{
	
	}
}
