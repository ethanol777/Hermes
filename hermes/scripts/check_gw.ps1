$procs = Get-CimInstance Win32_Process -Filter "Name='pythonw.exe' OR Name='python.exe'" | Where-Object { $_.CommandLine -match 'gateway' }
if ($procs) {
    Write-Host "Gateway running:"
    $procs | Select-Object ProcessId, Name, @{n='StartTime';e={$_.CreationDate}} | Format-Table -AutoSize
    Write-Host ""
    Write-Host "Processes:"
    $procs.Count
} else {
    Write-Host "Gateway NOT running"
}
