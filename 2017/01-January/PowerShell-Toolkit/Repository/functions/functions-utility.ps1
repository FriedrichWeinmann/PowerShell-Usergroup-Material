#region Coffee Related functions
function Get-Coffee
{
	<#
		.SYNOPSIS
			Sends a request for coffee.
		
		.DESCRIPTION
			Utilizes the vast powers of SMTP to magically summon you a cup of coffee, utilizing one of your minions.
		
		.PARAMETER Trainee
			Default: (Get-ConfigValue "Default.CoffeeFetcher" -FallBack ([Demo.Utility.Trainee]::GetRandom()))
			The minion (aka "Trainee" / "Azubi") to do your bidding.
		
		.PARAMETER Sugar
			Default: (Get-ConfigValue "Default.CoffeeSugar" -FallBack 0)
			The amount of sugar-cubes desired.
		
		.PARAMETER Milk
			Default: (Get-ConfigValue "Default.CoffeeMilk" -FallBack 0)
			The amount of milk your heathen soul desires.
		
		.PARAMETER Silent
			This switch replaces the soft, userfriendly yellow warnings with the cold red of unreadable errors.
		
		.EXAMPLE
			PS C:\> Get-Coffee
	
			Orders your favorite (or at least most subjugated) minion to fetch you your favorite kind of coffee.
	
		.EXAMPLE
			PS C:\> Get-Coffee "Maxxie" 2 25%
	
			Orders Maxxie to fetch you a coffee with 2 cubes of sugar and 25% Milk content.
		
		.NOTES
			Author:     Friedrich Weinmann
			Company:    Infernal Associates ltd.
			Created On: 12.01.2017
			Changed On: 12.01.2017
			Version:    1.0
			
			Version History
			1.0 (12.01.2017)
			- Initial release
	#>
	[CmdletBinding()]
	Param (
		[Parameter(Position = 0)]
		[Alias('Minion')]
		[Demo.Utility.Trainee]
		$Trainee = (Get-ConfigValue "Default.CoffeeFetcher" -FallBack ([Demo.Utility.Trainee]::GetRandom())),
		
		[Parameter(Position = 1)]
		[int]
		$Sugar = (Get-ConfigValue "Default.CoffeeSugar" -FallBack 0),
		
		[Parameter(Position = 2)]
		[Demo.Shell.Parameters.MilkParameter]
		$Milk = (Get-ConfigValue "Default.CoffeeMilk" -FallBack 0),
		
		[switch]
		$Silent
	)
	
	# Report Start
	Write-DebugEx -Message "Ordering Coffee" -Level 9 -Tag "Start"
	
	if ($Sugar -eq 0) { $sugar_text = "ohne Zucker" }
	else { $sugar_text = "mit $Sugar Stück Zucker" }
	
	if ($Milk.Value -eq 0) { $milk_text = "ohne Milch" }
	else { $milk_text = "mit $Milk Milch" }
	
	$body = @"
<html>
<head />
<body>
  <p>Hallo $($Trainee.Givenname),</p>

  <p>wärst Du so nett mir einen Kaffee $milk_text und $sugar_text vorbeizubringen?</p>

  <p>Vielen Dank Dir,<br />
  $(Get-ConfigValue "Shell.User")</p>
</body>
"@
	
	$splat = @{
		From = (Get-ConfigValue "Shell.UserMail")
		To = $Trainee.Email
		Subject = "Kaffee"
		SmtpServer = (Get-ConfigValue "System.MailServer")
		UseSSL = $True
		Body = $body
		BodyAsHtml = $true
	}
	Send-MailMessage @splat
	
	# End of Execution
	Write-DebugEx -Message "Ordering Coffee" -Level 9 -Tag "Finish"
}

function Register-Trainee
{
	<#
		.SYNOPSIS
			Registers Trainees
		
		.DESCRIPTION
			Creates a new Trainee and registers it, so it is ready for subjugation and coffee-fetching services
		
		.PARAMETER Givenname
			he given name of the rotten bastard
		
		.PARAMETER Surname
			The surname of the trainee
		
		.PARAMETER Handle
			The curse we use to refer to him
		
		.PARAMETER DateOfBirth
			The Birthday of this unlucky fellow
		
		.PARAMETER Email
			Where do orders go?
		
		.EXAMPLE
			PS C:\> Register-Trainee -Givenname 'Max' -Surname 'Mustermann' -Handle 'Maxxie' -DateOfBirth (Get-Date -Year 1998 -Month 2 -Day 28) -Email 'max.mustermann@domain.de'
	
			Registers the trainee Max Mustermann
		
		.NOTES
			Author:     Friedrich Weinmann
			Company:    Infernal Associates ltd.
			Created On: 10.12.2016
			Changed On: 10.12.2016
			Version:    1.0
			
			Version History
			1.0 (10.12.2016)
			- Initial release
	#>
	
	[CmdletBinding()]
	param
	(
		[Parameter(Mandatory = $true, Position = 0)]
		[string]
		$Givenname,
		
		[Parameter(Mandatory = $true, Position = 1)]
		[string]
		$Surname,
		
		[Parameter(Mandatory = $true, Position = 2)]
		[string]
		$Handle,
		
		[Parameter(Mandatory = $true, Position = 3)]
		[DateTime]
		$DateOfBirth,
		
		[Parameter(Mandatory = $true, Position = 4)]
		[string]
		$Email
	)
	
	try
	{
		[Demo.Utility.Trainee]::List.Add((New-Object Demo.Utility.Trainee($Givenname, $Surname, $Handle, $DateOfBirth, $Email)))
	}
	catch
	{
		throw
	}
}
#endregion Coffee Related functions