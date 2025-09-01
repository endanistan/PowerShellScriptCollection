param (
    [Parameter(Mandatory = $false)][String]$DN,
    [Parameter(Mandatory = $false)][String]$UPN,
    [Parameter(Mandatory = $false)][String[]]$Groups,
	[Parameter(Mandatory = $false)][String]$CSVList
)  

    function UserPassword {
        $adjectives = @("Ferocious", "Sabertoothed", "Maneating", "Bloodthirsty", "Vengeful", "Merciless", "Warthful", "Hellbound", "Soulharvesting", "Crazed", "Bleesed", "Flesheating")
        $nouns = @("Goldfish", "Froglet", "Bumblebee", "Pig", "Capybara", "Toad", "Rabbit", "Lamb", "Crab", "Shrimp", "Starfish")
        $numbers = @("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
        $characters = @("#", "%", "!", "?", "+", "\", "*", "$", "/")
        $randomAdjective = get-random -InputObject $adjectives
        $randomNoun = get-random -InputObject $nouns
        $randomNumber = get-random -InputObject $numbers
        $randomCharacter = get-random -InputObject $characters
        $randomEasyToType = "$randomAdjective" + "$randomNoun" + "$randomNumber" + "$randomCharacter"
        Set-Clipboard -Value $randomEasyToType
        return $randomEasyToType
    }

    function NewEntraUser {
        $RandomPassword = UserPassword
		$passwordprofile = @{
			Password = $RandomPassword
			forceChangePasswordNextSignIn = $true
			forceChangePasswordNextSignInWithMfa = $false
		}
        New-MgUser `
            -DisplayName $DN `
            -MailNickname ($UPN.Split('@')[0]) `
            -UserPrincipalName $UPN `
            -GivenName ($DN.Split(' ')[0]) `
            -Surname ($DN.Split(' ')[1..($DN.Split(' ').Count - 1)] -join ' ') `
            -PasswordProfile $passwordprofile ` -AccountEnabled `
        
        if ((Get-MgUser -Filter "displayName eq '$DN'").Id) {
            Write-Host "$DN added with username $UPN and their password is copied to your clipboard" -ForegroundColor Green
        } else {
            Write-Host "User $DN could not be added"
        }
    }
    
    function UserGroups {
		param (
		[switch]$CSV
		)
		if ($CSV) {
			$GroupsFromCsv = Import-Csv -Path $CSVList -Delimiter ";" | Select-Object -ExpandProperty DisplayName
			foreach ($Group in $GroupsFromCsv) {
				$CSVAddToGroup = (Get-MgGroup -Filter "displayName eq '$Group'").Id
				$CSVAddThisUser = (Get-MgUser -Filter "displayName eq '$DN'").Id
				if (-not $CSVAddToGroup) {
					Write-Warning "The group $Group could not be found, skipping..."
					continue
				} else {
					Write-Host "Adding $DN to $Group" -Foreground Cyan
					New-MgGroupMember -GroupId $CSVAddToGroup -DirectoryObjectId $CSVAddThisUser -ErrorAction SilentlyContinue
				}
			}
		} else {		
			foreach ($Group in $Groups) {
				$AddToGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}).id
				$AddThisUser = (Get-MgUser | Where-Object {$_.DisplayName -eq "$DN"}).id
				if (-not $AddToGroup) {
					Write-Warning "The group $Group could not be found, skipping..."
					continue
				} else {
					Write-Host "Adding $DN to $Group" -Foreground Cyan
					New-MgGroupMember -GroupId $AddToGroup -DirectoryObjectId $AddThisUser -ErrorAction SilentlyContinue
				}
			}
		}
	}


if ($DN -and $UPN) {
	$SecretValue = ""
	#$ClientSecret = ""
	$ClientID = ""
	$TenantID = ""

	$body = @{
		grant_type    = "client_credentials"
		scope         = "https://graph.microsoft.com/.default"
		client_id     = $ClientID
		client_secret = $SecretValue
	}
	$headers = @{ "Content-Type" = "application/x-www-form-urlencoded" }
	$TokenResponse = Invoke-RestMethod `
		-Uri "https://login.microsoftonline.com/$TenantID/oauth2/v2.0/token" `
		-Method Post `
		-Body $body `
		-Headers $headers
	$AccessToken = $TokenResponse.access_token
	$SecureToken = ConvertTo-SecureString $AccessToken -AsPlainText -Force
	
	Write-Host "Attempting to connect to Microsoft Graph..." -ForeGroundColor Magenta
	Connect-MgGraph -AccessToken $SecureToken -NoWelcome
	
    $CheckUPN = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" -ErrorAction SilentlyContinue
    if ($CheckUPN) {
        Write-Host "User $UPN already exists, preceeding to add groups" -ForegroundColor Red
    } else {
        Write-Host "User $DN does not exist, proceeding to create user..." -ForegroundColor Cyan
        NewEntraUser
    }
	
	if ($null -eq $Groups -and $null -eq $CSVList) {
		Write-Warning "No groups specified!"
	}
	if ($Groups) {
		UserGroups
	}
	if ($CSVList) {
		UserGroups -CSV
	}
} else { Write-Warning Specify DisplayName (DN), and UserPrincipalName (UPN)! }


Disconnect-MgGraph
Write-Host "Script finished. Disconnected Graph..." -ForegroundColor Magenta
Start-Sleep -seconds 2
Write-Host "Graph disconnected." -ForegroundColor Magenta
