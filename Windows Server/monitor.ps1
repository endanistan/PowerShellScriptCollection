$Svrs = @(
    "dc-01.n0gv.loc",
    "dc-02.n0gv.loc",
    "dhcp-01.n0gv.loc",
    "dhcp-02.n0gv.loc",
    "fs-01.n0gv.loc"
)

While ($true) { 
    Clear-Host
    Write-Host "Checking server status..." -ForegroundColor Yellow
    Start-Sleep -Seconds 2

    Foreach ($Svr in $Svrs) {
        Write-Host "Checking $Svr..." -ForegroundColor Cyan
        Start-Sleep -Seconds 1
    }
        $state = Test-Connection -ComputerName $Svr -Count 1 -Quiet
        $Svrs | ForEach-Object {
            $state = Test-Connection -ComputerName $_ -Count 1 -Quiet
            if ($state) { 
                Write-Host $_ "- Online" -ForegroundColor Green
            } 
                else {
                    Write-Host $_ "- Offline" -ForegroundColor Red
                }
        }
            $Date = Get-Date -Format "dd.MM.yyyy HH:mm:ss"
            Write-Host "All servers was checked at $Date" -ForegroundColor Yellow
            Write-Host "Next check in 60 seconds..." -ForegroundColor Magenta
            Start-Sleep -Seconds 30
            Write-Host "Next check in 30 seconds..." -ForegroundColor Magenta
            Start-Sleep -Seconds 27
            Write-Host "Next check in 3 seconds..." -ForegroundColor Magenta
            Start-Sleep -Seconds 3
}
