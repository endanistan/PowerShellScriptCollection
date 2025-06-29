#LAPS script to create a local admin user on Windows 10/11 devices.
#This script is intended to be run through Intune as a Platform Script.
#"Run this script using the logged on credentials" and "Enforce script signature check" should both be set to "No"

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force

function GeneratePassword {
    $letterNumberArray = @('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*')
    for (($counter = 0); $counter -lt 20; $counter++) {
        $randomCharacter = get-random -InputObject $letterNumberArray
        $randomString = $randomString + $randomCharacter
    }
    return $randomString
}

$log = "$ENV:TEMP\laps.log"
Start-Transcript -Path $log -Append

Write-Host "Initiating laps script..."

$Password = GeneratePassword
$SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force
$UserName = "local-admin"
$AdminGroup = (Get-CimInstance -Class Win32_Group | Where-Object { $_.SID -eq "S-1-5-32-544" }).Name
$User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

if ($null -eq $User) {
    Write-Host "Creating local admin user: $UserName"
    New-LocalUser -Name $UserName -Password $SecurePassword -FullName "Laps Admin" -Description "LAPS-managed administrator"
}
else {
    Write-Host "Local admin, $UserName, already exists."
}


$AdminInGroup = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName" } -ErrorAction SilentlyContinue
if ($AdminInGroup) {
    Write-Host "Local admin, $UserName, already exists in the local administrators group." #This line should realistically never be reached.
    Break
}
else {
    $User2 = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
    if ($User2) {
        Write-Host "Adding local admin, $UserName, to the local administrators group."
        Add-LocalGroupMember -Group $AdminGroup -Member $UserName 
    }
}


$AdminInGroupExit = Get-LocalGroupMember -Group $AdminGroup | Where-Object { $_.Name -like "*$UserName" } -ErrorAction SilentlyContinue
if ($AdminInGroupExit -like "*$UserName") {
    Write-Host "Local admin, $UserName, exists and is a member of the local administrators group."
}
else {
    Write-Host "ERROR: Local admin, $UserName, is NOT part of the administrators group" #If this line is reached, start looking at line 24.
}

Stop-Transcript
