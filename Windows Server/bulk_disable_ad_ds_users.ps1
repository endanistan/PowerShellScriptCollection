#split strings after first white space and export remaining info into csv
#Created for work to bulk disable inactive accounts.
#Inactive UPNs comes in through an alert once a month bundled with white spaces and text after the UPN. So first two lines are just to split the strings and convert to csv that can be used to disable the accounts.
$users = Get-Content -Path "$ENV:HOME\users.txt" | foreach { [PSCustomObject]@{ UserPrincipalName = ($_ -split '\s+')[0] } }
$users | Export-Csv -Path "$ENV:HOME\users.csv" -NoTypeInformation

$users = import-csv -path "c:\path\to\file.csv"

#Check is a user to be disabled is already disabled
foreach ($user in $users) {
	$firstcheck = Get-AdUser -filter "UserPrincipalName -eq '$($user.UserPrincipalName)'"  | Select-object -property Name, SamAccountName, Enabled
	if ($firstcheck.enabled -eq $false) {
		Write-Host "'$($firstcheck.name)' is already inactive"
	}
}

#Disable
foreach ($user in $users) { Get-AdUser -filter "UserPrincipalName -eq '$($user.UserPrincipalName)'" | Set-Aduser -description "Disabled due to Inactivity" -Enabled $false }

#Check if they actually are disabled
foreach ($user in $users) {
	$secondcheck = Get-AdUser -filter "UserPrincipalName -eq '$($user.UserPrincipalName)'"  | Select-object -property Name, SamAccountName, Enabled
	if ($secondcheck.enabled -eq $true) {
		Write-Host "'$($secondcheck.name)' is still enabled"
	}
}
#If null value is returned you're done








