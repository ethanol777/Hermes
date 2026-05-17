# Codex CLI + Transform Relay — Debugging Session (2026-05-17)

## Environment

- **Host**: Windows 10, PowerShell with oh-my-posh (but `pwd` shows bash-style paths)
- **Shell**: Primary is PowerShell; git-bash (MSYS2) available via terminal tool
- **Node**: fnm-managed (scoop), v22.22.2
- **Codex CLI**: `@openai/codex@0.130.0` (npm global via fnm)
- **Relay**: Transform Platform at `https://rsxermu666.cn/openai` (backup: `bxcv.store`)
- **API key**: Platform-generated `sk-*` key from relay dashboard

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

## Resolution Steps

1. **Remove `.git` from home** → `rm -rf ~/.git` so `~/.codex/config.toml` is recognized as user-level
2. **Add `env_key` to project config** → `[model_providers.codex] env_key = "OPENAI_API_KEY"`
3. **Set persistent env var** → PowerShell profile (`$PROFILE`): `$env:OPENAI_API_KEY = "sk-..."`
4. **Also set for git-bash** → `~/.bashrc`: `export OPENAI_API_KEY="sk-..."`
5. **Verify relay** → `curl -s -H "Authorization: Bearer $OPENAI_API_KEY" https://rsxermu666.cn/openai/models`

## Verification

After all fixes, Codex from the project directory runs without `-c` flags:
```
$ cd D:\Code\projects\Workspace\planC
$ codex exec 'print("ok")' --yolo
model: gpt-5.4
provider: codex
tokens used: 135,951
```

## Key Lessons

1. **Codex v0.130.0+ has two config layers**: user-level (`~/.codex/config.toml`) and project-level (`<project>/.codex/config.toml`). `model_provider`/`model_providers` only work in user-level config.
2. **Git repo detection**: Codex considers any `.codex/` directory inside a git repo as project-level. Even your home directory.
3. **`env_key` is required**: Without it in the provider definition, Codex returns 401 even with a valid key in the env var.
4. **Windows shell split**: PowerShell and git-bash have independent env var namespaces. Set in both.
5. **Relay models endpoint format mismatch**: Transform relay returns `{"data": [...], "object": "list"}` (OpenAI-style) but Codex v0.130.0 expects `{"models": [...]}`. This causes a non-fatal error on startup but doesn't affect execution.

## Layer 4: `codex` vs `transform` provider — hardcoded OAuth

Even after fixing env var and config layers, the **Codex desktop app** may fail with:

```
Error sending request for url (https://auth.openai.com/oauth/token)
```

**Root cause**: `model_provider = "codex"` uses Codex's built-in provider with hardcoded OAuth. It always authenticates at `auth.openai.com/oauth/token`, ignoring the `base_url` setting entirely. For relays, you must use `model_provider = "transform"` which passes the API key as a simple Bearer header.

**Fix**: Change both `~/.codex/config.toml` and any project-level `.codex/config.toml`:
```toml
# Before (broken for relays):
model_provider = "codex"
[model_providers.codex]
name = "codex"
base_url = "https://rsxermu666.cn/openai"
wire_api = "responses"
requires_openai_auth = true

# After (working):
model_provider = "transform"
[model_providers.transform]
name = "transform"
base_url = "https://rsxermu666.cn/openai"
wire_api = "responses"
requires_openai_auth = true
```

## Layer 5: cc-switch overwrites config

cc-switch (third-party Codex/Claude config manager) rewrites `~/.codex/config.toml` when switching API providers. It:
1. Sets `model_provider = "codex"` — breaks relay (see Layer 4)
2. Strips `env_key = "OPENAI_API_KEY"` — causes `Missing environment variable`

**Workaround**: After every cc-switch API switch, manually re-apply both fixes to `~/.codex/config.toml`.
