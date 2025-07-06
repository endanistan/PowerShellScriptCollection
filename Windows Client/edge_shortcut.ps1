#Append paths based on your environment
$edgeSource= "C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
$desktopPath = "$ENV:ONEDRIVE\Desktop\Microsoft Edge.lnk"
$WScriptObj = New-Object -ComObject ("WScript.Shell")
$shortcut = $WScriptObj.CreateShortcut($desktopPath)
$shortcut.TargetPath = $edgeSource
$shortcut.Save()