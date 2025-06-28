Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$log = "$ENV:TEMP\clock.log"
Start-Transcript -Path $log -Append 
Write-Host "Initiating clock script..."

$w32tm = Get-Service w32time | select-object -property status
if ($w32tm.Status -eq "stopped") {
    Start-Service w32time
    #Märkte att det tar ett par sekunder innan tjänsten koppar upp sig mot NTP-servern. Om man är för snabb så svarar den med cmos, ovs.
    Write-Host "Waiting for w32time service to start..."
    Start-Sleep -Seconds 10
}
else {
    continue
}


$currentsource = w32tm /query /source
if ($currentsource -like "*cmos*") {
    Write-Host "Clock set to  CMOS, setting to NTP source..."
    w32tm /config /update /manualpeerlist:"pool.ntp.org time.google.com"
    w32tm /resync
    #Samma som ovan, det tar ett par sekunder innan den har synkat med NTP-servern.
    Write-Host "Waiting for w32time to sync with NTP server..."
    Start-Sleep -seconds 10
}
else {
    Write-Host "Current NTP source is: $currentsource"
}

$newsource = w32tm /query /source
Write-Host "Old source: $currentsource"
Write-Host "New source: $newsource"

Stop-Transcript