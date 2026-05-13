---
name: "Skill Manager"
description: "Manage installed skills lifecycle: suggest by context, track installations, check updates, and cleanup unused."
version: "1.0.3"
author: ivangdavila (ClawHub)
homepage: https://clawhub.ai/ivangdavila/skill-manager
license: MIT-0
metadata:
  hermes:
    tags: [skills, management, lifecycle]
linked_files:
  references:
    - suggestions.md
    - lifecycle.md
---

## Skill Lifecycle Management

Manage the full lifecycle of installed skills: discovery, installation, updates, and cleanup.

**Key insight — skills are not all the same type:**

| Type | Example | Install? | Lifecycle |
|------|---------|----------|-----------|
| **Tool skills** | github, weather, google-workspace | ✅ Install permanently | Track updates, remove if unused |
| **Bookshelf skills** | feynman, karpathy, luxun | 📚 Symlink, load on-demand | Keep installed but never auto-load |
| **Absorbed skills** | partner, crush, npy | ❌ Don't install | Read SKILL.md → extract essence → integrate into SOUL.md |
| **Active skills** | skill-manager, proactive-agent | ✅ Install | Auto-loaded, manage lifecycle |

**References:**
- `suggestions.md` — when to suggest skills based on current task
- `lifecycle.md` — installation, updates, and cleanup

---

## Scope

This skill ONLY:
- Suggests skills based on current task context
- Tracks installed skills in `~/skill-manager/inventory.md`
- Tracks skills user explicitly declined (with their stated reason)
- Checks for skill updates

This skill NEVER:
- Counts task repetition or user behavior patterns
- Installs without explicit user consent
- Reads files outside `~/skill-manager/`

---

## Hermes-Native Skill Management

Hermes has built-in tools for skill management:

| Action | Hermes Command / Tool |
|--------|----------------------|
| List installed skills | `skills_list()` |
| View skill content | `skill_view(name)` |
| Search ClawHub | `openclaw skills search <query> --json` |
| Install from ClawHub | `openclaw skills install <slug>` then copy to Hermes skills dir |
| Create skill | `skill_manage(action='create')` |
| Update skill | `skill_manage(action='patch'/action='edit')` |
| Delete skill | `skill_manage(action='delete')` |
| Sync to GitHub | `skills-git-sync` skill |

For ClawHub skills, use OpenClaw CLI: `openclaw skills install <slug>`, then copy to `~/.hermes/skills/` and verify with `skill_view()`.

---

## Context-Based Suggestions

When working on a task, notice the **current context**:
- User mentions specific tool (Stripe, AWS, GitHub) → check if skill exists
- Task involves unfamiliar domain → suggest searching
- User repeats a task type → there might be a skill for that

**How to check:**
1. Use `skills_list()` to see what's already installed
2. Suggest from what's missing vs what they need

This is responding to current context, not tracking patterns.

---

## Memory Storage

Inventory at `~/skill-manager/inventory.md`.

**First use:** `mkdir -p ~/skill-manager`

**Format:**
```markdown
## Installed
- slug@version — purpose — YYYY-MM-DD

## Declined
- slug — "user's stated reason"
```

**What is tracked:**
- Skills user installed (with purpose and date)
- Skills user explicitly declined (with their stated reason)

**Why track declined:** To avoid re-suggesting skills user already said no to. Only stores what user explicitly stated.
