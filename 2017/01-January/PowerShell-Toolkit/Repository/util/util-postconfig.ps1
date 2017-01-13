#region Email
Set-Config -Module "System" -Name "MailServer" -Value "mail.DEMO.test" -Hidden
#endregion Email

#region User specific
Set-Config -Module "Shell" -Name "User" -Value $__Config.UserName.Split("@")[0]
Set-Config -Module "Shell" -Name "UserMail" -Value $__Config.UserName
#endregion User specific

#region Add Trainees
Register-Trainee -Givenname 'Simon' -Surname 'Wolny' -Handle 'Wolny' -DateOfBirth (Get-Date -Year 1998 -Month 2 -Day 28) -Email 'swy@netzwerker.de'
#endregion Add Trainees