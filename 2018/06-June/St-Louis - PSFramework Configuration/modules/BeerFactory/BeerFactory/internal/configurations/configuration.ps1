$paramSetPSFConfig = @{
	Module	     = 'BeerFactory'
	Name		 = 'Fridge.Size'
	Value	     = 10
	Initialize   = $true
	Validation   = 'integer'
	Description  = "The maximum capacity of the fridge"
}

Set-PSFConfig @paramSetPSFConfig