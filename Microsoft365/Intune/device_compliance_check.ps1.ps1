Connect-MgGraph -Tenantid "" -clientid "" -Scopes "DeviceManagementManagedDevices.Read.All", "Directory.Read.All", "User.Read.All", "Auditlog.Read.All" -NoWelcome
$devices = Get-MgDeviceManagementManagedDevice -All | where-object {$_.Compliancestate -ne "compliant" } | Select-Object DeviceName, UserPrincipalName, OperatingSystem, OsVersion, LastSyncDateTime, UserId
$results = foreach ($dev in $devices) {
        $LastSignin = Get-MgUser -UserId $dev.UserId -Property "displayName,signInActivity" | Select-Object displayName,@{Name="LastSignInDate";Expression={$_.SignInActivity.LastSignInDateTime}}
        [PSCustomObject]@{
            Name         = $dev.DeviceName
            UPN          = $dev.UserPrincipalName
            OS           = "$($dev.OperatingSystem) $($dev.OsVersion)"
            LastCheckIn  = $dev.LastSyncDateTime
            LastSignin   = $LastSignin.LastSignInDate
        }
}
 
$results | Sort-Object Name, UPN, OS, LastSignin, LastSyncDateTime | Export-Csv .\IntuneDevices.csv -Delimiter ";" -NoTypeInformation