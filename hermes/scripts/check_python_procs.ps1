Get-CimInstance Win32_Process -Filter "Name='python.exe' OR Name='pythonw.exe'" | Select-Object ProcessId, Name, CommandLine, CreationDate | Format-Table -AutoSize -Wrap
