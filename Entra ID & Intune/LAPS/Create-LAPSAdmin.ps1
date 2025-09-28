#LAPS script to create a local admin user on Windows 10/11 devices.
#This script is intended to be run through Intune as a Platform Script.
#"Run this script using the logged on credentials" and "Enforce script signature check" should both be set to "No"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$log = "$ENV:TEMP\laps.log"
Start-Transcript -Path $log -Append

Write-Host "Initiating laps script..."

$SecurePassword = (ConvertTo-SecureString -String "rN8zFT6O3C$^L*P09u" -AsPlainText -Force)
$UserName = "LAPSAdmin"
$AdminGroup = (Get-CimInstance -Class Win32_Group | Where-Object { $_.SID -eq "S-1-5-32-544" }).Name
$User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

if ($null -eq $User) {
    Write-Host "Creating local admin user: $UserName"
    New-LocalUser -Name $UserName -Password $SecurePassword -FullName "Laps Admin" -Description "LAPS-managed administrator"
} else {
    Write-Host "Local admin, $UserName, already exists."
}


$AdminInGroup = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName" } -ErrorAction SilentlyContinue
if ($AdminInGroup) {
    Write-Host "Local admin, $UserName, already exists in the local administrators group." #This line should realistically never be reached.
    break
} else {
    $User2 = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    if ($User2) {
        Write-Host "Adding local admin, $UserName, to the local administrators group."
        Add-LocalGroupMember -Group $AdminGroup -Member $UserName
    }
}


$AdminInGroupExist = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName" } -ErrorAction SilentlyContinue
if ($AdminInGroupExist -like "*$UserName") {
    Write-Host "Local admin, $UserName, exists and is a member of the local administrators group."
} else {
    Write-Host "ERROR: Local admin, $UserName, is NOT part of the administrators group" #If this line is reached, start looking at line 24.
}

Stop-Transcript
