param (
    [Parameter(Mandatory = $true)][String]$tenantid,
    [Parameter(Mandatory = $false)][String]$DN,
    [Parameter(Mandatory = $false)][String]$UPN,
    [Parameter(Mandatory = $false)][String[]]$Groups
)  

    function UserPassword {
        $letterNumberArray = @('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*')
        for (($counter = 0); $counter -lt 20; $counter++) {
        $randomCharacter = get-random -InputObject $letterNumberArray
        $randomString = $randomString + $randomCharacter
        }
        Set-Clipboard -value "$randomString"
        return $randomString
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
    }
    
    function UserGroups {
        foreach ($Group in $Groups) {
        $AddToGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}).id
        $AddThisUser = (Get-MgUser | Where-Object {$_.DisplayName -eq "$DN"}).id
        New-MgGroupMember -GroupId $AddToGroup -DirectoryObjectId $AddThisUser
        }
    }

if  (-not (Get-Module -listAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
}

Connect-MgGraph -tenantid $tenantid -scopes "user.readwrite.all", "group.readwrite.all" -NoWelcome

    if ($DN -and $UPN) {
        NewEntraUser
        if ((Get-MgUser | Where-Object {$_.DisplayName -eq "$DN"}).id) {
            Write-Host "$DN added with username $UPN and their password is copied to your clipboard"
        }
    }

    else {
        Write-Host "No user added, specify value for -DN and -UPN"
    }


    if ($groups) {
        UserGroups
        foreach ($Group in $Groups) {
            $CheckThisGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}).id
            $IsUserInGroup = Get-MgGroupMemberAsUser -groupid $CheckThisGroup | Where-Object {$_.DisplayName -eq "$DN"}
                if ($IsUserinGroup) {
                    Write-Host "$DN have been added to $group"
                }
        }
    }

    else {
        Write-Host "No groups specified"
    }

Disconnect-MgGraph