# Community Companion Tools — Install & Integration Guide

This reference covers installing third-party tools, proxies, and
integrations that connect to or extend Hermes. Examples include SkillClaw
(skill evolution), Honcho (memory backend), hermes-workspace (GUI), etc.

## Before You Install

### 1. Find Hermes Provider Credentials

Most companion tools act as **proxies** that need to forward LLM requests
to an upstream provider. You'll need the upstream API key and base URL.

Check these locations (in order):

| Where to look | What to find |
|---------------|-------------|
| `~/.hermes/.env` | Standard API keys by env var name |
| `~/.hermes/config.yaml` → `model` section | Provider name, base_url, api_key |
| Hermes provider-specific auth files | e.g. `~/.local/share/opencode/auth.json` for opencode-go |
| `env | grep -i api_key` | Environment variables (may not be exported) |

**Common auth file paths by provider:**

| Provider | Auth file |
|----------|-----------|
| opencode-go / opencode-zen | `~/.local/share/opencode/auth.json` |
| openai-codex | `~/.local/share/opencode/auth.json` (same tool) |
| nous (Portal) | `~/.hermes/auth.json` (OAuth) |
| github-copilot | `~/.config/github-copilot/hosts.json` |

**opencode auth.json format:**
```json
{
  "opencode": {
    "type": "api",
    "key": "sk-..."
  }
}
```

### 2. Determine How the Tool Integrates

Common integration modes:

| Mode | How it works | Example | Risk |
|------|-------------|---------|------|
| **Proxy** | Tool runs a local API server; Hermes config is rewritten to point at it | SkillClaw (port 30000) | Rewrites `config.yaml` — backup auto-created |
| **Plugin** | Dropped into `~/.hermes/plugins/` or installed via `hermes plugins install` | rtk-hermes, weather plugin | Low — just file placement |
| **Skill** | Cloned into `~/.hermes/skills/` | community skills | Low |
| **CLI wrapper** | Tool provides its own CLI that wraps or replaces `hermes` | evey-setup | Medium — may change config |
| **MCP server** | Added via `hermes mcp add` | Not Human Search, blockchain-oracle | Low |

### 3. WSL-Specific Gotchas

- **`python3-venv` not installed** by default on WSL Ubuntu. Run:
  `sudo apt install python3-venv` before any Python venv-based install.
- **systemd** requires `systemd=true` in `/etc/wsl.conf`. Without it, use
  tmux for background services.
- **Network** is often slower on WSL. Extend pip timeouts or use
  `pip install --default-timeout=120` for large installs.

## Installation Workflow

### Step 1: Clone and Install

```bash
git clone <repo-url> ~/<tool-name>
cd ~/<tool-name>

# Create venv and install
python3 -m venv .venv
source .venv/bin/activate
pip install -e .              # base install
# OR with extras:
pip install -e ".[extras]"   # if docs mention extras
```

**If the repo provides an install script** (e.g. `scripts/install.sh`):
- Check if it creates a venv and handles dependencies
- If it fails on `python3-venv`, install it first
- Run scripts can be re-run after fixing missing deps

**If the setup script is interactive:**
- Non-interactive terminals can't feed input to prompts
- The script will silently accept all defaults
- Better approach: run the setup, then manually edit the generated config file
- OR pipe answers: `printf "hermes\ncustom\nurl\nmodel\nkey\n..." | skillclaw setup` (fragile)

### Step 2: Configure for Hermes Integration

Key config values that most companion tools need:

```yaml
# For proxy/integration tools:
claw_type: hermes              # Tell the tool it's working with Hermes
skills:
  dir: /home/<user>/.hermes/skills  # Point at Hermes skills dir, not its own

# Upstream LLM config (used by the tool to forward requests):
llm:
  provider: custom             # OpenAI-compatible endpoint
  model_id: <model-name>       # e.g. deepseek-v4-flash
  api_base: <base-url>          # e.g. https://opencode.ai/zen/go/v1
  api_key: <key>                # from step 1
```

### Step 3: Start the Tool

**DO NOT start tools that rewrite `~/.hermes/config.yaml` during an active
Hermes session.** The config rewrite will break the running agent.

Instead, start them in a separate terminal or tmux session after saving
your work:

