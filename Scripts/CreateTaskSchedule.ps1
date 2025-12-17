$action = New-ScheduledTaskAction -Execute "$PSScriptRoot\Fallback2Remove.exe"
$trigger = New-ScheduledTaskTrigger -AtLogOn
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries
Register-ScheduledTask -Action $action -Trigger $trigger -Settings $settings -TaskName "Fallback2Remove" -Description "Starts Fallback2Remove on Login" -Force
Write-Host "Startup task created successfully!" -ForegroundColor Green
