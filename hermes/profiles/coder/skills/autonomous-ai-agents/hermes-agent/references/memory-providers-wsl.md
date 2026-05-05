# Memory Provider Selection on WSL

Hermes offers pluggable memory providers. On WSL (especially without sudo), constraints differ from native Linux. This guide covers provider selection, setup, and architecture.

## Quick Decision Matrix

| Provider | Requires | WSL Viable? | Best For |
|----------|----------|-------------|----------|
| **Holographic** ⭐ | SQLite (built-in) | ✅ Zero deps | Local-only, no-infra setups |
| Honcho (cloud) | API key, internet | ✅ | Full user modeling |
| Honcho (self-hosted) | Docker + PostgreSQL + build | ❌ Needs sudo | — |
| mem0 | API key / local LLM | ⚠️ Needs API key | Alternative to Honcho |
| openviking | API key + endpoint | ⚠️ If configured | Cloud-backed memory |
| byterover | API key | ⚠️ | Specialized |
| hindsight | API key / local | ⚠️ | Alternative |
| supermemory | API key | ⚠️ | — |

## Why Holographic for WSL (No Sudo)

WSL without sudo can't run Docker, systemd services, or PostgreSQL. Honcho self-hosted requires all three (Docker Compose → build from source → PostgreSQL + pgvector + Redis). Holographic uses SQLite — always available, zero setup.

## Multi-Layer Memory Architecture

A robust memory system uses layered storage with different retention policies:

```
Layer 1: Built-in (MEMORY.md / USER.md)
  Fast always-on, character-limited (2200/1375). Hot facts only.
  
Layer 2: Holographic (SQLite + FTS5 + HRR vectors)
  Unlimited storage, semantic search, entity resolution, trust scoring.
  
Layer 3: .learnings/ (LEARNINGS.md / ERRORS.md / FEATURE_REQUESTS.md)
  Permanent knowledge warehouse. High-value learnings → extracted as skills.
```

## Setup: Holographic

```bash
# 1. Set provider (honcho-ai must be installed for the plugin)
hermes config set memory.provider holographic

# 2. Add plugin config for auto-extraction (in config.yaml):
# plugins:
#   hermes-memory-store:
#     auto_extract: true
#     default_trust: 0.5
#     hrr_dim: 1024

# 3. Verify
hermes memory status
# → Provider: holographic, Status: available ✓
```

### Config Reference

| Key | Default | Description |
|-----|---------|-------------|
| `db_path` | `$HERMES_HOME/memory_store.db` | SQLite database path |
| `auto_extract` | `false` | Auto-extract facts at session end |
| `default_trust` | `0.5` | Default trust score for new facts |
| `hrr_dim` | `1024` | HRR vector dimensions |

## Available Tools

Once Holographic is active, these tools become available:

| Tool | Description |
|------|-------------|
| `fact_store` | 9 actions: add, search, probe, related, reason, contradict, update, remove, list |
| `fact_feedback` | Rate facts as helpful/unhelpful (trains trust scores) |

### fact_store Usage Patterns

```python
# Store a fact about the user
fact_store(action='add', content='User prefers terse responses', category='user_pref', tags='style,preference')

# Search by keyword
fact_store(action='search', query='WSL network config')

# Probe: all facts about an entity
fact_store(action='probe', entity='feishu')

# Reason: find facts connecting multiple entities
fact_store(action='reason', entities=['gateway', 'feishu'])

# Contradiction detection
fact_store(action='contradict', entity='deployment_method')
```

### Trust Scoring

Each fact has a trust score (0.0–1.0). Use `fact_feedback` to train:

```python
fact_feedback(action='helpful', fact_id=5)   # +trust
fact_feedback(action='unhelpful', fact_id=5) # -trust
```

Pass `min_trust=N` (default 0.3) to filter low-confidence facts in searches.

## Pitfalls

- **Plugin must exist before provider switch**: `hermes config set memory.provider holographic` requires the `holographic` plugin directory to exist in `~/.hermes/hermes-agent/plugins/memory/holographic/`. If missing, reinstall Hermes or verify the plugin was shipped with your version.
- **No automatic migration**: Switching providers discards facts stored in the old provider's backend. Built-in memory (MEMORY.md/USER.md) survives independently.
- **Honcho cloud from China**: Accessible (tested: returns 401/403 which means server is reachable), but latency may be higher. Self-hosted Honcho is not viable on WSL without sudo.
- **auto_extract interaction**: With `auto_extract: true`, facts are written at session end, not in real-time. This means the current session never sees facts it extracted — they surface on the next session.
