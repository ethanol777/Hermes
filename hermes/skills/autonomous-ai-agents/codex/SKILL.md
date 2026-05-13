---
name: codex
description: "Delegate coding to OpenAI Codex CLI (features, PRs) — plus install, integrate, and clean up on Windows/fnm."
version: 1.2.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [Coding-Agent, Codex, OpenAI, Code-Review, Refactoring, Windows, fnm]
    related_skills: [claude-code, hermes-agent]
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
