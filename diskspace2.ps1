param (
    [Switch]$free,
    [Switch]$used,
    [Switch]$max
)

$drives = Get-Volume | Where-Object {$_.Driveletter -ne $null}

foreach ($volume in $drives) {
    $everything = @()
    $whole = $volume.Size
    $part = $volume.SizeRemaining
    $remaining = ($part / $whole * 100)
    $usednr = ($volume.Size - $volume.SizeRemaining)
    $usedp = ($usednr / $volume.Size * 100)
    $wholegb = $volume.Size/1gb

    if ($free) {
        $everything += [PSCustomObject]@{
            "Driveletter" = $volume.Driveletter
            "Free drive capacity %" = $remaining
        }
            Write-Output $everything 
    }
    
    if ($used) {
        $everything += [PSCustomObject]@{
            "Driveletter" = $volume.Driveletter
            "Used drive capacity %" = $usedp
        }
            Write-Output $everything 
        }  
    
    if ($max) {
        $everything += [PSCustomObject]@{
            "Driveletter" = $volume.Driveletter
            "Drive max capacity" = $wholegb
        }
            Write-Output $everything 
    }
    
    if (-not ($free -or $used -or $max)) {

        $everything += [PSCustomObject]@{
            "Driveletter" = $volume.Driveletter
            "Drive max capacity" = $wholegb
            "Used drive capacity %" = $usedp
            "Free drive capacity %" = $remaining
        }
            Write-Output $everything 
    }
                   
}