function PasswordReset {
    Param (
        [Parameter(Mandatory = $false)][String]$easyToType,
        [Parameter(Mandatory = $false)][String]$random
    )

    $adjectives = @("Ferocious", "Sabertoothed", "Maneating", "Bloodthirsty", "Vengeful", "Merciless", "Warthful", "Hellbound", "Soulharvesting", "Crazed", "Bleesed", "Flesheating")
    $nouns = @("Goldfish", "Froglet", "Bumblebee", "Pig", "Capybara", "Toad", "Rabbit", "Lamb", "Crab", "Shrimp", "Starfish")
    $numbers = @("1", "2", "3", "4", "5", "6", "7", "8", "9", "0")
    $characters = @("#", "%", "!", "?", "+", "\", "*", "$", "/")
    $letterNumberArray = @('a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 'y', 'z', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z', '1', '2', '3', '4', '5', '6', '7', '8', '9', '0', '!', '@', '#', '$', '%', '^', '&', '*')
    
    if ($random) {
        for (($counter = 0); $counter -lt 20; $counter++) {
        $randomCharacter = get-random -InputObject $letterNumberArray
        $randomString = $randomString + $randomCharacter
        }
        return $randomString
    }

    if ($easyToType) {
        $randomAdjective = get-random -InputObject $adjectives
        $randomNoun = get-random -InputObject $nouns
        $randomNumber = get-random -InputObject $numbers
        $randomCharacter = get-random -InputObject $characters
        $randomEasyToType = "$randomAdjective" + "$randomNoun" + "$randomNumber" + "$randomCharacter"
        return $randomEasyToType
    }
}

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing
$form = New-Object System.Windows.Forms.Form
$form.Text = "One-Time Password"
$form.Width = 400
$form.Height = 200

$label = New-Object System.Windows.Forms.Label
$label.Text = "Multifunctional passwordgenerator tool for lazy support technicians"
$label.AutoSize = $true
$label.Location = [System.Drawing.Point]::new(10,10)
$form.Controls.Add($label)

$button = New-Object System.Windows.Forms.Button
$button.Text = "Generate"
$button.Width = 100
$button.Location = [System.Drawing.Point]::new(10,50)
$form.Controls.Add($button)

$copybutton = New-Object System.Windows.Forms.Button
$copybutton.Text = "Copy"
$copybutton.Width = 75
$copybutton.Location = [System.Drawing.Point]::new(220,90)
$form.Controls.Add($copybutton)

$textbox = New-Object System.Windows.Forms.TextBox
$textbox.Width = 200
$textbox.Location = [System.Drawing.Point]::new(10,90)
$textbox.ReadOnly = $true
$form.Controls.Add($textbox)

$comboBox = New-Object System.Windows.Forms.ComboBox
$comboBox.Location = [System.Drawing.Point]::new(120, 50)
$comboBox.Width = 150
$comboBox.DropDownStyle = 'DropDownList'
$comboBox.Items.AddRange(@("Easy to type", "Random"))
$comboBox.SelectedIndex = 0
$form.Controls.Add($comboBox)

$button.Add_Click({
    $choice = $comboBox.SelectedItem
    switch ($choice) {
        "Easy to type" { $textbox.Text = PasswordReset -easyToType "yes" }
        "Random" { $textbox.Text = PasswordReset -random "yes" }
        default { $textbox.Text = "" }
    }
})

$copybutton.Add_Click({
    Set-Clipboard -value $textbox.Text
})

[void] $form.ShowDialog()