#LAPS script to create a local admin user on Windows 10/11 devices.
#This script is intended to be run through Intune as a PowerShell script.

Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force
$UserName = "n0gv-admin"
$User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue

#Unsure if this is needed, but it doesn't hurt. It worked without it on my vm.
Add-Type -AssemblyName System.Web

if ($null -eq $User) {   
    #Creates a random password, don't worry, LAPS will catch it and store it in Entra ID.
    $Password = [System.Web.Security.Membership]::GeneratePassword(16, 2)
    $SecurePassword = ConvertTo-SecureString -String $Password -AsPlainText -Force

    New-LocalUser -Name $UserName -Password $SecurePassword -FullName "Local Admin" -Description "LAPS-managed administrator"
    
    $AdminGroup = Get-CimInstance -Class Win32_Group | Where-Object { $_.SID -eq "S-1-5-32-544" }
    Add-LocalGroupMember -Group $AdminGroup -Member $UserName
}

else {
    Write-Host "Local admin, $UserName, already exists." -ForegroundColor Yellow
}