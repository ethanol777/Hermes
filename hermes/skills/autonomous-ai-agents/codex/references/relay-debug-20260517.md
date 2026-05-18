# Codex CLI + Transform Relay — Debugging Session (2026-05-17)

## Environment

- **Host**: Windows 10, PowerShell with oh-my-posh
- **Shell**: Primary is PowerShell; git-bash (MSYS2) available via terminal tool
- **Node**: fnm-managed (scoop), v22.22.2
- **Codex CLI**: `@openai/codex@0.130.0` (npm global via fnm)
- **Relay**: Transform Platform at `https://rsxermu666.cn/openai` (backup: `bxcv.store`)
- **API key**: Platform-generated `sk-*` key from relay dashboard

## Hermes Config Locations Found

cc-switch (`.cc-switch/`) reads Hermes config files when importing Hermes providers. Multiple config locations exist:

| Path | Description |
|------|-------------|
| `~/.hermes/config.yaml` | Primary user-level config (cc-switch reads this) |
| `~/AppData/Local/hermes/config.yaml` | AppData config (used by Hermes itself) |
| `~/Hermes/hermes/config.yaml` | Another copy (source/build tree?) |

**cc-switch piper duplicate bug**: `~/.hermes/config.yaml` had TWO `piper` keys under `tts:` at different lines (line 220 + line 244), causing cc-switch's YAML parser to fail with `tts: duplicate entry with key "piper" at line 219 column 3`.

**Fix**: Remove the duplicate piper entry. Check ALL profile configs under `~/.hermes/profiles/` too.

## Config Structure

Two `.codex/config.toml` files exist:

### User-level: `C:\Users\77\.codex\config.toml`
```toml
model_provider = "transform"
model = "gpt-5.4"

[model_providers.transform]
name = "transform"
base_url = "https://rsxermu666.cn/openai"
wire_api = "responses"
requires_openai_auth = true
env_key = "OPENAI_API_KEY"
```

### Project-level: `D:\Code\projects\Workspace\planC\.codex\config.toml`
```toml
model_provider = "codex"
model = "gpt-5.4"

[model_providers.codex]
name = "codex"
base_url = "https://rsxermu666.cn/openai"
wire_api = "responses"
requires_openai_auth = true
env_key = "OPENAI_API_KEY"   # ← was MISSING, causing 401
```

## Problem Chain

### Layer 1: Home dir is a git repo → config treated as project-level
`C:\Users\77` had a `.git` directory (tracking `.claude/` cache). Codex v0.130.0+ treats `.codex/config.toml` as **project-level** when it's inside a git repo, silently ignoring `model_provider` and `model_providers`.

**Signal**: `Ignored unsupported project-local config keys in C:\Users\77\.codex\config.toml: model_provider, model_providers.`

**Fix**: `rm -rf ~/.git`

### Layer 2: Missing `env_key` in project-level config → 401
The D-drive project config (`D:\Code\projects\Workspace\planC\.codex\config.toml`) used `model_provider = "codex"` and pointed to the relay, but was missing `env_key = "OPENAI_API_KEY"`. Without it, Codex didn't know which env var to read for auth.

**Signal**: `unexpected status 401 Unauthorized: 无效的API Key`

**Fix**: Add `env_key = "OPENAI_API_KEY"` to the provider definition in the config.

### Layer 3: Shell env var scope mismatch
PowerShell and git-bash have separate env var scopes on Windows. Even when the key is set in a PowerShell `[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "...", "User")`, git-bash doesn't see it until `export OPENAI_API_KEY="..."` is run.

**Signal**: `Missing environment variable: OPENAI_API_KEY`

**Fix**: 
- PowerShell: `$env:OPENAI_API_KEY = "sk-..."` before running codex, or add to `$PROFILE`
- git-bash: `export OPENAI_API_KEY="sk-..."` in `~/.bashrc`
- Windows User env var: `[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-...", "User")` (needs app restart)

