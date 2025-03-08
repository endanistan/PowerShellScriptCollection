param (
    [Switch]$free,
    [Switch]$used,
    [Switch]$max
)

$drives = Get-Volume | Where-Object {$_.Driveletter -ne $null}

try {
    if ($free) {
        foreach ($volume in $drives) {
            $whole = $volume.Size
            $part = $volume.SizeRemaining
            $remaining = ($part / $whole * 100)
            Write-Output ""$volume.Driveletter": $([math]::Round($remaining, 0))%"
        }
    }
    
    if ($used) {
        foreach ($volume in $Drives) {
            $usednr = ($volume.Size - $volume.SizeRemaining)
            $usedp = ($usednr / $volume.Size * 100)
            Write-Output ""$volume.Driveletter": $([math]::Round($usedp, 0))%"
        }
    }  
    
    if ($max) {
        foreach ($volume in $drives) {
            $whole = $volume.Size/1gb
            Write-Output ""$volume.Driveletter": $([math]::Round($whole, 0))gb"
        }
    }
    
    if (-not ($free -or $used -or $max)) {
        Write-Output "Specify: 'free', 'used' or 'max'"
    }
}
catch {
    Write-Warning "No volumes with assigned driveletters found."
}