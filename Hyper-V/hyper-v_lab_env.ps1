Param (
	[switch]$Create-Env,
    [switch]$Create-Servers,
    [switch]$Delete-Servers,
	[Parameter(Mandatory = $false)][String]$Label
)

if (-not $Label) { $DiskLabel = "C" } else { $DiskLabel = $Label }
$Servers = @("dc-01", "dc-02", "dhcp-01", "dhcp-02", "fs-01", "router-01")
$VMLocation = "$DiskLabel:\Server Lab.Environment\Virtual Machines"
$ISOLocation = "$DiskLabel:\Server Lab.Environment\ISO Files\en-us_windows_server_2025_updated_july_2025_x64_dvd_a1f0681d.iso"
$VMStorageLocation = "$DiskLabel:\Server Lab.Environment\Virtual Machine Storage"

	function Create-Env {
		New-Item -Path "$DiskLabel:\Server Lab.Environment" -ItemType Directory
		New-Item -Path "$DiskLabel:\Server Lab.Environment\ISO Files" -ItemType Directory
		New-Item -Path "$DiskLabel:\Server Lab.Environment\Server Service Scripts" -ItemType Directory
		New-Item -Path "$DiskLabel:\Server Lab.Environment\Virtual Machines" -ItemType Directory
		New-Item -Path "$DiskLabel:\Server Lab.Environment\Virtual Machine Storage" -ItemType Directory
		Copy-Item -Path .\"en-us_windows_server_2025_updated_july_2025_x64_dvd_a1f0681d.iso" -Destination "$DiskLabel:\Server Lab.Environment\ISO Files"
		foreach ($server in $servers) { New-Item -Path "$DiskLabel:\Server Lab.Environment\Virtual Machines\$server" -ItemType Directory }
	}
	
	function Create-VMServers {
		foreach ($server in $servers) {
			New-VHD -Path "$VMStorageLocation\$server.vhdx" -Dynamic -SizeBytes 64GB
			New-VM -name "$server" -memorystartupbytes 4GB -Generation 2 -Path "$VMLocation\$server"
			Set-VM -name "$server" -ProcessorCount 8
			Add-VMHardDiskDrive -VMName "server" -Path "$VMStorageLocation\$server.vhdx"
			Add-VMDvdDrive -VMName "server" -Path "$ISOLocation"
			Set-VMProcessor -VMName "$server" -ExposeVirtualizationExtensions $true
			Set-VMFirmware -VMName "$server" -EnableSecureBoot On -FirstBootDevice $DVDDrive
			Add-VMNetworkAdapter -VMName "$server" -SwitchName "WLAN" | Set-VMNetworkAdapter -MacAddressSpoofing On
			Set-VMKeyProtector -VMName "$server" -NewLocalKeyProtector
			Enable-VMTPM -VMName "$server"
			Get-VM -VMName "$server" | Mount-VHD -Path "$VMStorageLocation\$server.vhdx" -passthru
		}
	}
	
	function Delete-VMServers {
		foreach ($server in $servers)
			Stop-VM -VMName "$server" -TurnOff -Force
			Get-VMHardDiskDrive -VMName "$server" -ControllerType SCSI | Remove-VMHardDiskDrive
			$TestVHDPath = Test-Path -path "$VMStorageLocation\$server.vhdx" -ErrorAction SilentlyContinue
			if ($TestVHDPath) { Remove-Item -Path $TestVHDPath -Force } else { continue }
			Remove-VM -name $server -Force
		}
	}
	
if ($Create-Servers) { Create-VMServers } if ($Delete-Servers) { Delete-VMServers } else { Create-Env }
