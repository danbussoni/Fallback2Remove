# Script to create a physical shortcut in the Windows Startup folder
$TargetFile = "$PSScriptRoot\Fallback2Remove.exe"
$ShortcutPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs\Startup\Fallback2Remove.lnk"

$WshShell = New-Object -ComObject WScript.Shell
$Shortcut = $WshShell.CreateShortcut($ShortcutPath)
$Shortcut.TargetPath = $TargetFile
$Shortcut.WorkingDirectory = "$PSScriptRoot\..\Source\"
$Shortcut.Description = "Starts Fallback2Remove on Login"
$Shortcut.Save()

Write-Host "Shortcut created at: $ShortcutPath" -ForegroundColor Green
