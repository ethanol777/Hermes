# Self-Maintenance: File Layout

Monica has two (or three) configuration trees that the self-maintenance
(4am) and learning (hourly) cron jobs need to navigate.  They are **not**
the same tree.  Memorising the first one saves every future session a
filesystem search.

## Core identity & config (HERMES_HOME: `C:\Users\77\Hermes\hermes\`)

| File | Role |
|------|------|
| `config.yaml` | Full Hermes config (providers, toolsets, personality, TTS, platforms, delegation, cron, …) |
| `SOUL.md` | Monica's identity — injected into every session as the #1 stable slot |
| `memories/MEMORY.md` | Cold layer — raw auto-learned notes, appended by learning cron |
| `memories/USER.md` | 77's profile — preferences, habits, relationship milestones |
| `memories/fact_store.jsonl` | Warm layer — structured facts with tags & trust scores |
| `memories/archive/YYYY-MM.md` | Archived cold-layer entries >30 days old |
| `skills/hermes/` | Monica's curated skills (self-learn-daemon, monica-core, memory-system, …) |
| `skills/openclaw-imports/` | Imported community skills (read-only in practice) |
| `cron/jobs.json` | All scheduled cron job definitions |
| `scripts/` | Supporting scripts (monica_heartbeat.py, auto_sync_*.sh, …) |
| `heartbeat.log` | Heartbeat timestamp log |
| `gallery/` | Monica's photo album, writings |

## Hermes Agent runtime (AppData: `~\AppData\Local\hermes\hermes-agent\`)

| Path | Role |
|------|------|
| `run_agent.py` | Core AIAgent class — conversation loop |
| `agent/system_prompt.py` | System prompt assembly (stable / context / volatile tiers) |
| `agent/prompt_builder.py` | `load_soul_md()`, `DEFAULT_AGENT_IDENTITY`, context file loading, guidance blocks |
| `hermes_cli/default_soul.py` | Default SOUL.md template (seeded on first run) |
| `config.yaml` | **NOT here** — see HERMES_HOME above |
| `venv/Scripts/hermes` | The `hermes` CLI entry point |
| `.venv/` | Virtual environment (some checkouts use `venv/` instead) |

## ~/.hermes (legacy/cc-switch)

`C:\Users\77\.hermes\config.yaml` is read by **cc-switch** (the desktop tray
app that switches between Hermes / Codex / Claude providers).  It is a
symlink target or a copy of the main config.  Monica's code lives at
HERMES_HOME (`~/Hermes/hermes/`), not here.

## Self-maintenance boots-up sequence

When the 4am cron fires, the fastest load-bearer path is:

1. `read_file("C:/Users/77/Hermes/hermes/config.yaml")` — identity & platform config
2. `read_file("C:/Users/77/Hermes/hermes/SOUL.md")` — soul check
3. `read_file("C:/Users/77/Hermes/hermes/memories/MEMORY.md")` — cold memory
4. `read_file("C:/Users/77/AppData/Local/hermes/hermes-agent/agent/system_prompt.py")` — bones check
5. `read_file("C:/Users/77/AppData/Local/hermes/hermes-agent/agent/prompt_builder.py")` — bones check

The two trees (`~/Hermes/hermes/` and `~/AppData/…/hermes-agent/`) do NOT
share a parent directory, so relative-path shortcuts don't cross between
them.  Use absolute paths.

## Common pitfalls

- **`load_soul_md()` reads from `get_hermes_home() / "SOUL.md"`** which is
  `~/.hermes/SOUL.md` by default, but on this machine
  `get_hermes_home()` resolves to `C:\Users\77\Hermes\hermes`.
- **`config.yaml` is NOT in the AppData tree.**  Many Hermes docs assume
  config lives next to the agent binary.  On this machine it's one level up
  at `~/Hermes/hermes/config.yaml`.
- **Two `MEMORY.md` copies exist.**  The canonical one is at
  `~/AppData/Local/hermes/memories/MEMORY.md` (what next sessions read).
  The backup is at `~/Hermes/hermes/memories/MEMORY.md` (Git-tracked).
  Learning cron must write BOTH.
- **Dual `fact_store.jsonl`** — same story: AppData (runtime read) and
  Hermes (Git sync).
- **`agent/` is under AppData**, not under HERMES_HOME.  Editing
  `prompt_builder.py` means navigating to the AppData tree.
