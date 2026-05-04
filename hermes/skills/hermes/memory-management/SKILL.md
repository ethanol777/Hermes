---
name: memory-management
description: Multi-layered memory system for Hermes Agent — hot (built-in MEMORY.md/USER.md), warm (Holographic SQLite with FTS5+HRR), cold (.learnings/). Use for memory maintenance, cross-layer search, migration, and auto-extraction.
version: 1.0.0
author: Monica
tags: [memory, holographic, self-improvement, maintenance]
---

# Memory Management

Hermes uses a three-layer memory system:

| Layer | Store | Tool | Capacity | Latency |
|-------|-------|------|----------|---------|
| Hot | Built-in `memory` tool | `memory(action=add/replace/remove)` | 2200 chars | Instant (injected into every turn) |
| Warm | Holographic SQLite | `fact_store` + `fact_feedback` | Unlimited | Fast (FTS5 + HRR vector search) |
| Cold | `~/.learnings/` files | `session_search` + file tools | Unlimited | Slower (disk I/O) |

## When to use which

- **Hot memory**: Current project context, recent preferences, active corrections. Facts the user would reference in the same session.
- **Warm memory (Holographic)**: Durable facts about the user, environment, projects, tools. Use `fact_store(action='search')` or `fact_store(action='probe')` before answering questions about the user.
- **Cold memory (.learnings/)**: Historical errors, resolved issues, long-term best practices. Use `session_search` or read `~/.learnings/LEARNINGS.md` / `ERRORS.md` directly.

## Holographic fact_store operations

| Action | Description | Required params |
|--------|-------------|-----------------|
| `add` | Store a fact | `content`, optional: `category`, `tags` |
| `search` | FTS5 keyword search | `query`, optional: `category`, `min_trust`, `limit` |
| `probe` | All facts about an entity | `entity`, optional: `category`, `limit` |
| `related` | Structural adjacency | `entity`, optional: `category`, `limit` |
| `reason` | Facts connected to MULTIPLE entities | `entities` (list), optional: `category`, `limit` |
| `contradict` | Find conflicting facts | optional: `category`, `limit` |
| `update` | Modify a fact | `fact_id`, optional: `content`, `trust_delta`, `tags`, `category` |
| `remove` | Delete a fact | `fact_id` |
| `list` | Browse facts | optional: `category`, `min_trust`, `limit` |

## Auto-extraction

Holographic is configured with `auto_extract: true`. At session end, it scans user messages for:
- Preference patterns ("I prefer/like/use/want/need...", "my favorite...is...", "I always/never/usually...")
- Decision patterns ("we decided/agreed/chose...", "the project uses/needs/requires...")

Extracted facts get `category=user_pref` or `category=project`.

## Maintenance

A cron job runs daily at 3:00 AM (Asia/Shanghai) to:
1. Remove facts with trust_score < 0.3
2. Check built-in memory usage and offload if needed
3. Report database stats

## Memory flow

```
User says something important
  → Hot: I save to built-in memory tool (immediate context)
  → Warm: Holographic auto-extracts patterns at session end
  → Cold: I log errors/corrections to .learnings/ if systemic

I need to recall something
  → First: fact_store(action='probe') or fact_store(action='search') on Holographic
  → Then: memory tool to check hot memory
  → Finally: session_search or read .learnings/ files for cold history
```
