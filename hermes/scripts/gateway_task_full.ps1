schtasks /Query /TN Hermes_Gateway /V /FO LIST 2>$null | ForEach-Object { Write-Host $_ }
