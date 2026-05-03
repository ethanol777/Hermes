---
name: skills-git-sync
description: "Sync Hermes config, skills, and backups to GitHub — single repo, submodules, cron-driven auto-push."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [git, github, skills, sync, backup]
    related_skills: [github-auth, github-repo-management]
---

# Skills Git Sync

Skills live in `~/.hermes/skills/` which is already a git repository. This skill covers the workflow for uploading new/changed skills to GitHub and syncing across devices.

> For the broader multi-repo backup pattern (config + skills + learnings + agentic-stack under a single umbrella repo with cron-driven auto-push), see [`references/multi-repo-backup.md`](references/multi-repo-backup.md).

## Local Repo Configuration

```bash
cd ~/.hermes/skills
git remote -v
# → origin  https://github.com/ethanol777/hermes-skills.git (fetch/push)
git branch
# → * master
```

**Gitignore** (`~/.hermes/skills/.gitignore`): `.bundled_manifest`, `.curator_state`, `.usage.json`, `.hub/`, `skills_list*`

## Basic Upload Workflow

After creating or modifying skills (via `skill_manage(action='create')` or `skill_manage(action='patch')`):

```bash
cd ~/.hermes/skills

# 1. Check what changed
git status

# 2. Stage all changes
git add .

# 3. Commit with a descriptive message
git commit -m "feat: add <skill-name> skill"
# or  git commit -m "fix: update <skill-name> — fix xxx"
# or  git commit -m "chore: sync skill updates"

# 4. Push to GitHub
git push origin master
```

## Batch Sync (Multiple Changes at Once)

If you've created or updated several skills in one session, do a single commit:

```bash
cd ~/.hermes/skills && git add . && git commit -m "sync: update multiple skills" && git push
```

Or as a one-liner after any session that touched skills:

```bash
cd ~/.hermes/skills && git add -A && git commit -m "chore: auto-sync $(date +%Y-%m-%d)" && git push
```

## Commit Message Conventions

| Prefix    | When to use                                    |
|-----------|------------------------------------------------|
| `feat:`   | New skill created                              |
| `fix:`    | Bug fix or correction in a skill               |
| `chore:`  | Maintenance, refactoring, or bulk updates      |
| `sync:`   | Cross-device sync or batch commit              |
| `docs:`   | Skill documentation improvement                |

## Pulling on Another Device

```bash
cd ~/.hermes/skills
git pull origin master
```

Restart Hermes after pulling — skills are loaded at startup.

## Credential Handling (Headless / WSL)

In non-interactive environments (WSL terminal, background agent), `git push` will fail with:

```
fatal: could not read Username for 'https://github.com': No such device or address
```

**Set up credential storage:**

```bash
# 1. Store credentials on disk (persists across sessions)
git config --global credential.helper store

# 2. Create ~/.git-credentials with embedded PAT
echo "https://GITHUB_USERNAME:YOUR_TOKEN@github.com" > ~/.git-credentials
chmod 600 ~/.git-credentials

# 3. Verify — push should work without prompts
git push origin master
```

The token is stored in plaintext in `~/.git-credentials`. This is the standard git approach for headless environments.

**Alternative approaches:**
- **`gh` CLI**: if authenticated (`gh auth status`), git uses its OAuth token automatically. Run `gh auth setup-git` to configure.
- **Memory cache**: `git config --global credential.helper 'cache --timeout=28800'` — stores in memory for 8 hours (dies with the session).

> ⚠️ **Do NOT embed the token in the remote URL** as a permanent solution:
> `git remote set-url origin https://user:token@github.com/...`
> This exposes the token in `git remote -v` output and git logs. Use `credential.helper store` instead.

## Verification

After a push, verify on GitHub:
```bash
gh repo view ethanol777/hermes-skills
# or visit https://github.com/ethanol777/hermes-skills
```
Or check the latest commit locally:
```bash
cd ~/.hermes/skills && git log --oneline -3
```

## Pitfalls

- **Don't commit secrets** — the `.gitignore` excludes `.hub/` and state files, but check `git status` before `git add .` if you've added any credential files manually. The `.git-credentials` file is NOT in the skills repo, it's in your home directory.
- **"could not read Username" on push**: credential helper not configured. See Credential Handling section above.
- **Push rejected (non-fast-forward)**: if another device pushed first, `git pull --rebase origin master` then `git push`
- **Skills not appearing after pull**: the agent loads skills at session start. Use `skill_view(name)` to verify it loaded; if not, restart Hermes
- **Different remote** — if you set up a different GitHub repo, update the remote URL:
  ```bash
  git remote set-url origin https://github.com/YOUR_USER/YOUR_REPO.git
  ```
