> ⚠️ **雨晨的环境已迁移为单仓实文件模式。** 所有配置（config + skills + learnings + agentic-stack）归入 `~/Hermes/`（`github.com/ethanol777/Hermes`），每30分钟通过 `auto_sync.sh` 自动同步。以下历史文档仅作参考。

# Hermes Config Backup & Dotfiles Management (历史参考)

> 本节描述的是旧的多仓库模式（每个子目录独立 git 仓库）。当前模式见 `skills-git-sync` 技能中的 [`references/monorepo-setup.md`](link:skills-git-sync)（在技能 `skills-git-sync` 中）。

## Overview: Multi-Repo Layout

```
GitHub (ethanol777)
├── hermes-skills       ← ~/.hermes/skills/     (skills — agent-authored, already git)
├── hermes-config       ← ~/.hermes/            (config.yaml, SOUL.md, scripts)
├── hermes-learnings    ← ~/.learnings/         (self-improvement logs)
└── agentic-stack       ← ~/agentic-stack/      (portable brain fork)
```

Each directory is its own repo with its own `.gitignore`. No monorepo — keeps concerns separate so you can clone only what you need.

## Secret Hygiene

### Files that MUST be gitignored

These contain API keys, tokens, OAuth credentials, runtime state, peer IDs, and other sensitive or ephemeral data:

```
# Secrets
.env
auth.json
auth.lock
channel_directory.json
feishu_seen_message_ids.json

# Runtime state
state.db
state.db-shm
state.db-wal
models_dev_cache.json
ollama_cloud_models_cache.json
.skills_prompt_snapshot.json
gateway.lock / gateway.pid / gateway_state.json
processes.json

# Cache / logs / temporaries
cache/  checkpoints/  logs/  memories/
cron/   audio_cache/  image_cache/  images/
node/   bin/  hooks/  sessions/  sandboxes/
pastes/  pairing/  weixin/  workspace/
```

**Why config.yaml IS safe to push** (tested): The Hermes `providers: {}` section is empty by default — API keys live in `.env`, not inline. The config.yaml only contains model names, agent settings, platform configs, and other non-secret values. Double-check your own config before pushing.

### Submodules (embedded git repos)

`~/.hermes/skills/` and `~/.hermes/hermes-agent/` are git repos themselves. If you `git add -A` without a `.gitignore`, they get added as submodule entries (a single file reference, not their contents). The fix:

```bash
# Before first commit — add to .gitignore:
echo "skills/" >> .gitignore
echo "hermes-agent/" >> .gitignore

# If already staged:
git rm --cached -f skills hermes-agent
```

After that, `git add -A` will skip them.

## Creating a New Backup Repo on GitHub

Use the GitHub API directly (no `gh` CLI required). The PAT must have `repo` scope.

```bash
# Create repo
curl -s -H "Authorization: token <PAT>" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/user/repos \
  -d '{"name":"<repo-name>","description":"<description>","private":false}'

# If it fails with 422, the repo already exists — just use it.
```

### Checking the PAT

The GitHub PAT is stored in `~/.git-credentials`:
```
https://<user>:<pat>@github.com
```

The PAT must have `repo` (full control of private repos) scope at minimum to create repos. If you get a 401, regenerate the token in GitHub Settings → Developer settings → Personal access tokens.

## Full Setup Workflow (for a new backup)

```bash
# 1. .gitignore first (before any git add)
cat > .gitignore << 'EOF'
# ...see Secret Hygiene above...
EOF

# 2. Init
git init
git add -A

# 3. Unstage submodules if needed
git rm --cached -f skills/ 2>/dev/null
git rm --cached -f hermes-agent/ 2>/dev/null

# 4. Commit
git commit -m "chore: init <description>"

# 5. Create remote (see section above)
# 6. Push
git remote add origin https://github.com/<user>/<repo>.git
git push -u origin master
```

## Companion Backup Targets

### `~/.learnings/` — Self-Improvement Logs

Simple — no secrets, no submodules:
```bash
cd ~/.learnings
git init && git add -A && git commit -m "chore: init learning logs"
# create repo on GitHub, then:
git remote add origin https://github.com/<user>/hermes-learnings.git
git push -u origin master
```

### `~/agentic-stack/` — Portable Brain Fork

The agentic-stack is cloned from `codejunkie99/agentic-stack`. To push your personal lessons and config, fork it:

```bash
cd ~/agentic-stack

# Change remote to your fork
git remote set-url origin https://github.com/<user>/agentic-stack.git

# Add and commit local changes (.agent/ lessons, AGENTS.md, install.json)
git add -A
git commit -m "chore: personal config and learnings"
git push -u origin master
```

The upstream remote (if you want to pull updates):
```bash
git remote add upstream https://github.com/codejunkie99/agentic-stack.git
git fetch upstream
git merge upstream/master
```

## Restoring on a New Machine

```bash
# Clone the four repos
git clone https://github.com/ethanol777/hermes-config.git ~/.hermes
git clone https://github.com/ethanol777/hermes-skills.git ~/.hermes/skills
git clone https://github.com/ethanol777/hermes-learnings.git ~/.learnings
git clone https://github.com/ethanol777/agentic-stack.git ~/agentic-stack

# Recreate .env from secrets (never in git)
hermes setup
# or manually create ~/.hermes/.env with API keys
```
