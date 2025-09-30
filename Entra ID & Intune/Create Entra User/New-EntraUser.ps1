param (
    [Parameter(Mandatory = $true)][String]$DN,
    [Parameter(Mandatory = $true)][String]$UPN,
    [Parameter(Mandatory = $false)][String[]]$Groups,
    [Parameter(Mandatory = $false)][String]$CSVList
)

function UserPassword {
    $Adjectives = @("Ferocious", "Sabertoothed", "Maneating", "Bloodthirsty", "Vengeful", "Merciless", "Wrathful", "Hellbound", "Soulharvesting", "Crazed", "Blessed", "Flesheating")
    $Nouns = @("Goldfish", "Froglet", "Bumblebee", "Pig", "Capybara", "Toad", "Rabbit", "Lamb", "Crab", "Shrimp", "Starfish")
    $Numbers = @("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    $Characters = @("#", "%", "!", "?", "+", "\", "*", "$", "/")
    $RandomAdjective = Get-Random $Adjectives
    $RandomNoun = Get-Random $Nouns
    $RandomNumber = Get-Random $Numbers
    $RandomCharacter = Get-Random $Characters
    $RandomEasyToType = -join ($RandomAdjective, $RandomNoun, $RandomNumber, $RandomCharacter)
    return $RandomEasyToType
}

function NewEntraUser {
    $RandomPassword = UserPassword
    $Passwordprofile = @{
        Password                             = $RandomPassword
        ForceChangePasswordNextSignIn        = $true
        ForceChangePasswordNextSignInWithMfa = $false
    }

    $UserSplat = @{
        DisplayName       = $DN
        MailNickname      = ($UPN.Split('@')[0])
        UserPrincipalName = $UPN
        GivenName         = ($DN.Split(' ')[0])
        Surname           = ($DN.Split(' ')[-1])
        PasswordProfile   = $Passwordprofile
        AccountEnabled    = $true
    }


    New-MgUser @UserSplat

    if ((Get-MgUser -Filter "DisplayName eq '$DN'").Id) {
        Write-Host "$DN added with username $UPN with password: $RandomPassword" -ForegroundColor Green
    } else {
        Write-Host "User $DN could not be added" -ForegroundColor Red
    }
}

function UserGroups {
    param (
        [switch]$CSV
    )

    if ($CSV) {
        $Groups = Import-Csv -Path $CSVList -Delimiter ";" | Select-Object -ExpandProperty DisplayName
    }

    foreach ($Group in $Groups) {
        $AddToGroup = (Get-MgGroup -Filter "DisplayName eq '$Group'").id
        $AddThisUser = (Get-MgUser -Filter "DisplayName eq '$DN'").id
        if (-not $AddToGroup) {
            Write-Warning "The group $Group could not be found, skipping..."
        } else {
            Write-Host "Adding $DN to $Group" -ForegroundColor Cyan
            New-MgGroupMember -GroupId $AddToGroup -DirectoryObjectId $AddThisUser -ErrorAction SilentlyContinue
            if (Get-MgGroupMemberAsUser -GroupId $AddtoGroup | Where-Object { $_.DisplayName -eq $DN }) {
                Write-Host "$DN has been added to $Group" -ForegroundColor Green
            } else {
                Write-Host "$DN has not been added to $Group" -ForegroundColor Red
            }
        }
    }
}

$CheckUPN = Get-MgUser -Filter "UserPrincipalName eq '$UPN'" -ErrorAction SilentlyContinue
if ($CheckUPN) {
    $continue = Read-Host -Prompt "User already exists, do you wish to continue to add groups to the user? (y/n)"
    if ($continue -ne 'y') {
        Write-Warning "Aborting, no groups will be added"
        return
    }
    Write-Host "Preceeding to add groups to user '$UPN'..." -ForegroundColor Cyan
} else {
    Write-Host "User $DN does not exist, proceeding to create user..." -ForegroundColor Cyan
    NewEntraUser
}


if ($null -eq $Groups -and $null -eq $CSVList) {
    Write-Warning "No groups specified!"
}
if ($Groups -and $CSVList) {
    Write-Error "You cannot specify both -Groups and -CSVList. Please use only one."
    return
}
if ($Groups) {
    UserGroups
}
if ($CSVList) {
    UserGroups -CSV
}
