param(
	[Parameter(Mandatory = $True)][string[]]$Groups
)

function Get-DisabledUserInGroup {
	param (
		[string]$GroupName
	)
	foreach ($DisabledUser in $DisabledUsers) {
		$GroupId = (Get-MgGroup -Filter "displayName eq '$GroupName'").Id
		$GroupMembers = Get-MgGroupMemberAsUser -GroupId $GroupId -All | Select-Object Id, UserPrincipalName
		$DisabledInGroup = $GroupMembers | Where-Object { $DisabledUsers.Id -contains $_.Id }
	}
	return $DisabledInGroup
}


$path = "$ENV:USERPROFILE"
$DisabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All | Select-Object Id, UserPrincipalName

foreach ($Group in $Groups) {
	Write-Host "Processing group $Group" -ForegroundColor Cyan
	$DisabledInGroup = Get-DisabledUserInGroup -GroupName $Group
	if (Test-Path "$path\$Group-DisabledUsers.csv") {
		Remove-Item "$path\$Group-DisabledUsers.csv"
	}
	$DisabledInGroup | Select-Object UserPrincipalName | Export-Csv -Path "$path\$Group-DisabledUsers.csv" -Delimiter ";" -NoTypeInformation
	if (Test-Path "$path\$Group-DisabledUsers.csv") {
		Write-Host "Output exported to '$path\$Group-DisabledUsers.csv'" -ForegroundColor Green
	}
}
