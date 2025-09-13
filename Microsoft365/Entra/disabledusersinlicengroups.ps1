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

$csvpath

$Groups = @{
    "GroupName" = "GroupId"
	"GroupName" = "GroupId"
	"GroupName" = "GroupId"
}

$DisabledUsers = Get-MgUser -Filter "accountEnabled eq false" -All |
    Select-Object Id, UserPrincipalName

foreach ($Group in $Groups.GetEnumerator()) {
    $GroupName = $Group.Key
    $GroupId   = $Group.Value

    Write-Host "Now processing group '$GroupName'..." -ForegroundColor Cyan

    $GroupMembers = Get-MgGroupMemberAsUser -GroupId $GroupId -All |
        Select-Object Id, UserPrincipalName

   $DisabledInGroup = $GroupMembers | Where-Object {
        $DisabledUsers.Id -contains $_.Id
    }

    $DisabledInGroup | Select-Object UserPrincipalName | Export-Csv -Path $csvpath -Delimiter ";" -NoTypeInformation
}