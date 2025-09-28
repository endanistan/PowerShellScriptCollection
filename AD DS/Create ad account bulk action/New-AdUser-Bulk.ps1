param (
    [Parameter(Mandatory = $true)][String]$CSVPath
)

function UserPassword {
    $Adjectives = @("Ferocious", "Sabertoothed", "Maneating", "Bloodthirsty", "Vengeful", "Merciless", "Wrathful", "Hellbound", "Soulharvesting", "Crazed", "Blessed", "Flesheating")
    $Nouns = @("Goldfish", "Froglet", "Bumblebee", "Pig", "Capybara", "Toad", "Rabbit", "Lamb", "Crab", "Shrimp", "Starfish")
    $Numbers = @("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    $Characters = @("#", "%", "!", "?", "+", "\", "*", "$", "/")
    $RandomAdjective = Get-Random $Adjectives
    $RandomNoun = Get-Random $Nouns
    $RandomNumber = Get-Random $Numbers
    $RandomCharacter = Get-Random $Characters
    $RandomEasyToType = -join ($RandomAdjective, $RandomNoun, $RandomNumber, $RandomCharacter)
    return $RandomEasyToType
}


Import-Csv -Path $CSVpath -Delimiter ";" | ForEach-Object {
    $password = UserPassword
    $splat = @{
        Name              = $_.DisplayName
        DisplayName       = $_.DisplayName
        GivenName         = ($_.DisplayName.Split(' ')[0])
        Surname           = ($_.DisplayName.Split(' ')[-1])
        SamAccountName    = $_.sam
        Description       = $_.Description
        Path              = $_.Path
        Company           = $_.Company
        EmailAddress      = $_.UserPrincipalName
        UserPrincipalName = $_.UserPrincipalName
        Title             = $_.Title
        StreetAddress     = $_.Street
        PostalCode        = $_.Zip
        City              = $_.City
        Office            = $_.City
    }

    $dn = $_.DisplayName

    try {
        Write-Host "Attempting to creat user '$dn'..."
        New-ADUser @splat -AccountPassword (ConvertTo-SecureString $password -AsPlainText -Force) `
            -Enabled $true `
            -ChangePasswordAtLogon $true `
            -ErrorAction Stop

    } catch {
        Write-Error -Message "Unknown error creating aduser '$dn'"
    }

    try {
        $CheckUser = Get-Aduser -identity $_.sam -ErrorAction Stop
        if ($CheckUser) {
            Write-Host "Confirmed creation of '$dn' with password '$password'"
        } else {
            Write-Host "Could not confirm creation of '$dn'"
        }
    } catch {
        Write-Error -Message "Could not confirm creation of '$dn'"
    }
}
