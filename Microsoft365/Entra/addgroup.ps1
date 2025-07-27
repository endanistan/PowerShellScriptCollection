param (
    [Parameter(Mandatory = $true)][String]$User,
    [Parameter(Mandatory = $false)][String]$GroupCSV
)

    function UserGroups {
        $Groups = Import-Csv -Path $GroupCSV -Delimiter ";" | Select-Object DisplayName
        foreach ($Group in $Groups) {
            $AddToGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq $Group.DisplayName}).id
            $AddThisUser = (Get-MgUser | Where-Object {$_.DisplayName -eq "$User"}).id
            if (-not $AddToGroup) {
                Write-Warning "Group $($Group.DisplayName) not found, skipping..."
                continue
            } else {
                New-MgGroupMember -GroupId $AddToGroup -DirectoryObjectId $AddThisUser -ErrorAction SilentlyContinue
            }
        }
            foreach ($Group in $Groups) {
                $CheckThisGroup = (Get-MgGroup | Where-Object {$_.DisplayName -eq $Group.DisplayName}).id
                $IsUserInGroup = Get-MgGroupMemberAsUser -groupid $CheckThisGroup | Where-Object {$_.DisplayName -eq "$User"}
                    if ($IsUserinGroup) {
                        Write-Host "$User have been added to the group" $Group.Displayname -ForegroundColor Green
                    } else {
                        Write-Host "$User has not been added to the group" $Group.DisplayName -ForegroundColor Yellow
                    }
            }
    }

$TenantId = "dbf3c20a-632e-412d-b396-82b07b103467"

If ($GroupCSV) {
    if (-not (Test-Path -Path $GroupCSV)) {
        Write-Warning "CSV path does not exist. Script Aborted."
        return
    } else {
        Connect-MgGraph -tenantid $TenantId -scopes "user.readwrite.all", "group.read.all" -NoWelcome
        $CheckUserName = Get-MgUser -Filter "DisplayName eq '$User'" -ErrorAction SilentlyContinue
        if (-not $CheckUserName) {
            Write-Warning "User $User does not exist. Script Aborted."
            return
        } else {
            Write-Host "User $User exists, proceeding to add to groups..." -ForegroundColor Cyan
            UserGroups
            Disconnect-MgGraph
        }
    }
} else {
    Write-Host "No CSV path specified, script finished... doing nothing..." -ForegroundColor Red
}