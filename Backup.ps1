param (
    [Parameter(Mandatory = $true)][String]$source,
    [Parameter(Mandatory = $true)][String]$destination,
    [Parameter(Mandatory = $false)][String]$logg
)  


try {
    Get-ChildItem -Path $source | Where-Object {$_.LastWriteTime -ge (Get-Date).AddDays(-7)} | Copy-Item -destination $destination
    
    if ($logg) {
        Add-Content -Path $logg -Value "Säkerhetskopiering utförd av $source $(Get-Date)"
    }
    else {
       Write-Output "Säkerhetskopiering utförd av $source" 
    }
}
catch {
    if ($logg) {
        Add-Content -Path $logg -Value "Säkerhetskopiering misslyckad av $source $(Get-Date)"
    }
    else {
       Write-Output "Säkerhetskopiering misslyckad av $source" 
    }
}

try {
    $filer = Get-ChildItem -Path $destination -File
    foreach ($file in $filer) {
        attrib.exe +U -P $file.Fullname
    }
        
    if ($logg) {
            Add-Content -Path $logg -Value "$source säkerhetskopering ligger endast i OneDrive-moln $(Get-Date)"
        }
        else {
            Write-Output "$source säkerhetskopering ligger endast i OneDrive-moln" 
        } 
}
catch {
    if ($logg) {
        Add-Content -Path $logg -Value "Filer har inte frigjorts. Om de inte har säkerhetskopierat till OneDrive kan du ignorera detta meddelande. $(Get-Date)"
    }
    else {
        Write-Output "Filer har inte frigjorts. Om de inte har säkerhetskopierat till OneDrive kan du ignorera detta meddelande."
    } 
}