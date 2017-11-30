Get-ChildItem D:\Temp
Get-ChildItem D:\Temp | Sort-Object Length
"D:\Temp" | Get-ChildItem

Get-ChildItem D:\Temp | Where-Object {$_.Name -like "m*"}
Get-ChildItem D:\Temp | Where-Object {$_.Name -like "m[is]*"}
Get-ChildItem D:\Temp | ForEach-Object {$_.FullName}
Get-ChildItem D:\Temp | Where-Object {$_.Name -like "m*"} | ForEach-Object {$_.FullName}

Get-ChildItem D:\Temp | ForEach-Object {
	if ($_.Length -gt 100000) { "Too long: $($_.FullName)" }
	else { "Too short: $($_.FullName)"}
}