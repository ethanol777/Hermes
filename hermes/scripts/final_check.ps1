Write-Host "=== Checking Gateway Status ==="
Write-Host ""
Write-Host "--- pythonw.exe processes ---"
$gw = Get-CimInstance Win32_Process -Filter "Name='pythonw.exe'" | Where-Object { $_.CommandLine -match 'gateway' }
if ($gw) {
    $gw | Select-Object ProcessId, @{n='StartTime';e={$_.CreationDate}} | Format-Table -AutoSize
} else {
    Write-Host "None found"
}
Write-Host ""
Write-Host "--- python.exe gateway processes ---"
$pg = Get-CimInstance Win32_Process -Filter "Name='python.exe'" | Where-Object { $_.CommandLine -match 'gateway' }
if ($pg) {
    $pg | Select-Object ProcessId, @{n='StartTime';e={$_.CreationDate}} | Format-Table -AutoSize
} else {
    Write-Host "None found"
}
Write-Host ""
Write-Host "--- Last 3 log lines ---"
Get-Content 'C:\Users\77\AppData\Local\hermes\logs\gateway.log' -Tail 3
Write-Host ""
Write-Host "--- Scheduled Task ---"
schtasks /Query /TN Hermes_Gateway /V /FO LIST 2>$null | Select-String 'TaskName|Status|Schedule Type|Scheduled Task State'
