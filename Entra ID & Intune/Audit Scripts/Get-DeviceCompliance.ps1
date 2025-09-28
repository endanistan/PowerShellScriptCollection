$devices = Get-MgDeviceManagementManagedDevice -All |
    Where-Object { $_.Compliancestate -ne "compliant" }
    | Select-Object DeviceName, UserPrincipalName, OperatingSystem, OsVersion, LastSyncDateTime, UserId

$results = foreach ($dev in $devices) {

    $LastSignin = Get-MgUser -UserId $dev.UserId -Property "displayName,signInActivity" |
        Select-Object displayName, @{Name = "LastSignInDate"; Expression = { $_.SignInActivity.LastSignInDateTime } }

    [PSCustomObject]@{
        Name        = $dev.DeviceName
        UPN         = $dev.UserPrincipalName
        OS          = "$($dev.OperatingSystem) $($dev.OsVersion)"
        LastCheckIn = $dev.LastSyncDateTime
        LastSignin  = $LastSignin.LastSignInDate
    }
}

$results | Sort-Object Name, UPN, OS, LastSignin, LastSyncDateTime |
    Export-Csv .\IntuneDevices.csv -Delimiter ";" -NoTypeInformation
