#Collects hardware info.
$system = @()
$system += [PSCustomObject]@{
    "BIOS V." = (Get-CimInstance -Class Win32_BIOS).SMBIOSBIOSVersion
    "Processor" = (Get-CimInstance -Class Win32_Processor).Name
    "RAM manufacturer ID" = (Get-CimInstance -Class Win32_PhysicalMemory).PartNumber
    "Disk model" = (Get-CimInstance -Class Win32_DiskDrive).Model
    "Disk size" = (Get-CimInstance -Class Win32_DiskDrive).Size
}

Write-Output $system
