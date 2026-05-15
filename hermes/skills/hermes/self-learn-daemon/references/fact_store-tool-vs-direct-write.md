# fact_store Tool vs Direct JSONL Write

## The Problem

In the 2026-05-15 late learning session, I (Monica) bypassed the `fact_store(action='add')` tool and wrote new entries directly to `fact_store.jsonl` using `write_file` / `patch`. This works mechanically (the data is there) but loses several benefits:

1. **No deduplication** — the tool checks if a similar fact already exists; direct write risks duplicates.
2. **No trust scoring** — `fact_store` tool manages trust decay (`trust_delta`); direct write leaves the `confidence` field hardcoded with no decay.
3. **No entity resolution** — the `fact_store` tool connects facts to entities (people, projects, concepts) for later `probe`/`reason` queries.
4. **No category/tag normalization** — the tool enforces the category enum (`user_pref`, `project`, `tool`, `general`) and validates tag syntax.

## When to Use What

| Method | When | Why |
|--------|------|-----|
| `fact_store(action='add')` | **Default**. Every cron run. | Proper dedup, trust scoring, entity linking. |
| Direct write to jsonl | **Only as fallback** when `fact_store` tool is genuinely unavailable (e.g. tool removed from available list mid-session). | File write always works. But no metadata management. |

## How to Properly Add Facts in Cron

```python
# CORRECT (use fact_store tool):
fact_store(
    action='add',
    content='...',
    category='general',
    tags='timely,security,automotive,privacy',
    trust_delta=0.5
)

# WRONG (direct file manipulation):
write_file(path='fact_store.jsonl', content=json.dumps({...}))
```

## Real Impact

The 7 facts written directly in the 2026-05-15 session (fs_019 through fs_025) are "dumb" records — they exist but won't be found by entity probes, won't have their trust managed, and could cause duplicates on subsequent writes. A future cleanup could re-import them through `fact_store(action='add')` with their existing IDs overwritten.

## Note

In the sandbox/execute_code Python environment, tools are not available — direct file write is the only option if you need to write facts from inside a Python script. In that case, write a structured markdown fact log instead of directly mutating the JSONL file, and re-add through `fact_store` in a subsequent tool call:

```python
# Fallback from execute_code:
write_file(
    "pending_facts_2026-05-15.md",
    "- fact: ...\n  tags: ...\n- fact: ...\n  tags: ...\n"
)
# Then in next tool call:
# fact_store(action='add', ...) for each line
```
