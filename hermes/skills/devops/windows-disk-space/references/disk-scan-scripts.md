# Disk Scan PowerShell Scripts

Proven scripts for scanning Windows disk space from git-bash/MSYS2.

## Usage

Write these to a `.ps1` file (e.g. via the agent's `write_file` tool), then run:

```bash
powershell.exe -ExecutionPolicy Bypass -File C:\path\to\script.ps1
```

## Script 1: Top-level directory sizes

Write with **English-only content** to avoid PowerShell encoding issues.

```powershell
$ErrorActionPreference = "SilentlyContinue"
$target = "D:\"

Get-ChildItem $target -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    if ($size -gt 0) {
        "$([math]::Round($size/1GB,2)) GB`t$($_.Name)"
    }
} | Sort-Object -Descending
```

## Script 2: Drill into a specific directory's subfolders

```powershell
$ErrorActionPreference = "SilentlyContinue"
$dir = "D:\SomeLargeDirectory"

Get-ChildItem $dir -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    if ($size -gt 0) {
        $g = [math]::Round($size/1GB, 2)
        if ($g -gt 0.3) { "$g GB`t$($_.Name)" }
    }
} | Sort-Object -Descending
```

## Script 3: Find large files in a directory

```powershell
$ErrorActionPreference = "SilentlyContinue"
$dir = "D:\TargetDir"

Get-ChildItem $dir -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 200MB } |
    Sort-Object Length -Descending |
    Select-Object -First 30 |
    ForEach-Object { "$([math]::Round($_.Length/1GB,2)) GB  $($_.FullName)" }
```

## Script 4: C: drive scan (system files + profile)

Run this for C: drive where hiberfil.sys and pagefile.sys live at root.

```powershell
$ErrorActionPreference = "SilentlyContinue"

# System files
Write-Output "=== System Files ==="
@("C:\hiberfil.sys","C:\pagefile.sys","C:\swapfile.sys") | ForEach-Object {
    if (Test-Path $_) {
        $sz = (Get-Item $_).Length
        "$([math]::Round($sz/1GB,2)) GB  $_"
    }
}

# Top-level directories
Write-Output "`n=== Top-Level Directories ==="
Get-ChildItem "C:\" -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    if ($size -gt 0) {
        $g = [math]::Round($size/1GB, 2)
        if ($g -gt 0.2) { "$g GB`t$($_.Name)" }
    }
} | Sort-Object -Descending

# Temp and cache
Write-Output "`n=== Temp & Cache ==="
@(
    @("$env:TEMP","User Temp"),
    @("$env:WINDIR\Temp","Windows Temp"),
    @("$env:WINDIR\SoftwareDistribution\Download","Windows Update"),
    @("$env:ProgramData\Package Cache","Package Cache")
) | ForEach-Object {
    if (Test-Path $_[0]) {
        $s = (Get-ChildItem $_[0] -Recurse -File -ErrorAction SilentlyContinue |
              Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        $g = [math]::Round($s/1GB, 2)
        if ($g -gt 0) { "$g GB`t$($_[1])`t$($_[0])" }
    }
}

# Large profile directories
Write-Output "`n=== User Profile Subdirs ==="
$profile_dirs = @(
    "C:\Users\$env:USERNAME\AppData",
    "C:\Users\$env:USERNAME\scoop",
    "C:\Users\$env:USERNAME\.cache"
)
foreach ($d in $profile_dirs) {
    if (Test-Path $d) {
        $s = (Get-ChildItem $d -Recurse -File -ErrorAction SilentlyContinue |
              Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        "$([math]::Round($s/1GB,2)) GB  $d"
    }
}
```

## Known Working Patterns

- **Timeout guard**: if scanning AppData takes >300s, split by subfolder:
  ```
  $ErrorActionPreference="SilentlyContinue"
  Get-ChildItem "C:\Users\$env:USERNAME\AppData\Local" -Directory |
      ForEach-Object { scan $_ }
  ```
- **WSL check**: `wsl -l -v` from PowerShell proper (git-bash output has null-byte issues)
- **hiberfil/pagefile**: always check root of C:, they can consume 13-33 GB
