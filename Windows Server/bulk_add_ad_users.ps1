#CSV file must contain the following headers: Name;Company;Costcenter;Department;Title;Region

Param (
    [Parameter(Mandatory = $True)][string]$AB
)


$users = import-csv -path ".\users.csv" -Delimiter ";"


foreach ($user in $users) { 

    Write-Host "Attempting to create user $($user.Name)" -ForegroundColor Cyan

    $path = "OU=Users,OU=HS,DC=$AB,DC=loc"

    function Path {
        switch ($user.Company) {
            "$AB Sweden" { return "OU=$AB,OU=Sweden,$path" }
            "$AB Group" { return "OU=Group,OU=Sweden,$path" }
            "$AB Norway" { return "OU=$AB,OU=Norway,$path" }
            "$AB Finland" { return "OU=$AB,OU=Finland,$path" }
            "$AB Denmark" { return "OU=$AB,OU=Denmark,$path" }
            "$AB Estonia" { return "OU=$AB,OU=Estonia,$path" }
            "$AB Latvia" { return "OU=$AB,OU=Latvia,$path" }
            "$AB France" { return "OU=$AB,OU=France,$path" }
            "$AB Romania" { return "OU=$AB,OU=Romania,$path" }
            "$AB Czech" { return "OU=$AB,OU=Czech,$path" }
            "$AB United Kingdom" { return "OU=$AB,OU=United Kingdom,$path" }
        }
    }

    function Complete-Suffix {
        switch ($user.Company){
            "$AB Sweden" { return "$AB.se" }
            "$AB Group" { return $AB + "group.com" }
            "$AB Norway" { return "$AB.no" }
            "$AB Finland" { return "$AB.fi" }
            "$AB Denmark" { return "$AB.dk" }
            "$AB Estonia" { return "$AB.ee" }
            "$AB Latvia" { return "$AB.lv" }
            "$AB France" { return "$AB.fr" }
            "$AB Romania" { return "$AB.ro" }
            "$AB Czech" { return "$AB.cz" }
            "$AB United Kingdom" { return "$AB.co.uk" }
        }
    }

    function SamAccount {

        $first = ($User.name -split ' ')[0]
        $last = ($User.name -split ' ')[-1]
        $sam = $first.Substring(0,3) + $last.Substring(0,2)

        try {
            $trysam = Get-AdUser -Identity $sam -ErrorAction Stop
        if ($user) {
            $f = 3
            $l = 2
            While ($trysam) {
                $f--
                $l++
                $sam = $first.Substring(0,$f) + $last.Substring(0,$l)
                try {
                    $trysam = Get-AdUser -Identity $sam -ErrorAction Stop
                }
                catch {
                    return $sam
                }
            }
        } } catch {
            return $sam
        }
    }


    New-ADUser `
        -Name $user.Name `
        -GivenName ($user.Name -split ' ')[0] `
        -Surname ($user.Name -split ' ')[-1] `
        -Path (Path) `
        -SamAccountName (SamAccount).ToLower() `
        -Email (($user.Name -split ' ')[0] + "." + ($user.Name -split ' ')[-1] + "@" + (Complete-Suffix)).ToLower() `
        -UserPrincipalName (($user.Name -split ' ')[0] + "." + ($user.Name -split ' ')[-1] + "@" + (Complete-Suffix)).ToLower() `
        -Company $user.Company `
        -Description $user.Costcenter `
        -Department $user.Department `
        -Title $user.Title `
    
    try {
        $trysam = Get-Aduser -filter "name -eq '$($user.Name)'" -ErrorAction Stop
        if ($trysam) {
            Write-Host "User $($user.Name) created successfully" -ForegroundColor Green
        } else {
            Write-Host "Failed to create user $($user.Name)" -ForegroundColor Red
        }
    } catch {
        Write-Warning "Could not verify creation of user $($user.Name)"
    }
}