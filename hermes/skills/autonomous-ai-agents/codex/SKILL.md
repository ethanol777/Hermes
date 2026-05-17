---
name: codex
description: "Delegate coding to OpenAI Codex CLI (features, PRs) — plus install, integrate, and clean up on Windows/fnm."
version: 1.4.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [Coding-Agent, Codex, OpenAI, Code-Review, Refactoring, Windows, fnm]
    related_skills: [claude-code, hermes-agent, overseas-ai-api-access]
---

# Codex CLI

Delegate coding tasks to [Codex](https://github.com/openai/codex) via the Hermes terminal.
Codex is OpenAI's autonomous coding agent CLI.

## When to use

- Building features
- Refactoring
- PR reviews
- Batch issue fixing

Requires the codex CLI and a git repository.

## Prerequisites & Setup

### Installation

```bash
npm install -g @openai/codex
```

**Windows/fnm note:** When Node.js is managed by fnm (e.g. via scoop), `npm install -g` puts the package into the persistent fnm node installation at:
```
scoop\persist\fnm\node-versions\<version>\installation\node_modules\@openai\codex
```
The CLI shims (`codex`, `codex.cmd`, `codex.ps1`) appear in the current fnm multishell directory (`AppData\Local\fnm_multishells\<pid>_\<timestamp>\`), which is added to PATH dynamically by fnm.

### PowerShell Profile Integration

If you wrap `codex` in a PowerShell function (e.g. to inject a system prompt), **do not hardcode the CLI path** — the fnm multishell path contains a PID and changes every session.

```powershell
# ❌ Wrong — fnm multishell PID changes
$codexCliPath = "$env:USERPROFILE\AppData\Local\fnm_multishells\22916_1778412943301\codex.ps1"

# ✅ Correct — resolve dynamically
$codexCmd = Get-Command codex -ErrorAction SilentlyContinue
if ($codexCmd) { $codexCliPath = $codexCmd.Source }
```

### Verifying Installation

```bash
codex --version
# Expected: codex-cli <version>
```

Also check the global package is actually in the persistent Node installation (not just the ephemeral multishell):

```bash
# Via fnm's Node directly
/path/to/fnm/node-versions/<version>/installation/npm.cmd list -g @openai/codex --depth=0
```

## Configuration

Codex CLI v0.130.0+ reads config from **two layers**:

| 层级 | 路径 | 作用 |
|------|------|------|
| 用户级 | `~/.codex/config.toml` | `model_provider`, `model_providers` 等全局默认 |
| 项目级 | `<project>/.codex/config.toml` | 覆盖项目专属设置（model、features、MCP 等） |

项目级覆盖用户级。`model_provider` 和 `model_providers` **只能放在用户级**，项目级配置里会被静默忽略。

**坑**：如果 `~` 本身就是 git 仓库，Codex 会把 `~/.codex/config.toml` 误判为项目级配置，跳过 `model_provider`/`model_providers`。表现：日志里有 `Ignored unsupported project-local config keys`。解决：`rm -rf ~/.git`。

Key fields:

| Field | Purpose | Example |
|-------|---------|---------|
| `model_provider` | Which provider block to use | `"codex"` or `"transform"` |
| `model` | Model name | `"gpt-5.4"` |
| `model_reasoning_effort` | Reasoning level | `"low"`, `"medium"`, `"high"` |
| `base_url` | API endpoint URL (under the provider section) | `"https://api.openai.com"` |
| `wire_api` | API protocol — Codex uses the Responses API | `"responses"` |
| `requires_openai_auth` | Whether auth is needed | `true` |
| `env_key` | Which env var to read for the API key | `"OPENAI_API_KEY"` |

### Using Codex CLI Through an API Relay (China)

From within China, direct access to `api.openai.com` is blocked. Codex CLI can be configured to use an API relay/proxy (see the `overseas-ai-api-access` skill for relay provider options).

**Important:** Chinese API relays typically generate **their own API keys** — you don't use your direct OpenAI key. The flow is: buy an activation code → redeem on the relay's dashboard → get a platform-generated API key.

1. **Set `base_url`** to the relay's Codex-specific endpoint (e.g., `"https://rsxermu666.cn/openai"`)
2. **Keep `wire_api = "responses"`** — Codex uses the Responses API protocol
3. **Add `env_key = "OPENAI_API_KEY"`** — tells Codex which env var holds the key
4. **Store the relay key** in `~/.codex/auth.json`:
   ```json
   { "OPENAI_API_KEY": "sk-relay-key-here" }
   ```

Example relay config:

```toml
...
```

> Real debugging session with Transform Platform (rsxermu666.cn): see `overseas-ai-api-access/references/relay-debug-20260517.md` in the related skill.

### `transform` vs `codex` provider — critical distinction for relays

When using a relay (not direct OpenAI), you must set `model_provider = "transform"`, **not** `"codex"`.

| Provider | Auth mechanism | Works with relays? |
|----------|---------------|-------------------|
| `codex` | Hardcoded OAuth → `auth.openai.com/oauth/token` | ❌ — bypasses `base_url`, always hits OpenAI auth |
| `transform` | Plain API key header (Bearer token) | ✅ — uses `base_url`, no OAuth |

**Signal**: Codex log shows `Error sending request for url (https://auth.openai.com/oauth/token)`.

**Fix** — Change `model_provider = "codex"` to `model_provider = "transform"` and rename the provider section:
```toml
# ❌ wrong
model_provider = "codex"
[model_providers.codex]

# ✅ correct
model_provider = "transform"
[model_providers.transform]
```

#### cc-switch interaction
cc-switch (at `~/.cc-switch`) rewrites `~/.codex/config.toml` when switching Codex API providers. It:
1. Resets `model_provider` to `"codex"` (which breaks relays — see above)
2. Strips `env_key` from the provider section (causes `Missing environment variable`)

After every cc-switch API switch, you must re-apply the fix:
- `model_provider = "transform"` instead of `"codex"`
- Add `env_key = "OPENAI_API_KEY"` back if missing

See `hermes-agent/references/cc-switch-config-manager.md` for database schema, recovery from backups, and full interaction details.

### Relay models endpoint format

Some relays return models in OpenAI's new format (`{data: [...]}`) rather than the legacy format (`{models: [...]}`). Codex v0.130.0 expects the legacy format and logs:
```
failed to decode models response: missing field `models`
```

This is a **non-fatal warning** — Codex falls back to a local model catalog. The actual API calls still work fine. No action needed.

### `-c` flag workaround (when user-level config is unavailable)

If you can't use `~/.codex/config.toml` (see v0.130.0+ config split above), pass provider + model via `-c` on every invocation:

```bash
export OPENAI_API_KEY="sk-relay-key-here"
codex exec 'prompt' --yolo \
  -c model_provider=transform \
  -c 'model_providers.transform={name="transform",base_url="https://rsxermu666.cn/openai",wire_api="responses",requires_openai_auth=true,env_key="OPENAI_API_KEY"}' \
  -c model=gpt-5.4
```

### Windows env var gotcha

On Windows, PowerShell and git-bash have separate env var scopes:
- PowerShell: `$Env:OPENAI_API_KEY` / `[System.Environment]::SetEnvironmentVariable`
- git-bash: `$OPENAI_API_KEY` / `export OPENAI_API_KEY=...`

Even if you set a User-level env var via PowerShell, a git-bash terminal may need `export` to make it visible to Codex. Add `export OPENAI_API_KEY="..."` to `~/.bashrc` if running Codex from git-bash.

Some relays have separate base URLs per tool (e.g., Claude Code vs Codex CLI), and provide backup domains when the primary is blocked.

## One-Shot Tasks

```
terminal(command="codex exec 'Add dark mode toggle to settings'", workdir="~/project", pty=true)
```

For scratch work (Codex needs a git repo):
```
terminal(command="cd $(mktemp -d) && git init && codex exec 'Build a snake game in Python'", pty=true)
```

## Background Mode (Long Tasks)

```
# Start in background with PTY
terminal(command="codex exec --full-auto 'Refactor the auth module'", workdir="~/project", background=true, pty=true)
# Returns session_id

# Monitor progress
process(action="poll", session_id="<id>")
process(action="log", session_id="<id>")

# Send input if Codex asks a question
process(action="submit", session_id="<id>", data="yes")

# Kill if needed
process(action="kill", session_id="<id>")
```

## Key Flags

| Flag | Effect |
|------|--------|
| `exec "prompt"` | One-shot execution, exits when done |
| `--full-auto` | Sandboxed but auto-approves file changes in workspace |
| `--yolo` | No sandbox, no approvals (fastest, most dangerous) |

## PR Reviews

Clone to a temp directory for safe review:

```
terminal(command="REVIEW=$(mktemp -d) && git clone https://github.com/user/repo.git $REVIEW && cd $REVIEW && gh pr checkout 42 && codex review --base origin/main", pty=true)
```

## Removal / Cleanup (Windows)

Codex CLI can be installed through multiple package managers. To fully remove:

### 1. Uninstall from all package managers

```bash
# fnm/npm global (the active Node)
npm uninstall -g @openai/codex

# pnpm global (if present)
pnpm remove -g @openai/codex

# system Node.js (e.g. scoop nodejs-lts)
# Use the system npm directly:
/path/to/scoop/apps/nodejs-lts/current/npm.cmd uninstall -g @openai/codex
```

### 2. Remove config/data directory

```bash
rm -rf ~/.codex
```

### 3. Clean stale shims

```bash
# fnm multishell stale symlinks (created by previous sessions)
find /c/Users/$USER/AppData/Local/fnm_multishells -name 'codex' -type f -delete

# pnpm shims
rm -f /c/Users/$USER/AppData/Local/pnpm/codex*

# system npm shims (Roaming)
rm -f /c/Users/$USER/AppData/Roaming/npm/codex*
```

### 4. Fix PowerShell profile if it hardcodes a path

Edit `$HOME\Documents\PowerShell\profile.ps1` — replace hardcoded paths with `Get-Command` (see PowerShell Profile Integration above).

### 5. Verify

```bash
which codex  # should return nothing
```

## Parallel Issue Fixing with Worktrees

```
# Create worktrees
terminal(command="git worktree add -b fix/issue-78 /tmp/issue-78 main", workdir="~/project")
terminal(command="git worktree add -b fix/issue-99 /tmp/issue-99 main", workdir="~/project")

# Launch Codex in each
terminal(command="codex --yolo exec 'Fix issue #78: <description>. Commit when done.'", workdir="/tmp/issue-78", background=true, pty=true)
terminal(command="codex --yolo exec 'Fix issue #99: <description>. Commit when done.'", workdir="/tmp/issue-99", background=true, pty=true)

# Monitor
process(action="list")

# After completion, push and create PRs
terminal(command="cd /tmp/issue-78 && git push -u origin fix/issue-78")
terminal(command="gh pr create --repo user/repo --head fix/issue-78 --title 'fix: ...' --body '...'")

# Cleanup
terminal(command="git worktree remove /tmp/issue-78", workdir="~/project")
```

## Batch PR Reviews

```
# Fetch all PR refs
terminal(command="git fetch origin '+refs/pull/*/head:refs/remotes/origin/pr/*'", workdir="~/project")

# Review multiple PRs in parallel
terminal(command="codex exec 'Review PR #86. git diff origin/main...origin/pr/86'", workdir="~/project", background=true, pty=true)
terminal(command="codex exec 'Review PR #87. git diff origin/main...origin/pr/87'", workdir="~/project", background=true, pty=true)

# Post results
terminal(command="gh pr comment 86 --body '<review>'", workdir="~/project")
```

## Rules

1. **Always use `pty=true`** — Codex is an interactive terminal app and hangs without a PTY
2. **Git repo required** — Codex won't run outside a git directory. Use `mktemp -d && git init` for scratch
3. **Use `exec` for one-shots** — `codex exec "prompt"` runs and exits cleanly
4. **`--full-auto` for building** — auto-approves changes within the sandbox
5. **Background for long tasks** — use `background=true` and monitor with `process` tool
6. **Don't interfere** — monitor with `poll`/`log`, be patient with long-running tasks
7. **Parallel is fine** — run multiple Codex processes at once for batch work

## Troubleshooting

### Missing environment variable (`Missing environment variable: OPENAI_API_KEY`)

The relay config has `env_key = "OPENAI_API_KEY"` but Codex can't find that variable in its shell environment.

1. **If running from git-bash (MSYS2)** — `$Env:OPENAI_API_KEY` is PowerShell syntax. Use `export OPENAI_API_KEY="sk-..."` instead. Add to `~/.bashrc` for persistence.
2. **If running from PowerShell** — Set via `$env:OPENAI_API_KEY = "sk-..."` before invoking codex.
3. **If set as a User env var** — Restart the terminal session so it picks up the new value.
4. **Verify** — `echo $OPENAI_API_KEY` (bash) or `echo $env:OPENAI_API_KEY` (PowerShell) should print the key.

### Missing env var for desktop app

The Codex **desktop app** (not CLI) is a separate process that doesn't inherit PowerShell profile or `.bashrc` environment variables. Even if `codex` CLI works from terminal, the desktop app may fail with `Missing environment variable: OPENAI_API_KEY`.

**Fix** — Set a User-level (registry-persisted) environment variable:
```powershell
[System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-...", "User")
```
Then **fully restart** the Codex desktop app. User-level env vars are inherited by new processes at startup.

For the desktop app's project-level config, also ensure `env_key = "OPENAI_API_KEY"` is present in the provider definition (see relay config above).

### 401 Unauthorized / Missing environment variable

When Codex returns `401 Unauthorized` or `Missing environment variable: OPENAI_API_KEY`:

1. **The relay/platform generates its own keys** — If using a Chinese API relay, the key in `auth.json` is platform-generated (not your direct OpenAI key). It may have expired. Go back to the relay's dashboard and regenerate it.

2. **Missing `env_key` in config.toml** — Verify `~/.codex/config.toml` includes `env_key = "OPENAI_API_KEY"` under the provider section. Without it, Codex doesn't know which env var to read:

   ```toml
   [model_providers.<name>]
   name = "..."
   base_url = "..."
   wire_api = "responses"
   requires_openai_auth = true
   env_key = "OPENAI_API_KEY"    # <-- this line is critical
   ```

3. **cc-switch overwrites config.toml without env_key** — When switching Codex API via cc-switch (a third-party config manager at `~/.cc-switch`), it rewrites `~/.codex/config.toml` and **strips the `env_key` field**. You must re-add it after every API switch:
   ```bash
   # Add env_key back after cc-switch switches API
   # Edit ~/.codex/config.toml and add:
   env_key = "OPENAI_API_KEY"
   ```

4. **User-level env var not set (Codex desktop app)** — Codex desktop app reads from Windows user environment variables (registry), not PowerShell profile or .bashrc. Set it persistently:
   ```powershell
   [System.Environment]::SetEnvironmentVariable("OPENAI_API_KEY", "sk-your-key", "User")
   ```
   Then **fully restart** the Codex desktop app (including tray).

5. **Test with curl** — Verify the relay and key separately:
   ```bash
   curl -s https://<relay>/openai/models -H "Authorization: Bearer $OPENAI_API_KEY"
   ```
   - HTTP 200 = relay + key work
   - HTTP 401 = key expired or invalid on the relay side
   - Connection failure = relay domain blocked; try backup domain

6. **Try the backup domain** — Most relays provide fallback domains (e.g., `bxcv.store` as backup for `rsxermu666.cn`). Switch `base_url` to the backup.

### Connection Failures (No Route to Host)

- Chinese relays are frequently blocked by ISPs. Use the relay's status page or tutorial page to find working backup domains.
- Check whether the relay's tutorial/status page lists currently active domains.
- Some relays use Cloudflare for DDoS protection — occasional timeouts are normal; retry.
