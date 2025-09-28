param(
    [Parameter(Mandatory = $True)][String]$GroupId,
    [Parameter(Mandatory = $True)][String]$SkuPartNumber,
    [Parameter(Mandatory = $False)][Switch]$GetLastSignIn
)

function Get-LicensedUserInGroup {
    param (
        [Switch]$GetLastSignIn,
        [String]$GroupId
    )

    $Result = (Get-MgGroupMemberAsUser -GroupId $GroupId).UserPrincipalName |
        ForEach-Object {
            $User = Get-MgUser -Filter "UserPrincipalName eq '$_'"
            $Lic = (Get-MgUserLicenseDetail -UserId $User.Id).SkuPartNumber

            if ($Lic -eq $SkuPartNumber) {
                $LastSignInValue = $null

                if ($GetLastSignIn) {
                    $LastSignIn = (Get-MgUser -UserId $User.Id `
                            -Property SignInActivity).SignInActivity.LastSignInDateTime
                    if ((Get-Date).AddDays(-21) -ge $LastSignIn) {
                        $LastSignInValue = $LastSignIn
                    } else {
                        $LastSignInValue = "Active"
                    }
                }

                [PSCustomObject]@{
                    UserPrincipalName = $user.UserPrincipalName
                    License           = $lic
                    LastSignIn        = $lastSignInValue
                }
            }
        }
    return $Result
}

if ($GetLastSignIn) {
    Get-LicensedUserInGroup -GroupId $GroupId -GetLastSignIn
} else {
    Get-LicensedUserInGroup -GroupId $GroupId
}
