<#
An example on how to make some small operators pipeline capable, saving time by not having to restructure lines of code in the console on the fly.
Just make it paert of the pipeline.
#>

function Trim-String
{
	<#
		.SYNOPSIS
			Trims strings, can be used in a pipeline.
		
		.DESCRIPTION
			Trims strings, can be used in a pipeline.
		
		.PARAMETER InputObject
			The strings to trim.
		
		.PARAMETER Start
			Only the start of the string will be trimmed.
			Setting both Start and End will cause both parameters to be ignored.
		
		.PARAMETER End
			Only the end of the string will be trimmed.
			Setting both Start and End will cause both parameters to be ignored.
		
		.PARAMETER Characters
			Default: " "
			The characters that are trimmed.
		
		.EXAMPLE
			PS C:\> Get-Content "computers.txt" | Trim-String
	
			Reads all lines from the file computers.txt, then for each of those trims away whitespaces.
		
		.NOTES
			Supported Interfaces:
			------------------------
			
			Author:       Friedrich Weinmann
			Company:      die netzwerker Computernetze GmbH
			Created:      10.05.2016
			LastChanged:  10.05.2016
			Version:      1.0
		
		.LINK
			Link to Website.
	#>
    [CmdletBinding()]
    Param (
        [Parameter(ValueFromPipeline = $true)]
        [string[]]
        $InputObject,
        
        [switch]
        $Start,
        
        [switch]
        $End,
        
        [Parameter(Position = 0)]
        [char[]]
        $Characters = " "
    )
    
    Begin
    {
        # Decide modes
        [int]$Mode = 0
        if ($Start -and (-not $End)) { [int]$Mode = 1 }
        if ((-not $Start) -and $End) { [int]$Mode = 2 }
    }
    Process
    {
        #region Process strings
        foreach ($s in $InputObject)
        {
            switch ($Mode)
            {
                0 { $s.Trim($Characters) }
                1 { $s.TrimStart($Characters) }
                2 { $s.TrimEnd($Characters) }
            }
        }
        #endregion Process strings
    }
    End
    {
        
    }
    
}
New-Alias -Name "trim" -Value Trim-String