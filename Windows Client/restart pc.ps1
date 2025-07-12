#Not ideal; Just a fun possible solution for an end user who ran into pc issue because they never turned off their pc.
$log = "$ENV:TEMP\task_restart.log"
test-path $log
if ($log) {
remove-item -path $log
}

Start-Transcript -path $log

$upTime = (Get-Date) - (gcim Win32_OperatingSystem).LastBootUpTime
if ($upTime.TotalHours -ge 36) {
    $restartHour = Get-Date -Hour 3 -Minute 0 -Second 0
    $correctRestartHour = $restartHour.AddDays(1)
    $timeNow = Get-Date
    $whenToRestart = $correctRestartHour - $timeNow
    $inSeconds = [Math]::Round($whenToRestart.TotalSeconds)
    shutdown /r /t $inSeconds
    Write-Host "Restart was scheduled for $correctRestartHour"
}
else {
    Write-Host "Restart not scheduled"
}

Stop-Transcript