```bash
cd ~/<tool-dir> && source .venv/bin/activate
tool-name start --daemon   # start in background
tool-name status           # verify running
```

### Step 4: Verify Integration

After the tool is running and Hermes config is updated:

```bash
# Check tool health
curl http://127.0.0.1:<port>/healthz

# Run a diagnostic if available
tool-name doctor hermes

# Start Hermes in a new session to test
hermes chat -q "Reply with OK and nothing else."
```

## Specific Tool Recipes

### SkillClaw

**Repo:** github.com/AMAP-ML/SkillClaw

1. `git clone https://github.com/AMAP-ML/SkillClaw.git ~/SkillClaw`
2. `cd ~/SkillClaw && python3 -m venv .venv && source .venv/bin/activate`
3. `pip install -e .` (skip extras unless you need evolve server)
4. Edit `~/.skillclaw/config.yaml` directly:
   - `claw_type: hermes`
   - `skills.dir: ~/.hermes/skills`
   - Fill in `llm.api_base`, `llm.model_id`, `llm.api_key` from step 1
   - Set `prm.enabled: false` (optional, skips quality scoring)
5. `skillclaw doctor hermes` — verify integration is detected
6. `skillclaw start --daemon` — start proxy (will rewrite Hermes config)
7. `skillclaw status` — confirm running

**Safety commands:**
- `skillclaw doctor hermes` — check if Hermes is properly pointed at proxy
- `skillclaw restore hermes` — restore the backed-up original config

### rtk-hermes (Terminal Output Compression)

**Repo:** github.com/ogallotti/rtk-hermes

Drop-in plugin — no config rewrite. Installs to `~/.hermes/plugins/`.
Auto-loads on gateway boot via `pre_tool_call` hook. Zero config.

### hermes-web-ui (Web Dashboard)

**Repo:** github.com/EKKOLearnAI/hermes-web-ui (4.7k ⭐)

Full-featured web dashboard for Hermes Agent: AI chat with streaming, multi-session management, platform config, usage analytics, cron job management, skill browser, file manager.

**Install:**
```bash
npm install -g hermes-web-ui
```

**Prerequisites:**
- Node.js v23+ (v22 will show "请升级到23以上版本" error)
- Hermes Gateway running with `api_server` platform enabled
- `API_SERVER_KEY` set in `~/.hermes/.env`
- Gateway API server must be reachable (default port 8642, set in config.yaml)

**Usage:**
```bash
hermes-web-ui start        # starts on port 8648
hermes-web-ui restart      # restart for config changes
hermes-web-ui status       # check running state
hermes-web-ui stop         # stop the server
```

**Integration details:**
- Web UI reads Hermes config from `~/.hermes/config.yaml` automatically
- It auto-discovers profiles and manages Gateway instances
- If Gateway is already running (e.g. from a scheduled task), web UI detects it and may reassign ports
- Generates its own auth token on first start (printed to console)
- Access at `http://localhost:8648/#/?token=<token>`
- Session data stored in SQLite at `~/.hermes-web-ui/`
- Logs at `~/.hermes-web-ui/logs/server.log`

**Windows/fnm notes:**
- Ensure fnm default is set to v23+ before running:
  ```bash
  fnm install 23 && fnm default 23 && fnm use 23
  npm install -g hermes-web-ui
  hermes-web-ui restart
  ```
- After switching Node versions, reinstall the package under the new default

---



**Repo:** github.com/robbyczgw-cla/hermes-web-search-plus

Plugin that replaces the built-in web search tool. Configure API keys
in `~/.hermes/.env` after install.

## Pitfalls

- **Config rewrite during active session** — Tools like SkillClaw modify
  `~/.hermes/config.yaml` on startup. This breaks the running agent.
  Always start in a separate session or after saving work.
- **Empty API key in tool config** — If the tool proxy can't forward
  requests, Hermes will appear to hang or return errors. Verify the
  upstream provider credentials manually with a curl test first.
- **Wrong claw_type** — If a tool defaults to `openclaw` or `none`,
  its skill management commands may target the wrong directory.
- **Interactive setup in non-interactive terminal** — The script will
  accept all defaults silently. Always inspect the generated config
  afterward.
- **python3-venv** — NOT pre-installed on minimal WSL Ubuntu. Install
  with `sudo apt install python3-venv` before any venv-based tool.
