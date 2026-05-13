# Test silent startup via .cmd script
Write-Host "Testing Hermes_Gateway.cmd silent startup..."
$p = Start-Process -FilePath 'C:\Users\77\AppData\Local\hermes\gateway-service\Hermes_Gateway.cmd' -WindowStyle Hidden -PassThru
Start-Sleep -Seconds 3

# Check if pythonw.exe gateway processes exist
$gw = Get-CimInstance Win32_Process -Filter "Name='pythonw.exe'" | Where-Object { $_.CommandLine -match 'gateway' }
if ($gw) {
    Write-Host "PASS - Gateway running silently, no window popup"
    $gw | Select-Object ProcessId, @{n='ExeSize';e={(Get-Item $_.ExecutablePath).Length}} | Format-Table -AutoSize
} else {
    Write-Host "FAIL - No pythonw.exe gateway process found"
}
