Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$hostname = hostname
$sn = (Get-CimInstance -Class Win32_BIOS).SerialNumber
$cpu = (Get-CimInstance -Class Win32_Processor).Name
$Secureboot = Confirm-Securebootuefi
$TPMReady = Get-Tpm | Select-Object -ExpandProperty TpmReady
$TPMVersion = (Get-CimInstance -Namespace "Root\CIMV2\Security\MicrosoftTpm" -ClassName Win32_Tpm).SpecVersion
$ramSticks = (Get-CimInstance -Class Win32_PhysicalMemory).PartNumber
$ram = @(foreach ($ramstick in $ramsticks) { $ramStick })

$system = @([PSCustomObject]@{
	"Computer" = $hostname
    "Serialnumber" = $sn
    "Processor" = $cpu
    "RAM manufacturer ID 1" = $ram[0]
	"RAM manufacturer ID 2" = $ram[1]
	"TPM Readiness" = $TPMReady
	"TPM Version Support" = $TPMVersion
	"Secureboot" = $Secureboot
})

$testpath = Test-Path -path "$ENV:TEMP\$hostname.csv"
if ($testpath) {
	remove-item -path "$ENV:TEMP\$hostname.csv" -force
}

$system | Sort-Object "Hostname", "Serialnumber", "Processor", "Ram manufacturer ID 1", "Ram manufacturer ID 2", "TPM Readiness", "TPM Version Support", "Secureboot" | export-CSV -path "$ENV:TEMP\$hostname.csv" -delimiter ";" -NoTypeInformation

Move-Item -Path "$ENV:TEMP\$hostname.csv" -Destination "\\"