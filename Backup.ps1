$source = "C:\Scripts"
$destination = "C:\Users\danie\OneDrive\Dokument\PowerShell\Scripts"
$logg = "C:\Scriptloggar\Backup.txt"

try {
    Get-ChildItem -Path $source | Where-Object {$_.LastWriteTime -ge (Get-Date).AddDays(-7)} | Copy-Item -destination $destination
    Add-Content -Path $logg -Value "Säkerhetskopiering utförd av $source $(Get-Date)"
}
catch {
    Add-Content -Path $logg -Value "Säkerhetskopiering misslyckad av $source $(Get-Date)"
}

$filer = Get-ChildItem -Path $destination -File
foreach ($file in $filer) {
    attrib.exe +U -P $file.Fullname
}