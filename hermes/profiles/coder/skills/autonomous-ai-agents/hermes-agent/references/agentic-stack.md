# Agentic-Stack Integration with Hermes Agent

[agentic-stack](https://github.com/codejunkie99/agentic-stack) is a portable AI agent memory and skills layer (`.agent/` folder) that can be shared across coding agents (Claude Code, Cursor, Windsurf, OpenCode, OpenClaw, Hermes, Codex, and others). It provides multi-tier memory (working/episodic/semantic/personal), built-in skills (skillforge, memory-manager, git-proxy, debug-investigator, deploy-checklist, data-layer, data-flywheel, design-md, tldraw), and a lessons system.

## Installation (Hermes adapter)

```bash
cd ~
git clone https://github.com/codejunkie99/agentic-stack.git
cd agentic-stack
./install.sh hermes
```

This creates:
- `.agent/` — the portable brain (memory, skills, tools, harness, protocols)
- `AGENTS.md` — instructions for Hermes to load `.agent/` as workspace context

## Key Tools

| Command | Purpose |
|---------|---------|
| `python3 .agent/tools/recall.py "<query>"` | Search lessons for relevant experience before tasks |
| `python3 .agent/tools/learn.py "<rule>" --rationale "<why>"` | Teach a persistent lesson |
| `python3 .agent/tools/show.py` | Show brain state (episodes, lessons, skills, candidates) |
| `python3 .agent/tools/memory_reflect.py <skill> <action> <outcome>` | Log action outcomes |
| `python3 .agent/memory/auto_dream.py` | Nightly compression: episodic → lesson candidates |

## Brain State Layout

```
.agent/
├── memory/
│   ├── working/      ← WORKSPACE.md (active task context)
│   ├── episodic/     ← daily activity log
│   ├── semantic/     ← LESSONS.md (accepted lessons)
│   └── personal/     ← PREFERENCES.md (user conventions)
├── skills/           ← built-in skills (agentskills.io format)
├── tools/            ← recall.py, learn.py, show.py, etc.
├── harness/          ← hook system (pre/post tool call)
├── protocols/        ← hard rules (permissions.md)
└── candidates/       ← staged lesson candidates (graduation queue)
```

## Usage Workflow

1. **Before non-trivial tasks:** `python3 .agent/tools/recall.py "<description>"` — the tool searches lessons.jsonl for relevant experience. If found, it prints "Consulted lessons for intent: ..." with matches.
2. **After significant actions:** `python3 .agent/tools/memory_reflect.py <skill> <action> <outcome>` — logs an episodic memory entry.
3. **Teaching a rule:** `python3 .agent/tools/learn.py "<rule>" --rationale "<why>"` — creates a candidate → auto-graduates to lesson if it passes heuristics.
4. **Quick state check:** `python3 .agent/tools/show.py`

## Pitfalls

### learn.py rejects pure Chinese text

The heuristic check `insufficient_content_words_0_of_3` counts English words only. A rule written entirely in Chinese will fail with exit code 2 and no graduation.

**Fix:** Mix in English keywords — the tool uses them as `conditions[]` for lexical matching during recall. Example:
```bash
# ❌ Fails
python3 .agent/tools/learn.py "用户偏好简洁直接"

# ✅ Works
python3 .agent/tools/learn.py "User prefers short direct responses. No flattery. 用户偏好简洁直接"
```

### Conditions array determines recall relevance

When a lesson graduates, the tool extracts English words from the rule as `conditions`. During recall, only lessons whose conditions overlap with the query are returned. Chinese-only conditions = no recall matches.

### AGENTS.md only loads when working inside the agentic-stack directory

Hermes reads `AGENTS.md` from the working directory. To benefit from the agentic-stack brain, you must be in `~/agentic-stack/` (or a project directory that has the `.agent/` folder and AGENTS.md).

### agentic-stack is very new

Project created April 2026, v0.13.0. Tools and structure may change. The `learn.py` heuristic is particularly fragile — check `exit_code` after calling it.
