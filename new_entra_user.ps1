#Parameters for the script.
#$UserPrincipalName expects f.ex. "UserName@domain.topleveldomain".
param (
    [Parameter(Mandatory = $true)][String]$DisplayName,
    [Parameter(Mandatory = $true)][String]$UserPrincipalName,
    [Parameter(Mandatory = $true)][String]$PWD,
    [Parameter(Mandatory = $false)][String]$Group
)  

#Installs microsoft.graph if already not installed.
try {
    if  (-not (Get-Module -listAvailable -Name Microsoft.Graph)) {
        Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
        Write-Warning "Microsoft Graph module is not installed. Installing..."
    }
}
catch {
    Write-Warning "Could not install Microsoft Graph."
}

#Connects user to microsoft.graph and if it fails tries again after changing ExecutionPolicy.
for ($i = 1; $i -le 2; $i++) {
    try {
    Connect-MgGraph -scopes "user.readwrite.all, group.readwrite.all" -NoWelcome  
    }
    catch {
    Write-Output "Could not connect to microsoft graph... trying to change execution policy..."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
            Write-Output "ExecutionPolicy set to RemoteSigned. Trying to reconnect to microsoft graph."
        }
        catch {
            Write-Warning "ExecutionPolicy could not be changed, aborting script. Is pwsh.exe running as administrator?"
        }
    
    }
}

#Adds new user to Microsoft Entra.
#$MailNickname is "UserName" part of $UserPrincipalName see line 2 for reference.
try {
    $MailNickname = $UserPrincipalName.Split('@')[0]
    $PWProfile = @{
        Password = $PWD;
        ForceChangePasswordNextSignIn = $false
    }
    
    New-MgUser `
        -DisplayName $DisplayName `
        -MailNickname $MailNickname `
        -UserPrincipalName $UserPrincipalName `
        -PasswordProfile $PWProfile ` -AccountEnabled `
}
catch {
    Read-Warning "Unexpected error, $DisplayName not added to Microsoft Entra."
}


#Assigns the user to an existing group.
#This script can not create new a MgGroup.
if (-not $Group) {
        $Group = Read-Host "$DisplayName added without group assignment." -AsSecureString
}
else { try {
        $AddToGroup = Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}
        $AddThisUser = Get-MgUser | Where-Object {$_.DisplayName -eq "$DisplayName"}
        New-MgGroupMember -GroupId $AddToGroup.Id -DirectoryObjectId $AddThisUser.Id  
    }
    catch {
        Read-Warning "Unexpected error. $DisplayName added, but without group assignment."
    } 
   
}