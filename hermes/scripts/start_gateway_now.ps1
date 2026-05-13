# Kill any running gateway python processes
taskkill /F /IM pythonw.exe /FI "WINDOWTITLE eq *gateway*" 2>$null
taskkill /F /IM python.exe /FI "WINDOWTITLE eq *gateway*" 2>$null
Start-Sleep -Seconds 2

# Start the gateway using the scheduled task .cmd file
Write-Host "Starting gateway from cmd script..."
Start-Process -FilePath "C:\Users\77\AppData\Local\hermes\gateway-service\Hermes_Gateway.cmd" -WindowStyle Hidden
Write-Host "Gateway started (hidden window)"
