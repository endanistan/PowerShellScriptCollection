
Begin {


    $temp = $env:TEMP
    $LogFile = Join-Path -Path $temp -ChildPath "system_info.csv"
    $LogFile2 = Join-Path -Path $temp -ChildPath "disk_info.csv"
    $LogFile3 = Join-Path -Path $temp -ChildPath "memory_info.csv"


}


    Process {


        $Serial = (Get-CimInstance -Class Win32_BIOS).SMBIOSBIOSVersion
        $Processor = (Get-CimInstance -Class Win32_Processor).Name

            $SystemInfo = @()
            $SystemInfo += [PSCustomObject]@{
                "BiosVersion" = $Serial
                "Processor" = $Processor
            }
        
            $MemoryInfo = @()
            $Memory = (Get-CimInstance -Class Win32_PhysicalMemory)
                Foreach ($CimInstance in $Memory) {
                    $MemoryInfo += [PSCustomObject]@{
                        "ManufactureID" = $CimInstance.PartNumber
                    }
                }
        
                $DiskInfo = @()
                $Disk = (Get-CimInstance -Class Win32_DiskDrive)
                    Foreach ($CimInstance in $Disk) {
                        $DiskInfo += [PSCustomObject]@{
                            "Model" = $CimInstance.Model
                            "Size" = $CimInstance.Size
                        }
                    }


                    $SystemInfo | export-Csv -Path $LogFile -NoTypeInformation
                    $DiskInfo | export-Csv -Path $LogFile2 -NoTypeInformation
                    $MemoryInfo | export-Csv -Path $LogFile3 -NoTypeInformation
                

    }


        End {


            Write-Output "Output logged into $logfile $logfile2 $logfile3"


        }