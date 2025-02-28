$tröskel = 80
$loggfil = "C:\Scriptloggar\diskhealth.csv"
$loggfil2 = "C:\Scriptloggar\diskhealth.txt"
$varning = "C:\Users\danie\Desktop\Diskvarning.txt"
$volyminfo = @()


try {
    $volumes = Get-Volume  
}
catch {
    Add-Content -Path $loggfil2 -Value "Kunde inte hämta Volym information. $(Get-Date)"
}


try {
    foreach ($volume in $volumes) {
        if ($null -ne $volume.DriveLetter) {
        $använtutrymme = $volume.Size - $volume.SizeRemaining
        $procentvärde = ($använtutrymme / $volume.Size) * 100

        Write-Output "Volym: $($volume.DriveLetter)"
        Write-Output "Använt utrymme: $([math]::Round($använtutrymme/1GB, 0)) GB"
        Write-Output "Total storlek: $([math]::Round($volume.Size/1GB, 0)) GB"
        Write-Output "Använt procent: $([math]::Round($procentvärde, 0))%"
     

            $volyminfo += [pscustomobject]@{
                "Bokstav" = $volume.DriveLetter
                "Total storlek(GB)" = [math]::Round($volume.Size/1GB, 0)
                "Använt utrymme(GB)" = [math]::Round($volume.SizeRemaining/1GB, 0)
                "Använt procent(%)" = [math]::Round($procentvärde, 0)
            }
        }
    }
}
catch {
    Add-Content -Path $loggfil2 -Value "Volyminformation kunde inte sparas i array. $(Get-Date)"
}



if ($procentvärde -ge $tröskel) {
    Add-Content -Path $varning -Value "En eller flera diskar nästan full(a). $(Get-Date)"
}
else {
    Write-Output "Tillfredställande mängd diskutrymme"
}


try {
    $volymInfo | Export-Csv -Path $loggfil -NoTypeInformation
    Add-Content -Path $loggfil -value "$(Get-Date)"
    Add-Content -Path $loggfil2 -Value "Diskanalys genomförd. $(Get-Date)"
}
catch {
    Add-Content -Path $loggfil2 -Value ".csv Fil kunde inte sparas. $(Get-Date)"
}