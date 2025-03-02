#Parameters for the script
param (
    [Parameter(Mandatory = $true)][String]$DisplayName,
    [Parameter(Mandatory = $true)][String]$UserPrincipalName,
    [Parameter(Mandatory = $true)][String]$PWD,
    [Parameter(Mandatory = $false)][String]$Group
)  

#Installs microsoft.graph if already not installed
try {
    if  (-not (Get-Module -listAvailable -Name Microsoft.Graph)) {
        Install-Module Microsoft.Graph -Scope CurrentUser -Repository PSGallery -Force
        Write-Warning "Microsoft Graph module is not installed. Installing..."
    }
}
catch {
    Write-Output "Could not install Microsoft Graph."
}

#Connects user to microsoft.graph and if it fails tries again after changing ExecutionPolicy
for ($i = 1; $i -le 2; $i++) {
    try {
    Connect-MgGraph -scopes "user.readwrite.all, group.readwrite.all" -NoWelcome  
    }
    catch {
    $i
    Write-Output "Could not connect to microsoft graph... trying to change execution policy..."
        try {
            Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
            Write-Output "ExecutionPolicy set to RemoteSigned. Trying to reconnect to microsoft graph"
        }
        catch {
            Write-Output "ExecutionPolicy could not be changed, aborting script."
        }
    
    }
}

#Adds new user to Microsoft Entra
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