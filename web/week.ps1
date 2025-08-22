$Week = (Invoke-WebRequest -Uri "https://vecka.nu/" -SkipHeaderValidation).headers["x-week-number"]
Write-Host "Det är nu vecka $Week"
