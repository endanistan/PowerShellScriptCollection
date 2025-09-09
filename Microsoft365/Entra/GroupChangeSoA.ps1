#This script changes the Source of Authority of a group from OnPremises to Cloud
#Required permissions: Group.Read.All & Group.ReadWrite.All
#Yes, it's over engineered.
Param (
    [Parameter(Mandatory = $True)][string]$Group,
    [Parameter(Mandatory = $True)][int]$GraphAppId
)

Begin {
$Key = (Import-Csv `
    -Path "$ENV:USERPROFILE\OneDrive\Dokument\PowerShell\Scripts\Keys\Wideopen.csv" `
    -Delimiter ";")[$GraphAppId]

$SecretValue = "$($Key.Secret -split ","[0])"
$ClientID = "$($Key.ClientID)"
$TenantID = "$($Key.TenantID)"


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


Write-Host "Attempting to sign in to $($Key.Name)..."
Connect-MgGraph -AccessToken $SecureToken -NoWelcome


    $GroupId = (Get-MgGroup -Filter "DisplayName eq '$Group'").Id


    function SourceOfAuthority {
        param (
            [string]$GroupId
        )
        $SoAStatus = Invoke-MgGraphrequest `
            -Method GET `
            -Uri "https://graph.microsoft.com/beta/groups/{$GroupId}/onPremisesSyncBehavior?$select=isCloudManaged"
        return $SoAStatus.isCloudManaged
    }
}


Process {
    if ((SourceOfAuthority -GroupId $GroupId) -eq $False) {
        Write-Host "$Group is currently On-Prem managed, changing SoA to cloud"
        Invoke-MgGraphrequest `
            -Method PATCH `
            -Uri "https://graph.microsoft.com/beta/groups/{$GroupId}/onPremisesSyncBehavior" `
            -Body '{ "isCloudManaged": true }'
            if ((SourceOfAuthority -GroupId $GroupId) -eq $True) {
                Write-Host "Source Of Authority successfully changed to Cloud"

            } else {
                Write-Host "Source Of Authority change failed"

            }
    } else {
        Write-Host "$Group is already cloud managed"
    }
}


End {
    Disconnect-MgGraph
}