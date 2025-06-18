#LAPS script to create a local admin user on Windows 10/11 devices.
#This script is intended to be run through Intune as a Platform Script.
#"Run this script using the logged on credentials" and "Enforce script signature check" should both be set to "No"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

$log = "$ENV:TEMP\laps.log"
Start-Transcript -Path $log -Append

Write-Host "Initiating laps script..."

$UserName = "local-admin"
$User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

if ($null -eq $User) {   
    #Creates a random password, don't worry, LAPS will catch it and store it in Entra ID.
    $Password = -join ((48..57) + (65..90) + (97..122) | Get-Random -Count 16 | % { [char]$_ })
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    New-LocalUser -Name $UserName -Password $SecurePassword -FullName "Local Admin" -Description "LAPS-managed administrator"

    $AdminGroup = (Get-CimInstance -Class Win32_Group | Where-Object { $_.SID -eq "S-1-5-32-544" }).Name

    $AdminInGroup = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName" } -ErrorAction SilentlyContinue
    if ($AdminInGroup -like "*$UserName") {
        Write-Host "Local admin, $UserName, already exists in the local administrators group." #This line should realistically never be reached.
    }
    else {
        $User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
        if ($User) {
                Add-LocalGroupMember -Group $AdminGroup -Member $UserName 
        }
    }
}

else {
    Write-Host "Local admin, $UserName, already exists."
}


$AdminInGroup = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName" } -ErrorAction SilentlyContinue
if ($AdminInGroup -like "*$UserName") {
    Write-Host "Local admin, $UserName, exists and is a member of the local administrators group."
}
else {
    Write-Host "ERROR: Local admin, $UserName, is NOT part of the administrators group" #If this line is reached, start looking at line 22.
}

Stop-Transcript
