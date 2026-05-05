# WSL Self-Hosting Limitations (Honcho + Similar Services)

## Environment profile
- **OS**: WSL2 (Windows Subsystem for Linux)
- **sudo**: Disabled via Windows settings
- **Docker**: Not installable (requires sudo or Windows Docker Desktop)
- **Package managers**: apt-get download + dpkg-deb -x for no-sudo extraction

## What fails
| Attempt | Result |
|---------|--------|
| `docker compose up --build` | Permission denied (docker socket requires root) |
| `sudo apt install postgresql` | sudo: effective uid is not 0 |
| `systemctl --user start postgresql` | service manager not available / permission denied |

## Working alternatives
| Need | Solution | How |
|------|----------|-----|
| Local memory backend | Holographic (Hermes plugin) | `hermes config set memory.provider holographic` |
| Cross-session modeling | Holographic (SQLite FTS5 + HRR) | Bundled with Hermes, no install needed |
| Vector search | Holographic (HRR phase encoding) | auto_extract=true in plugins.hermes-memory-store |
| Cloud memory | Honcho cloud (app.honcho.dev) | API key required; connectivity: `curl -s --max-time 10 https://api.honcho.dev` |

## Diagnosis script
```bash
# Quick check: can we self-host anything requiring Docker?
docker ps 2>&1
# → "permission denied" = Docker not usable, use local-only alternatives

# Check Honcho cloud connectivity
curl -s --max-time 10 -o /dev/null -w "%{http_code}" https://api.honcho.dev
# → 403/401 = reachable
# → timeout/000 = blocked (try cloudflare tunnel or skip Honcho entirely)

# Check Holographic availability
hermes memory status | grep holographic
# → "available ✓" = good to go
```
