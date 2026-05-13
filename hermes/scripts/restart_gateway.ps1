Stop-ScheduledTask -TaskName Hermes_Gateway -ErrorAction SilentlyContinue
Start-ScheduledTask -TaskName Hermes_Gateway
Write-Host "Gateway restart triggered"
