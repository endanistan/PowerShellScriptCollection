#$UserPrincipalName expects "UserName@domain.TopLevelDomain".
param (
    [Parameter(Mandatory = $true)][String]$tenantid,
    [Parameter(Mandatory = $true)][String]$DisplayNameParameter,
    [Parameter(Mandatory = $true)][String]$UserPrincipalName,
    [Parameter(Mandatory = $true)][String]$PWD,
    [Parameter(Mandatory = $false)][String[]]$Groups
)  

if  (-not (Get-Module -listAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
}

Connect-MgGraph -tenantid $tenantid -scopes "user.readwrite.all, group.readwrite.all" -NoWelcome  

#Adds new user to Microsoft Entra.
#$MailNickname is "UserName" part of $UserPrincipalName see line 2 for reference.
    $GivenName = $DisplayNameParameter.Split(' ')[0]
    $Surname = $DisplayNameParameter.Split(' ')[1..($DisplayNameParameter.Split(' ').Count - 1)] -join ' '
    $MailNickname = $UserPrincipalName.Split('@')[0]
    $passwordprofile = @{}
    $passwordprofile["Password"] = $PWD
    $passwordprofile["forceChangePasswordNextSignIn"] = $True
    $passwordprofile["forceChangePasswordNextSignInWithMfa"] = $False
    
    New-MgUser `
        -DisplayName $DisplayNameParameter `
        -MailNickname $MailNickname `
        -UserPrincipalName $UserPrincipalName `
        -GivenName $GivenName `
        -Surname $Surname `
        -PasswordProfile $passwordprofile ` -AccountEnabled `


    if ($groups) {
        foreach ($Group in $Groups) {
        $AddToGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}).id
        $AddThisUser = (Get-MgUser | Where-Object {$_.DisplayName -eq "$DisplayNameParameter"}).id
        New-MgGroupMember -GroupId $AddToGroup -DirectoryObjectId $AddThisUser
        }
    }
