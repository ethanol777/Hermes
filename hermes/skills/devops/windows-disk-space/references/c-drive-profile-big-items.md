# C: Drive User Profile — Common Large Items

Real data from real scans (2026-05). Sizes are typical ranges — your mileage will vary.

## Top-Level Directories

| Directory | Typical size | Notes |
|-----------|-------------|-------|
| `Windows` | 40-50 GB | WinSxS alone is 20-30 GB |
| `Users\<user>` | 30-90 GB | Profile — depends on apps installed |
| `Program Files` | 10-20 GB | |
| `Program Files (x86)` | 8-15 GB | |

## System Files at Root

| File | Size range | How to free |
|------|-----------|-------------|
| `hiberfil.sys` | 8-20 GB | `powercfg -h off` (admin) |
| `pagefile.sys` | 8-32 GB | System Properties → Advanced → Performance → Virtual Memory |
| `swapfile.sys` | 16-256 MB | Ignore, tiny |

## User Profile — AppData Breakdown

### AppData\Local (largest — often 40-70 GB)

| Item | Size range | What it is |
|------|-----------|------------|
| `Google` (Chrome) | 5-15 GB | Profiles + cache. Cache is safe to clear. |
| `wsl` | 5-20 GB | WSL VM disk (`ext4.vhdx`). Unregister if unused. |
| `Temp` | 2-5 GB | ✅ Safe to delete |
| `Programs` | 2-5 GB | Per-user installed apps |
| `Microsoft` | 3-6 GB | Edge, Windows caches, etc. |
| `uv` | 3-8 GB | Python package manager cache |
| `pip` | 0.5-1.5 GB | pip cache — `pip cache purge` |
| `npm-cache` | 0.5-2 GB | npm cache — `npm cache clean --force` |
| `pnpm` | 1-3 GB | pnpm store |
| `Yarn` | 0.5-2 GB | Yarn cache |
| `Python` | 1-2 GB | Python installers/data |
| `ms-playwright` | 1-3 GB | Playwright browsers. Safe to delete if not testing. |

### AppData\Roaming (10-30 GB)

| Item | Size range | What it is |
|------|-----------|------------|
| `kingsoft` (WPS) | 2-5 GB | WPS Office data |
| `Code` (VS Code) | 2-5 GB | Extensions, caches |
| `LarkShell` (飞书) | 2-5 GB | Feishu app data |
| `Tencent` / `QQ` / `QQEX` | 1-4 GB | Tencent chat apps |
| `CherryStudio` | 0.5-2 GB | AI chat client |
| `obsidian` | 0.3-1 GB | Obsidian notes |
| `SiYuan-Electron` | 0.3-1 GB | SiYuan notes |

### AppData\LocalLow (1-5 GB)

Usually game or low-integrity app data.

## User Profile — Other Large Directories

| Item | Size range | Notes |
|------|-----------|-------|
| `scoop\persist` | 3-10 GB | Package persistent data — nodejs alone can be 6 GB |
| `scoop\apps` | 2-5 GB | Installed scoop packages |
| `scoop\cache` | 1-2 GB | Download cache — `scoop cache rm` |
| `.cache` | 1-5 GB | Various tool caches |
| `.git` | 1-5 GB | Git objects — inspect before deleting |
| `.trae-cn` / `.vscode` | 2-4 GB | IDE config |
| `.qoder` / `.marscode` / `.lingma` | 1-3 GB | AI-assisted coding tools |

## Pitfall: Large File Scan on C: Times Out

C: drive has **many more small files** than D: drives (system files, registry, package managers, node_modules). Never do a full recursive `Get-ChildItem "C:\" -Recurse` — it will timeout. Always:

1. Scan top-level directories first (fast, <30s)
2. Drill into `Users\<user>` specifically (the profile is the biggest consumer)
3. Within profile, separate `AppData` into Local vs Roaming vs LocalLow
4. Scan AppData subdirectories individually with a 0.5 GB threshold
