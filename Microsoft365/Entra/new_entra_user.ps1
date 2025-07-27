param (
    [Parameter(Mandatory = $false)][String]$DN,
    [Parameter(Mandatory = $false)][String]$UPN,
    [Parameter(Mandatory = $false)][String[]]$Groups
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
        $GivenName = $DN.Split(' ')[0]
        $Surname = $DN.Split(' ')[1..($DN.Split(' ').Count - 1)] -join ' '
        $MailNickname = $UPN.Split('@')[0]
        $passwordprofile = @{}
        $passwordprofile["Password"] = $RandomPassword
        $passwordprofile["forceChangePasswordNextSignIn"] = $True
        $passwordprofile["forceChangePasswordNextSignInWithMfa"] = $False
    
        New-MgUser `
            -DisplayName $DN `
            -MailNickname $MailNickname `
            -UserPrincipalName $UPN `
            -GivenName $GivenName `
            -Surname $Surname `
            -PasswordProfile $passwordprofile ` -AccountEnabled `
        
        if ((Get-MgUser | Where-Object {$_.DisplayName -eq "$DN"}).id) {
            Write-Host "$DN added with username $UPN and their password is copied to your clipboard" -ForegroundColor Green
        } else {
            Write-Host "User $DN could not be added"
        }
    }
    
    function UserGroups {
        foreach ($Group in $Groups) {
            $AddToGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}).id
            $AddThisUser = (Get-MgUser | Where-Object {$_.DisplayName -eq "$DN"}).id
            if (-not $AddToGroup) {
                Write-Warning "The group $group could not be found, skipping..."
                continue
            } else {
                New-MgGroupMember -GroupId $AddToGroup -DirectoryObjectId $AddThisUser -ErrorAction SilentlyContinue
            }
        }
            foreach ($Group in $Groups) {
                $CheckThisGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}).id
                $IsUserInGroup = Get-MgGroupMemberAsUser -groupid $CheckThisGroup | Where-Object {$_.DisplayName -eq "$DN"}
                if ($IsUserinGroup) {
                    Write-Host "$DN have been added to the group $Group"  -ForegroundColor Green
                } else {
                    Write-Host "$DN has not been added to the group $Group" -ForegroundColor Yellow
                }
            }
    }

if ($DN -or $UPN -or $Groups) { 
    $TenantId = "" #Add tenantid
    Connect-MgGraph -tenantid $TenantId -scopes "user.readwrite.all", "group.read.all", "RoleManagement.ReadWrite.Directory" -NoWelcome
}

if ($DN -and $UPN) {
    $CheckUPN = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" -ErrorAction SilentlyContinue
    if ($CheckUPN) {
        Write-Host "User $UPB already exists" -ForegroundColor Red
        Break
    } else {
        Write-Host "User $DN does not exist, proceeding to create user..." -ForegroundColor Cyan
        NewEntraUser
    }
} else {
    Write-Host "No user added, specify value for -DN and -UPN"
}

If ($Groups) {
        $CheckUserName = Get-MgUser -Filter "DisplayName eq '$DN'" -ErrorAction SilentlyContinue
        if (-not $CheckUserName) {
            Write-Warning "User $DN does not exist. Could not add groups."
            Break
        } else {
            Write-Host "User $DN exists, proceeding to add to groups..." -ForegroundColor Cyan
            UserGroups
        }
} else {
    Write-Warning "No groups specified."
}

Disconnect-MgGraph
Write-Host "Script finished." -ForegroundColor Yellow
