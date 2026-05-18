---
name: windows-disk-space
description: >-
  Windows disk space analysis and cleanup from a git-bash (MSYS2) environment.
  Methods for scanning large files, identifying reusable directories
  (cache, temp, logs), and generating cleanup recommendations.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [windows, disk-space, cleanup, system-administration, devops]
---

# Windows Disk Space Management

## Trigger Conditions

- User asks to check/analyze/clean up disk space on a Windows system
- Questions like "what's taking up space on D:?", "帮我清理C盘", "磁盘空间不够了"
- Looking for large files, cache directories, or useless data to delete
- WSL virtual disk cleanup requests

## Approach

### 1. Quick overview

```bash
df -h /d      # or /c for C: drive
```

### 2. Scan directory sizes first — never scan the whole drive recursively

Git-bash's `du` and `find` are extremely slow on large Windows directories
with many small files. **Always start with top-level directory sizes** to
identify the biggest consumers before drilling down.

Write a PowerShell script for reliable bulk scanning:

**`scan_dirs.ps1`** — top-level directory sizes:
```powershell
$target = "D:\"
Get-ChildItem $target -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    if ($size -gt 0) {
        "$([math]::Round($size/1GB,2)) GB`t$($_.Name)"
    }
} | Sort-Object -Descending
```

Run from git-bash:
```bash
powershell.exe -ExecutionPolicy Bypass -File scan_dirs.ps1
```

### 3. Drill into the largest directories

Once you know the top consumers (e.g. `Fun` 98 GB, `Code` 70 GB), scan
their subdirectories one at a time with the same pattern:

```powershell
$dir = "D:\Fun"
Get-ChildItem $dir -Directory | ForEach-Object {
    $size = (Get-ChildItem $_.FullName -Recurse -File -ErrorAction SilentlyContinue |
             Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
    if ($size -gt 0) {
        "$([math]::Round($size/1GB,2)) GB`t$($_.Name)"
    }
} | Sort-Object -Descending
```

### 4. Find large individual files

For a focused directory (not the whole drive), list files > 200 MB:
```powershell
Get-ChildItem "D:\SomeDir" -Recurse -File -ErrorAction SilentlyContinue |
    Where-Object { $_.Length -gt 200MB } |
    Sort-Object Length -Descending |
    Select-Object -First 30 |
    ForEach-Object { "$([math]::Round($_.Length/1GB,2)) GB  $($_.FullName)" }
```

### 5. Scoop persist cleanup check

When a user has `scoop` installed and you see a large `persist/` directory:

1. List both `persist/` and `apps/` directories
2. Compare: any directory name in `persist/` without a match in `apps/` is **orphaned** — the app was uninstalled but its persistent data remained
3. Always ask before deleting orphaned persist dirs (they may contain user configs or data)

```powershell
$ErrorActionPreference = "SilentlyContinue"
$scoop = "C:\Users\$env:USERNAME\scoop"

$apps = @(Get-ChildItem "$scoop\apps" -Directory | % { $_.Name })
$persist = @(Get-ChildItem "$scoop\persist" -Directory | % { $_.Name })

$orphans = $persist | Where-Object { $_ -notin $apps }
if ($orphans.Count -eq 0) {
    Write-Output "No orphaned persist directories found."
} else {
    Write-Output "Orphaned persist directories (app not installed):"
    $orphans | ForEach-Object {
        $sz = (Get-ChildItem "$scoop\persist\$_" -Recurse -File -ErrorAction SilentlyContinue |
               Measure-Object -Property Length -Sum -ErrorAction SilentlyContinue).Sum
        "$([math]::Round($sz/1GB,2)) GB  $_"
    }
}
```

### 5. Identify reusable space by category

| Category | Typical locations | Safe to delete? |
|----------|-------------------|-----------------|
| Windows update cache | `DeliveryOptimization` | ✅ Yes |
| pip cache | `~/.cache/pip` | ✅ Yes |
| conda package cache | `miniconda3/pkgs` | ✅ Yes (`conda clean -a`) |
| Browser/app caches | `Search\Quark`, etc. | ✅ Usually yes |
| Old installers | `.exe`, `.msi`, `.iso` > 100 MB | ⚠️ If already installed |
| Duplicate code/projects | Multiple copies of same repo | ⚠️ Depends on need |
| Games | Steam, Minecraft, etc. | ⚠️ If no longer playing |
| Old logs | `*.log` files | ✅ Yes |
| Temporary files | `tmp/`, `Temp/` | ✅ Yes |
| WSL virtual disk | `AppData\Local\wsl\*\ext4.vhdx` | ⚠️ Unregister if unused |
| pip/npm/pnpm/Yarn caches | `.cache/pip`, `.npm`, etc. | ✅ Yes |
| scoop cache | `scoop/cache` | ✅ Yes (`scoop cache rm`) |

### 6. C: drive specific analysis

C: drive has unique system files and profile structure that require special handling:

**System files (root of C:):**
```powershell
# Check these from git-bash:
ls -lh /c/hiberfil.sys   # Hibernation — 13 GB typical, turn off with: powercfg -h off
ls -lh /c/pagefile.sys   # Virtual memory — 20 GB typical, adjustable in System Settings
ls -lh /c/swapfile.sys    # App swap — small, ignore
```

**Windows directories of interest:**
| Directory | Size range | Notes |
|-----------|-----------|-------|
| `C:\Windows\WinSxS` | 20-30 GB | Component store. Use `DISM /Online /Cleanup-Image /StartComponentCleanup` |
| `C:\Windows\Installer` | 3-8 GB | MSI installers cache. Hard to clean safely. |
| `C:\Windows\SoftwareDistribution\Download` | 1-5 GB | ✅ Safe to delete contents |
| `C:\ProgramData\Package Cache` | 0.5-2 GB | ✅ Safe to delete |

**User profile structure (`C:\Users\<user>`):**
```powershell
# Profile subdirectory targets from PowerShell:
$base = "C:\Users\$env:USERNAME"

# AppData breakdown:
#   AppData\Local   — Machine-specific app data (largest: Chrome, WSL, pip caches)
#   AppData\Roaming — User-specific settings (VS Code, WPS, chat apps)
#   AppData\LocalLow — Low-integrity apps
```

**Common large profile items:**
| Item | Typical size | Notes |
|------|-------------|-------|
| `AppData\Local\Google` | 5-15 GB | Chrome profiles + cache. Clearing cache is safe. |
| `AppData\Local\wsl` | 5-20 GB | WSL VM disk. Already-running/unused. |
| `AppData\Local\Temp` | 2-5 GB | ✅ Safe to delete |
| `AppData\Roaming\kingsoft` | 2-5 GB | WPS Office data |
| `AppData\Roaming\Code` | 2-5 GB | VS Code extensions + caches |
| `scoop` | 5-15 GB | Package manager (persist/ + apps/ + cache/) — see scoop persist check below |
| `.cache` | 1-5 GB | Tool caches |
| `.git` | 1-5 GB | Git objects — verify before deleting |

## Pitfalls

- **`du` from git-bash MSYS2 is extremely slow** on Windows directories with
  many small files. It will time out on large drives (60s default timeout is
  far too short for a 658 GB drive scan). Always use PowerShell script files.
- **`find /d -type f -size +100M` is also slow** on a full recursive scan of
  a large drive. Scope scans to specific directories, never the whole drive.
- **PowerShell `$` variables get eaten by bash** — you MUST write `.ps1`
  script files and run with `powershell.exe -ExecutionPolicy Bypass -File`.
  Avoid inline `-Command` with `$_` or `${}` syntax.
- **Chinese/Unicode characters in script files cause encoding errors.** When
  you use `write_file` tool to create a `.ps1` with Chinese characters,
  PowerShell may fail to parse them. Two mitigations:
  1. Write scripts with English-only identifiers and comments (safer).
  2. Use Unicode escape sequences (`\u5f53` → `当`) via the tool's JSON encoding
     to embed Chinese in string literals.
- **When a PowerShell script encounters a parsing error from encoding issues,**
  the error message will show garbled characters. This is a reliable signal
  that the file encoding is wrong. Rewrite avoiding non-ASCII text.
- **`Test-Path` is fast** for checking existence. Use it before attempting
  to scan directories that may not exist.
- **Recycle bin size is hard to measure** — `du $RECYCLE.BIN` may never
  complete due to access restrictions. Skip it or use `cmd /c dir /a`.
- **Scanning the entire drive recursively for large files is too slow**
  on 500+ GB drives with many files. Always scan at directory level first,
  then drill down into the largest directories.
- **The `$RECYCLE.BIN`** path contains a `$` that PowerShell interprets as
  a variable. Use single quotes or escape it: `'D:\$RECYCLE.BIN'`.
- **Timeout strategy**: if a PowerShell script takes >300s, break it into
  smaller focused scripts targeting one directory at a time. The directory-
  level scan (step 2 in Typical Workflow) should finish in under 60s.\n
- **`du --threshold` for quick partial scans**: If `du` on a large drive is
  too slow, use the `--threshold` flag to skip small items:
  ```bash
  du -sh --threshold=1G /d/*        # only show items > 1 GB
  du -sh --threshold=1G /d/*/  2>/dev/null | sort -rh
  ```
  This can complete in seconds instead of minutes, giving you the biggest
  consumers without waiting for a full scan. However, it still can't match
  PowerShell's speed on Windows — fall back to PowerShell scripts for
  precision.
- **WSL disk file path**: `C:\Users\<user>\AppData\Local\wsl\{UUID}\ext4.vhdx`.
  To check size from git-bash: `ls -lh /c/Users/.../ext4.vhdx`.
  To free space: `wsl --unregister <distro_name>` (destroys all data).
  To- **`wsl -l -v` from git-bash produces completely garbled output** — the command
  outputs UTF-16 with null bytes between characters, which MSYS2 renders as
  unreadable garbage. Examples seen: `\u0000 \u0000N\u0000A\u0000M\u0000E...` in
  stdout, or completely scrambled text. **Always run WSL management commands
  from cmd.exe or PowerShell**, not git-bash.
  From git-bash, pipe through `cat -v` to see the raw bytes:
  ```bash
  wsl -l -v 2>&1 | cat -v
  ```
  But the output is still barely readable. Use PowerShell instead:
  ```powershell
  powershell.exe -Command "wsl -l -v"
  ```
  Or write to a file and read it:
  ```bash
  wsl -l -v > /tmp/wsl.txt 2>&1
  cat /tmp/wsl.txt
  ```
- **`schtasks` output also garbled in git-bash** — same UTF-16 issue. Pipe through
  `cat -v` or redirect to file for parsing.
- **`hiberfil.sys` and `pagefile.sys`** are hidden system files. From git-bash
  they appear as regular files owned by user. The sizes are visible via `ls -lh`.
  Disable hibernation: `powercfg -h off` (run as admin).

## Typical Workflow

1. Run `df -h /d` to see drive usage overview
2. Scan top-level directories (PowerShell script, see above)
3. Identify the 3-5 biggest directories
4. Drill into each one with subdirectory scanning
5. Check cache/temp/installer directories for easy wins
6. Present findings organized by confidence: safe-to-delete → conditional → keep
7. Ask user which to clean before executing any deletions

## Common cleanup commands

```bash
# pip cache (usually in Code/root/.cache/pip or similar)
rm -rf /d/Code/root/.cache/pip

# conda
conda clean -a --yes

# DeliveryOptimization (Windows update cache)
rm -rf /d/DeliveryOptimization

# App search caches
rm -rf /d/Search/*

# npm/pnpm/Yarn caches
npm cache clean --force
pnpm store prune
yarn cache clean

# scoop cache
scoop cache rm

# C: drive Temp
rm -rf /c/Users/*/AppData/Local/Temp/*
rm -rf /c/Windows/Temp/*

# Windows Update download cache
rm -rf /c/Windows/SoftwareDistribution/Download/*

# Disable hibernation (run as admin, frees hiberfil.sys)
powercfg -h off

# Clean WinSxS component store (run as admin)
DISM /Online /Cleanup-Image /StartComponentCleanup /ResetBase

# WSL — unregister and delete disk (run as admin, destroys all data)
wsl --unregister Ubuntu
```

## References

- `references/disk-scan-scripts.md` — Copy-paste-ready PowerShell scripts for scanning directory sizes, large files, and C: drive system analysis.
- `references/c-drive-profile-big-items.md` — Real-world reference for C: drive user profile item sizes (AppData breakdown, scoop, system files). Use during C: drive analysis to quickly estimate expected sizes without scanning.