### Layer 4: `codex` vs `transform` provider — hardcoded OAuth
`model_provider = "codex"` uses Codex's built-in provider with hardcoded OAuth. It always authenticates at `auth.openai.com/oauth/token`, ignoring the `base_url` setting entirely. For relays, must use `model_provider = "transform"` which passes the API key as a simple Bearer header.

**Signal**: `Error sending request for url (https://auth.openai.com/oauth/token)`

**Fix**: Change both `~/.codex/config.toml` and any project-level `.codex/config.toml`:
```toml
# Before (broken for relays):
model_provider = "codex"
[model_providers.codex]

# After (working):
model_provider = "transform"
[model_providers.transform]
```

### Layer 5: cc-switch overwrites config
cc-switch (third-party Codex/Claude config manager at `~/.cc-switch/`) rewrites `~/.codex/config.toml` when switching API providers. It:
1. Sets `model_provider = "codex"` — breaks relay (see Layer 4)
2. Strips `env_key = "OPENAI_API_KEY"` — causes `Missing environment variable`

cc-switch stores provider configs in SQLite: `~/.cc-switch/cc-switch.db` → table `providers` (id, app_type, name, settings_config). Hermes provider configs backed up in `~/.cc-switch/backups/hermes/`.

**Workaround**: After every cc-switch API switch, manually re-apply both fixes to `~/.codex/config.toml`.

### Layer 6: Codex CLI vs Desktop separation
Codex **CLI** (`codex exec`) uses `~/.codex/config.toml`. Codex **desktop** (CodexManager, a third-party app at `com.codexmanager.desktop`) has its OWN auth system:

- Database: `%APPDATA%/com.codexmanager.desktop/codexmanager.db`
- Tables: `accounts`, `tokens`, `api_keys`, `login_sessions`
- Config: `app_settings` table with `gateway.route_strategy`, `app.env_overrides`

The desktop app's `CODEXMANAGER_ISSUER` defaults to `https://auth.openai.com` and `CODEXMANAGER_UPSTREAM_BASE_URL` defaults to `https://chatgpt.com/backend-api/codex`. It requires OpenAI account login or AT/RT token import — it doesn't read `config.toml` at all.

**Removal**: 
```powershell
npm uninstall -g @openai/codex            # CLI
rm -rf ~/.codex                            # CLI config
rm -rf "$env:LOCALAPPDATA\com.codexmanager.desktop"   # Desktop app data
rm -rf "$env:APPDATA\com.codexmanager.desktop"        # Desktop config
rm -rf ~/.cache/codex-runtimes             # CLI runtime cache
```

## PowerShell Wrapper Function

To avoid typing long `-c` flags every time, define a wrapper in PowerShell profile:

```powershell
function codex-cn {
  codex exec $args --yolo -c model_provider=transform -c 'model_providers.transform={name="transform",base_url="https://rsxermu666.cn/openai",wire_api="responses",requires_openai_auth=true,env_key="OPENAI_API_KEY"}' -c model=gpt-5.4
}
```

Usage: `codex-cn 'print("hello")'`

## Relay Status Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | OK — models list returned | Normal |
| 401 | 无效的API Key | Key expired/wrong; check env var or auth.json |
| 503 | authentication backend temporarily unavailable | Relay upstream down; wait or contact provider |
| 503 | 无可用上游账号或所有账号额度已耗尽 | Relay quota exhausted; wait or recharge |

## Verification Steps

1. **Check relay**: `curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://rsxermu666.cn/openai/models`
2. **Check config**: Verify `model_provider = "transform"` in `~/.codex/config.toml`
3. **Check auth**: Ensure `env_key = "OPENAI_API_KEY"` exists in the provider section
4. **Check env var**: `echo $env:OPENAI_API_KEY` (PowerShell) or `echo $OPENAI_API_KEY` (bash)
5. **Run**: `codex exec 'print("ok")' --yolo -c model=gpt-5.4` (for project-level) or full `-c` flags (for home dir)
