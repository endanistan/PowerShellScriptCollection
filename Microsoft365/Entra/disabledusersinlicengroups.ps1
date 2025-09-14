Param(
	[Parameter(Mandatory = $True)][string[]]$Groups
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

function Get-DisabledUserInGroup {
	param (
		[string]$GroupName
	)	
		foreach ($DisabledUser in $DisabledUsers) {
			$GroupId = (Get-MgGroup -Filter "displayName eq '$GroupName'").Id
			$GroupMembers = Get-MgGroupMemberAsUser -GroupId $GroupId -All | Select-Object Id, UserPrincipalName
			$DisabledInGroup = $GroupMembers | Where-Object { $DisabledUsers.Id -contains $_.Id}
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