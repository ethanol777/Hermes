$action = New-ScheduledTaskAction -Execute "C:\Users\77\AppData\Local\hermes\start-gateway.vbs"
$trigger = New-ScheduledTaskTrigger -AtLogOn -User "77"
$settings = New-ScheduledTaskSettingsSet -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -StartWhenAvailable
$principal = New-ScheduledTaskPrincipal -UserId "77" -LogonType Interactive -RunLevel Limited
Register-ScheduledTask -TaskName "HermesGateway" -Action $action -Trigger $trigger -Settings $settings -Principal $principal -Force
Write-Host "Created scheduled task: HermesGateway"
