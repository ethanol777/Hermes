# Auto-Learned Cold Layer File Layout (2026-05-19)

## Active File Locations

| Layer | Path | Purpose | Format | Size |
|-------|------|---------|--------|------|
| **Cold (冷层)** | `hermes-agent/MEMORY.md` | Auto-learned diary entries, with `§` separators and `YYYY-MM-DD auto-learned: [Topic]` headings | Markdown with `§` section breaks | ~1210 lines (2026-05-19) |
| **Warm (温层)** | `memories/fact_store.jsonl` | Structured facts with JSONL format, one fact per line with id/fact/source/date/tags/confidence | JSONL (JSON Lines) | fs_001 through fs_125+ (2026-05-19) |
| **Other notes** | `memories/MEMORY.md` | Non-auto-learned content (77's skincare routine, TTS research notes, etc.) | Markdown freeform | ~2 lines (2026-05-19) |

## Key Distinctions

**DO NOT assume `memories/MEMORY.md` and `hermes-agent/MEMORY.md` are duplicates.**
- They are two different files serving different purposes
- `hermes-agent/MEMORY.md` = auto-learned cold layer (prefixed with `§` and auto-learned headers)
- `memories/MEMORY.md` = other notes (skincare, tool research, etc.)
- To tell them apart: read the first 5 lines and check the format

**The `fact_store.jsonl` is only at `memories/fact_store.jsonl`.**
- There is no secondary copy as of 2026-05-19
- Always use `execute_code` + Python `open('file.jsonl', 'a')` + `json.dumps()` for appending
- Never use `patch` on JSONL files (proven to truncate lines)

## Discovery Priority

When seeking the auto-learned cold layer MEMORY.md in a cron session:
1. Check CWD (`hermes-agent/MEMORY.md`) — most likely location
2. Check `$HERMES_HOME/memories/MEMORY.md` — possible alternate location, but may contain different content
3. Validate by format (auto-learned format vs freeform notes), not by path alone
