# Relay Debug Session — 2026-05-17

## Codex CLI v0.130.0 + Relay (Transform Platform rsxermu666.cn)

### Environment
- Windows 10, PowerShell + git-bash
- Hermes agent running via OpenCode Go + deepseek-v4-flash
- Codex CLI v0.130.0 (npm global, fnm-managed Node)
- Relay: Transform Platform (rsxermu666.cn), Model B (platform-generated keys)

### The Problem
Codex CLI returned 401 `无效的API Key` despite:
- Valid key in `~/.codex/auth.json`
- Key working via curl: `curl -s -H "Authorization: Bearer $KEY" https://rsxermu666.cn/openai/models`
- Config.toml with correct `base_url` and `wire_api = "responses"`

### Root Causes Found

#### 1. Config Split in v0.130.0
Codex v0.130.0+ distinguishes two config levels:
- **User-level** (`~/.codex/config.toml`): `model_provider`, `model_providers`, and other provider definitions
- **Project-level** (`<project>/.codex/config.toml`): model, features, MCP servers, overrides

**Critical**: `model_provider` and `model_providers` are **ignored** in project-level config. If they appear there, Codex falls back to default `codex` provider → 401.

#### 2. Home Directory as Git Repo
If `~` (home dir) is a git repo, Codex treats `~/.codex/config.toml` as project-level config. The user's `C:\Users\77` had a `.git` (from gstack/Claude setup). Fix: `rm -rf ~/.git`.

Detection: run Codex and look for `warning: Ignored unsupported project-local config keys` followed by `model_provider` / `model_providers`.

#### 3. Missing env_key in Provider Definition
Even with `requires_openai_auth = true`, Codex needs `env_key = "OPENAI_API_KEY"` in the provider block. Without it, the provider doesn't know WHICH environment variable to read for the API key.

**Working config.toml (user-level):**
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

**Working config.toml (project-level, uses `codex` provider name):**
```toml
model_provider = "codex"
model = "gpt-5.4"

[model_providers.codex]
name = "codex"
base_url = "https://rsxermu666.cn/openai"
wire_api = "responses"
requires_openai_auth = true
env_key = "OPENAI_API_KEY"
```

#### 4. Env Var Not Set for Desktop Apps
PowerShell profile (`$PROFILE`) environment variables are only available to PowerShell sessions. Desktop apps (Codex desktop app, other GUI tools) need **User-level** environment variables set via the registry:

```powershell
[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "<key>", "User")
```

Then **restart the desktop app** — new processes inherit User-level env vars at startup.

### Diagnostic Commands

```bash
# Test relay connectivity
curl -s https://rsxermu666.cn/openai/models -H "Authorization: Bearer $KEY"

# Check env var (PowerShell)
$env:OPENAI_API_KEY

# Check env var (bash/git-bash)
echo $OPENAI_API_KEY

# Set env var temporarily (PowerShell)
$env:OPENAI_API_KEY = "<key>"

# Set env var permanently (User-level, Windows)
[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "<key>", "User")

# Verify config keys being loaded
codex features list  # shows which config.toml was used
```

### Project-Level Config Discovery
The user had a project at `D:\Code\projects\Workspace\planC\.codex\config.toml` with `model_provider = "codex"` and `base_url` pointing to the relay. It was missing `env_key`. After adding it, Codex CLI worked from the project directory without any `-c` flags.

### Quick Fix (No Config File Changes)
```bash
codex exec 'do something' --yolo \
  -c model_provider=transform \
  -c 'model_providers.transform={name="transform",base_url="https://rsxermu666.cn/openai",wire_api="responses",requires_openai_auth=true,env_key="OPENAI_API_KEY"}' \
  -c model=gpt-5.4
```
