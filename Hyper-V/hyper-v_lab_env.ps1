#largely untested and WIP
Param (
	[switch]$CreateEnv,
    [switch]$CreateServers,
    [switch]$DeleteServers,
	[Parameter(Mandatory = $false)][String]$Label
)

if (-not $Label) { $DiskLabel = "C" } else { $DiskLabel = $Label }
$Servers = @("dc-01", "dc-02", "dhcp-01", "dhcp-02", "fs-01", "router-01")
$VMLocation = "${DiskLabel}:\Server Lab.Environment\Virtual Machines"
$ISOLocation = "${DiskLabel}:\Server Lab.Environment\ISO Files\26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso"
$VMStorageLocation = "${DiskLabel}:\Server Lab.Environment\Virtual Machine Storage"

	function Create-Env {
		New-Item -Path "${DiskLabel}:\Server Lab.Environment" -ItemType Directory
		New-Item -Path "${DiskLabel}:\Server Lab.Environment\ISO Files" -ItemType Directory
		New-Item -Path "${DiskLabel}:\Server Lab.Environment\Virtual Machines" -ItemType Directory
		New-Item -Path "${DiskLabel}:\Server Lab.Environment\Virtual Machine Storage" -ItemType Directory
		Copy-Item -Path .\"26100.1742.240906-0331.ge_release_svc_refresh_SERVER_EVAL_x64FRE_en-us.iso" -Destination "${DiskLabel}:\Server Lab.Environment\ISO Files"
		foreach ($server in $servers) { New-Item -Path "${DiskLabel}:\Server Lab.Environment\Virtual Machines\$server" -ItemType Directory }
	}
	
	function Create-VMServers {
		foreach ($server in $servers) {
			New-VHD -Path "$VMStorageLocation\$server.vhdx" -Dynamic -SizeBytes 64GB
			New-VM -name "$server" -memorystartupbytes 4GB -Generation 2 -Path "$VMLocation\$server"
			Set-VM -name "$server" -ProcessorCount 8
			Add-VMHardDiskDrive -VMName "$server" -Path "$VMStorageLocation\$server.vhdx"
			Add-VMDvdDrive -VMName "$server" -Path "$ISOLocation"
			Set-VMProcessor -VMName "$server" -ExposeVirtualizationExtensions $true
			$fw  = Get-VMFirmware -VMName $server
			$DVDBoot = $fw.BootOrder | Where-Object { $_.FirmwarePath -like "*scsi(0,1)*" }
			Set-VMFirmware -VMName $server -EnableSecureBoot On -FirstBootDevice $DVDBoot
			Add-VMNetworkAdapter -VMName "$server" -SwitchName "WLAN" | Set-VMNetworkAdapter -MacAddressSpoofing On
			Set-VMKeyProtector -VMName "$server" -NewLocalKeyProtector
			Enable-VMTPM -VMName "$server"
		}
	}
	
	function Delete-VMServers {
		foreach ($server in $servers) {
			Stop-VM -VMName "$server" -TurnOff -Force
			Get-VMHardDiskDrive -VMName "$server" -ControllerType SCSI | Remove-VMHardDiskDrive
			$TestVHDPath = Test-Path -path "$VMStorageLocation\$server.vhdx" -ErrorAction SilentlyContinue
			if ($TestVHDPath) { Remove-Item -Path $TestVHDPath -Force } else { continue }
			Remove-VM -name $server -Force
		}
	}
	
if ($CreateServers) {
Create-VMServers 
}

if ($DeleteServers) {
Delete-VMServers 
}

if ($CreateEnv) {
Create-Env 
}


