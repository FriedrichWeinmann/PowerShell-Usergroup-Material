#region Configurations
#region Coffee
Set-Config -Module "Default" -Name "CoffeeMilk" -Value 0
Set-Config -Module "Default" -Name "CoffeeSugar" -Value 0
Set-Config -Module "Default" -Name "CoffeeFetcher" -Value "Wolny"
#endregion Coffee

#region System
Set-Config -Module "Shell" -Name "User" -Value "Friedrich"
#endregion System
#endregion Configurations