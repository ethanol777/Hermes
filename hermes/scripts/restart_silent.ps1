# Kill all gateway python processes
Get-Process python -ErrorAction SilentlyContinue | Where-Object { $_.CommandLine -match 'gateway' } | ForEach-Object { $_.Kill() }
Start-Sleep -Seconds 2

# Start silently with the real pythonw.exe via the .cmd script
Start-Process -FilePath 'C:\Users\77\AppData\Local\hermes\gateway-service\Hermes_Gateway.cmd' -WindowStyle Hidden

Write-Host 'Gateway restarted silently with real pythonw.exe'
