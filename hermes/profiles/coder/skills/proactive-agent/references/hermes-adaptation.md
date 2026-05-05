# Proactive Agent × Hermes: Adaptation Notes

This skill is designed for **OpenClaw** but its concepts work on **Hermes Agent** with adjustments.

## Workspace Mapping

| OpenClaw File | Hermes Equivalent | Notes |
|---------------|-------------------|-------|
| `SOUL.md` | `~/.hermes/workspace/SOUL.md` | Created manually or via onboarding |
| `USER.md` | `~/.hermes/workspace/USER.md` | Created during onboarding |
| `ONBOARDING.md` | `~/.hermes/workspace/ONBOARDING.md` | Created and tracked per session |
| `AGENTS.md` | Not directly supported | Adapt rules into skill SKILL.md or memory |
| `MEMORY.md` | Hermes `memory` tool | Use `memory(action='add')` for persistent facts |
| `TOOLS.md` | `~/.hermes/config.yaml` | Tool config goes in Hermes config, not a workspace file |
| `HEARTBEAT.md` | Not directly supported | No cron-based heartbeat in Hermes |
| `SESSION-STATE.md` | N/A | Hermes has built-in session state; not needed |
| `memory/YYYY-MM-DD.md` | `session_search` | Transcripts persist across sessions; use `session_search` to retrieve |

## Onboarding Workflow (Tested on Hermes)

1. Copy `assets/SOUL.md`, `assets/USER.md`, `assets/ONBOARDING.md` templates from the skill to `~/.hermes/workspace/`
2. Read `ONBOARDING.md` — it has 12 core questions about the user
3. Ask the user in batches of 3-4 questions to keep it conversational
4. After all answers collected:
   - Create `USER.md` from answers
   - Create `SOUL.md` from the template + agent's identity
   - Mark `ONBOARDING.md` state → `complete`
5. Save durable facts to Hermes memory: `memory(action='add', target='user', content='...')`

## Key Differences from OpenClaw

- **No automatic injection**: OpenClaw injects workspace files into every session context. Hermes does not — the agent must actively load/skill_view the proactive-agent skill and read SOUL.md/USER.md at session start.
- **Memory tool replaces manual files**: Instead of daily memory files, use Hermes' built-in `memory` tool. It persists across sessions automatically.
- **No hooks/activators**: Hermes doesn't support OpenClaw-style hook scripts. Rely on SOUL.md rules and memory for behavioral guidance.
- **Cron system**: Hermes has its own `hermes cron` system, not OpenClaw's `systemEvent`/`agentTurn`. Use `hermes cron add` for autonomous scheduled tasks.

## Best Practices for Hermes

1. At session start, do `skill_view(name='proactive-agent')` to load the skill
2. Read `~/.hermes/workspace/SOUL.md` and `~/.hermes/workspace/USER.md` for context
3. Use `memory(action='add')` for important facts the agent should never forget
4. Use `session_search` to recall past conversations
5. When corrections happen, log to `.learnings/` AND update memory
