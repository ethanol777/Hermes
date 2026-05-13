$p = Start-Process -FilePath 'C:\Users\77\AppData\Local\hermes\gateway-service\Hermes_Gateway.cmd' -WindowStyle Hidden -PassThru -ErrorAction Stop
Start-Sleep -Seconds 3
if (!$p.HasExited) {
    Write-Host 'OK - no window popup, process runs silently'
    $p.Kill()
} else {
    Write-Host 'Exit code:' $p.ExitCode
}
