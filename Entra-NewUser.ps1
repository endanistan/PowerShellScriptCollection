#Parameters for the script
param (
    [Parameter(Mandatory = $true)][String]$DisplayName,
    [Parameter(Mandatory = $true)][String]$UserPrincipalName,
    [Parameter(Mandatory = $true)][String]$PWD,
    [Parameter(Mandatory = $false)][String]$Group
)  

#Installs microsoft.graph if already not installed
if  (-not (Get-Module -listAvailable -Name Microsoft.Graph)) {
    Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
    Write-Warning "Microsoft Graph module is not installed. Installing..."
}

#Connects user to microsoft.graph
Connect-MgGraph -scopes "user.readwrite.all, group.readwrite.all" -NoWelcome

#Adds new user to Microsoft Entra
try {
    $PWProfile = @{
        Password = $PWD;
        ForceChangePasswordNextSignIn = $false
    }
    $MailNickname = $UserPrincipalName.Split('@')[0]

    New-MgUser `
        -DisplayName $DisplayName `
        -MailNickname $MailNickname `
        -UserPrincipalName $UserPrincipalName `
        -PasswordProfile $PWProfile -AccountEnabled `
}
catch {
    Read-Host "Unexpected error, $DisplayName not added to Microsoft Entra"
}


#Assigns the user to group
if (-not $Group) {
        $Group = Read-Host "User added without group assignment" -AsSecureString
}
else { try {
        $Addtogroup = Get-MgGroup | Where-Object {$_.DisplayName -eq "$Group"}
        $Addthisuser = Get-MgUser | Where-Object {$_.DisplayName -eq "$DisplayName"}
        New-MgGroupMember -GroupId $Addtogroup.Id -DirectoryObjectId $Addthisuser.Id  
    }
catch {
        Read-Host "Unexpected error. User added, but without group assignment"
    } 
   
}