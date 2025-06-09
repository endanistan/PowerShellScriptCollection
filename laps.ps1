#LAPS script to create a local admin user on Windows 10/11 devices.
#This script is intended to be run through Intune as a Platform Script.
#"Run this script using the logged on credentials" and "Enforce script signature check" should be set to "No"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$log = "$ENV:TEMP\laps.log"
Start-Transcript -Path "$log" -Append

Get-Date
Write-Host "Initiating laps script..."

$UserName = "local-admin"
$User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

#Unsure if this is needed, but it doesn't hurt. It worked without it on my vm.
Add-Type -AssemblyName System.Web

if ($null -eq $User) {   
    #Creates a random password, don't worry, LAPS will catch it and store it in Entra ID.
    $Password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | % { [char]$_ })
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    try {
        New-LocalUser -Name $UserName -Password $SecurePassword -FullName "Local Admin" -Description "LAPS-managed administrator"
    }
    catch {
        Write-Host "Failed to create local admin, $UserName. Error: $_" -ForegroundColor Red
    }
    $AdminGroup = (Get-CimInstance -Class Win32_Group | Where-Object { $_.SID -eq "S-1-5-32-544" }).Name
    $AdminInGroup = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName*" } -ErrorAction SilentlyContinue

    if ($AdminInGroup -like "*$UserName*") {
        Write-Host "Local admin, $UserName, already exists in the local administrators group." -ForegroundColor Yellow
    }
    else {
        $User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
        if ($User) {
            try {
                Add-LocalGroupMember -Group $AdminGroup -Member $UserName 
            }
            catch {
                Write-Host "Local admin, $UserName, could not be added into $AdminGroup." -ForegroundColor Red
            }
        }
        else {
        Write-Host "Failed to create local admin, $UserName." -ForegroundColor Red
        }
    }
}
else {
    Write-Host "Local admin, $UserName, already exists." -ForegroundColor Yellow
}

$AdminInGroup = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName*" } -ErrorAction SilentlyContinue
if ($AdminInGroup -like "*$UserName*") {
    Write-Host "Local admin, $UserName, is a member of the local administrators group." -ForegroundColor Green
}
else {
    Write-Host "ERROR: Local admin, $UserName, is NOT part of the administrators group" -ForegroundColor Red
}

Stop-Transcript
