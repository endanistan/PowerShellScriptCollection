#csv file requires header sam and date, where sam expects samaccountname and date is supposed to be the date added to the csv file. Script run as a daily job and after 30 days the user is moved to an unsynced ou.
#date format is supposed to be yyyy mmm dd (e.g. 2025-12-31)
#PossibleOU is just a sample, script was made for an environement with alot of different regions which could be determined by portion of distinguishedname
     Start-Transcript -path "C:\Script\unsyncusers.log" -Append
    
    $users = Import-Csv -Path "C:\script\unsyncusers.csv" -Delimiter ";" | ForEach-Object {
        $_.date = [datetime]::ParseExact($_.date, "yyyy-MM-dd", $null) 
            $_
    }

    $PossibleOU = @{
        "OU=Contos,OU=Sweden"  = "OU=Contoso,OU=Sweden,OU=Terminated,OU=HS,DC=Contoso,DC=loc"
        "OU=Group,OU=Sweden"   = "OU=Group,OU=Sweden,OU=Terminated,OU=HS,DC=Contoso,DC=loc"
    }

    function Get-TargetOu {
        param (
            [string]$DistinguishedName
        )

        foreach ($company in $PossibleOu.Keys) {
            if ($DistinguishedName -match $company) {
                return $PossibleOU[$company]
            } else {
                return $null
            }
        } 
    }

    $remaining = @()
    foreach ($user in $users) {
        try {
            if ((Get-Date).AddDays(-30) -ge $user.date) {
                $moveuser = Get-AdUser -Identity $user.sam -Properties name,samaccountname,distinguishedname,enabled | Select-Object name,samaccountname,distinguishedname,enabled -erroraction Stop
                    $TargetOu = Get-TargetOu -DistinguishedName $moveuser.DistinguishedName
                    if ($TargetOu) {
                        Write-Host "Attempting to move $($moveuser.samaccountname) to $TargetOu"
                        Move-ADObject -Identity $moveuser.DistinguishedName -TargetPath $TargetOu
                    } else {
                        Write-Warning "Could not find a target ou for $($moveuser.samaccountname)"
                        $remaining += $user
                    }
                } else {
                    $remaining += $user
                }
            } catch {
            Write-Warning "Error processing $($user.sam)"
            $remaining += $user
        }
    }

    $remaining | Select-Object @{n='sam' ;e={$_.sam}}, @{n='date'; e={$_.date.ToString('yyy/MM/dd')}} | Export-Csv -Path "C:\script\unsyncusers.csv" -Delimiter ";" -NoTypeInformation

    Stop-Transcript
