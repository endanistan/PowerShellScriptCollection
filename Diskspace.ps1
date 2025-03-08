$Drives = Get-Volume | Where-Object {$_.Driveletter -ne $null}
Foreach ($volume in $Drives) {
    $whole = $volume.Size
    $part = $volume.SizeRemaining
    $Remaining = ($part / $whole * 100)
    Write-Output ""$volume.Driveletter": $([math]::Round($Remaining, 0))%"
    }    