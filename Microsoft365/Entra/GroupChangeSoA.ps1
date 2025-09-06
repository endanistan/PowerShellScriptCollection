#My prefered Connect-MgGraph authentication method is using an access token from different Graph app for each purpose for granular permissions
#Least privilege for this script is Group.Read.All & Group.ReadWrite.All
#This script changes the Source of Authority of a group from OnPremises to Cloud
$SecretValue = ""
$ClientID = ""
$TenantID = ""

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
Connect-MgGraph -AccessToken $SecureToken -NoWelcome


#Edit {GroupID} with your Group objectID
#Check current Source of Authority
Invoke-MgGraphrequest -method GET -uri "https://graph.microsoft.com/beta/groups/{GroupID}/onPremisesSyncBehavior?$select=isCloudManaged"

#Edit {GroupID} with your Group objectID
#Change Source of Authority to Cloud

Invoke-MgGraphrequest -method patch -uri "https://graph.microsoft.com/beta/groups/{6f534c50-bf87-4625-813f-b9160dc39e45}/onPremisesSyncBehavior" -body '{ "isCloudManaged": true }' 
