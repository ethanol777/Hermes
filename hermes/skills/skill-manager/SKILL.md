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
- `skill-tree-sync.md` — automation for the skill tree index (`skills_tree_v2/index.yaml`)

## Skill Tree Structure

Skills are organized under `~/AppData/Local/hermes/skills_tree_v2/`:
- `index.yaml` — source of truth, all skills classified into 6 branches × 18 leaves
- `sync_tree.py` — automation: scan skills dir → diff with index → auto-classify new skills → update index

### Cleanup Workflow (When to Prune)

Run when user asks "are there unnecessary skills?" or proactively during routine maintenance.

**Prune signals (in order of certainty):**

1. **Empty references/examples dirs** — no SKILL.md, no sub-skill dirs → delete
2. **Empty skill dirs** — no SKILL.md, no sub-skill dirs, only DESCRIPTION.md → delete
3. **Platform mismatch** — skill for a platform the user doesn't use (e.g. Apple/macOS skills on Windows) → delete unless user wants to keep
4. **Duplicate skills** — two skills covering identical territory → delete the older/less-detailed one
5. **Overly niche verticals** — skills for industries or roles the user clearly doesn't work in → delete unless "just in case" is requested
6. **Old temporary outputs** — skill dirs named with timestamps (e.g. `ao-output/短篇小说创作-2026-05-02`) → delete
7. **No-content skill directories** — a top-level skill dir that contains only one sub-skill with the same name → fold the sub-skill up

**Cleanup steps:**
```
1. scan: ls ~/AppData/Local/hermes/skills/ | wc -l
2. diff: for each skill dir, check if SKILL.md exists
3. delete: rm -rf <empty_dirs>
4. rescan empty parent dirs: rmdir <now-empty_parent_dirs>
5. update index: python skills_tree_v2/sync_tree.py
   (falls back to manual edit of sync_tree.py CATEGORY_MAP if new skill doesn't auto-classify)
```

**After cleanup:**
- Update `skills_tree_v2/index.yaml` by re-running the classification scan
- Increment index version number
- The sync cron job (`skill-tree-sync`, every 6h) will pick up the next run automatically

### Skill Tree Branches (Current)

```
cognition (30)     — research, memory, learning
creation (36)      — writing, visual, audio, media
execution (115)    — coding, engineering, devops, data, testing
interaction (18)   — communication, platform
domain (124)      — business, gaming, creative, health, security
meta (41)         — self_management, system_control, evolution
Total: ~366 skills across 80 top-level directories
```

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
