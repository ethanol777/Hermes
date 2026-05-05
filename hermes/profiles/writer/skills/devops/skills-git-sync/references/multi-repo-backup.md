# Multi-Repo Auto Backup

Pattern for auto-syncing multiple Hermes config directories to GitHub using a single umbrella repo with submodules, triggered by a periodic cron job.

## Structure

```
~/Hermes/                        # Umbrella repo (github.com/ethanol777/Hermes)
├── config/         ← submodule: github.com/ethanol777/hermes-config    (~/.hermes/ safe files)
├── skills/         ← submodule: github.com/ethanol777/hermes-skills   (~/.hermes/skills/)
├── learnings/      ← submodule: github.com/ethanol777/hermes-learnings (~/.learnings/)
├── agentic-stack/  ← submodule: github.com/ethanol777/agentic-stack   (~/agentic-stack/)
└── README.md
```

Clone: `git clone --recurse-submodules https://github.com/ethanol777/Hermes.git`

## Setup

Each runtime directory is a separate git repo pointing to its own GitHub remote:

| Directory | Remote |
|-----------|--------|
| `~/.hermes/` | `ethanol777/hermes-config` |
| `~/.hermes/skills/` | `ethanol777/hermes-skills` |
| `~/.learnings/` | `ethanol777/hermes-learnings` |
| `~/agentic-stack/` | `ethanol777/agentic-stack` |

The umbrella repo `~/Hermes/` has all four as submodules. After pushing changes to any sub-repo, update the umbrella:

```bash
cd ~/Hermes
git add -A && git commit -m "update submodule pointers" && git push
```

## Secrets Handling

`~/.hermes/.gitignore` excludes sensitive files before `git add -A`:

```gitignore
# Secrets
.env
auth.json
channel_directory.json
feishu_seen_message_ids.json

# Runtime data
state.db*  
models_dev_cache.json
*.lock
gateway*.pid

# Cache/temp
cache/ checkpoints/ logs/ memories/ cron/
node/ bin/ hooks/ sessions/
```

The `config.yaml` itself is safe (API keys stored in `.env`, not inline). Always verify with `git status --short` before pushing.

Also ignore sub-repos that are independently git-controlled:
```gitignore
hermes-agent/
skills/
```

## Auto-Sync Cron Job

Script: `~/.hermes/scripts/auto_sync.sh`

```bash
#!/bin/bash
set -e
REPOS=(
  "$HOME/.hermes"
  "$HOME/.hermes/skills"  
  "$HOME/.learnings"
  "$HOME/agentic-stack"
  "$HOME/Hermes"
)
for repo in "${REPOS[@]}"; do
  [ ! -d "$repo/.git" ] && continue
  cd "$repo"
  [ -z "$(git status --porcelain)" ] && continue
  git add -A
  git commit -m "auto-sync $(date '+%Y-%m-%d %H:%M')"
  git push 2>&1 || echo "push failed for $repo"
done
```

Schedule via Hermes cron (every 30m):

```bash
# Created via cronjob action — not crontab directly
# Name: "自动同步 Hermes 配置到 GitHub"
# Schedule: every 30m
# Script: auto_sync.sh (relative to ~/.hermes/scripts/)
```

## Credential Setup (WSL Headless)

```bash
git config --global credential.helper store
# ~/.git-credentials contains: https://USER:PAT@github.com
chmod 600 ~/.git-credentials
```

## Pitfalls

- **Submodules are independent** — pushing a sub-repo does NOT auto-update the umbrella. The cron script handles this: pushes sub-repos first, then umbrella.
- **New machine setup** — clone with `--recurse-submodules`. Runtime dirs (`~/.hermes/`, `~/.learnings/`) must be symlinked or the Hermes repo cloned directly to the expected paths.
- **Push conflicts** — if another device pushed first, `git pull --rebase` then push.
- **Cron job stopped** — check `cronjob action=list` to verify it's still scheduled.
