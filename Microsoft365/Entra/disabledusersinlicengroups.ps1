Param(
	[Parameter(Mandatory = $True)][string[]]$Groups,
	[Parameter(Mandatory = $false)][switch]$RemoveUsers
)

		$SecretValue = 
		#$ClientSecret = 
		$ClientID = 
		$TenantID = 

		$Body = @{
			grant_type    = "client_credentials"
			scope         = "https://graph.microsoft.com/.default"
			client_id     = $ClientID
			client_secret = $SecretValue
		}
		$Headers = @{ "Content-Type" = "application/x-www-form-urlencoded" }
		$TokenResponse = Invoke-RestMethod `
			-Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" `
			-Method Post `
			-Body $Body `
			-Headers $Headers
		$AccessToken = $TokenResponse.access_token
		$SecureToken = ConvertTo-SecureString $AccessToken -AsPlainText -Force
	
		Connect-MgGraph -AccessToken $SecureToken -NoWelcome

$path = "$ENV:USERPROFILE\OneDrive\Desktop\"
$DisabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All |
    Select-Object Id, UserPrincipalName

function Get-DisabledUsersInGroup {
	param (
		[string]$GroupName,
		[switch]$RemoveUsers
	)

	$GroupId = (Get-MgGroup -Filter "displayName eq '$GroupName'").Id
	$GroupMembers = Get-MgGroupMemberAsUser -GroupId $GroupId -All | Select-Object Id, UserPrincipalName
	$DisabledInGroup = $GroupMembers | Where-Object {
		$DisabledUsers.Id -contains $_.Id
	}
	if ($RemoveUsers) {
		foreach ($User in $DisabledInGroup) {
			Write-Host "Removing user $($User.UserPrincipalName) from group $GroupName" -ForegroundColor Yellow
			Remove-MgGroupMember -GroupId $GroupId -MemberId $User.Id
		}
	} else{
		return $DisabledInGroup
	}
}

if ($RemoveUsers) {
	foreach ($Group in $Groups) {
		Write-Host "Processing group $Group" -ForegroundColor Cyan
		Get-DisabledUsersInGroup -GroupName $Group -RemoveUsers
	}
} else {
	foreach ($Group in $Groups) {
		Write-Host "Processing group $Group" -ForegroundColor Cyan
		$DisabledInGroup = Get-DisabledUsersInGroup -GroupName $Group
		if (Test-Path "$path\$Group-DisabledUsers.csv") {
			Remove-Item "$path\$Group-DisabledUsers.csv"
		} else {
			$DisabledInGroup | Select-Object UserPrincipalName | Export-Csv -Path $path -Delimiter ";" -NoTypeInformation
			if (Test-Path "$path\$Group-DisabledUsers.csv") {
				Write-Host "Output exported to '$path\$Group-DisabledUsers.csv'" -ForegroundColor Green
			} else {
				Write-Host "Something went wrong, file '$path\$Group-DisabledUsers.csv' not created" -ForegroundColor Red
			}
		}
	}
}