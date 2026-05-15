# Agent Memory Architecture — 5-Layer Design

A multi-layered memory system to prevent "amnesia" (fact loss across sessions) in Hermes Agent.

## Why This Matters

LLM agents have no built-in long-term memory. Every session starts fresh. Without an intentional architecture:

- Facts pile up in a 2,200-char flat text block (the built-in `memory` tool)
- Old facts conflict with new ones with no dedup
- Semantic relationships between facts are invisible (no vector search)
- High-value lessons stay buried in raw session logs forever

## Architecture Overview

```
 Fast / Hot ──────────────────────────────────────→ Slow / Cold

Layer 1          Layer 2           Layer 3           Layer 4
┌────────┐       ┌────────┐       ┌─────────┐       ┌─────────┐
│ Built-in│ ←→  │ Honcho  │ ←→  │.learnings│ ←→  │ Chroma  │
│ Memory  │      │ Backend │      │ Logs     │      │ Vectors │
└────────┘       └────────┘       └─────────┘       └─────────┘
    ↑                ↑                ↑                 ↑
 Instantly       Semantic        Permanent         Semantic
 injected        search +        structured        retrieval
 every turn      user model      knowledge         (RAG)

Layer 5: Cron automation (glue that keeps it all healthy)
```

## Layer Details

### Layer 1 — Built-in Memory (Hot)

| Property | Value |
|----------|-------|
| Tool | `memory(action='add'/'replace'/'remove')` |
| Capacity | 2,200 chars (memory), 1,375 chars (user profile) |
| Injection | Auto-injected into system prompt every turn |
| Lifespan | Permanent until overwritten |

**What goes here**: Current facts the agent must always know — user name, timezone, immediate project context, recent corrections, environment quirks.

**Rules**:
- Keep entries compact (≤200 chars each)
- Don't duplicate what's in `.learnings/` — use pointers
- Use `replace` (not `add`) to update existing facts
- When hitting caps, merge/compress before adding new

**Priority order** (what to keep when space is tight):
1. User preferences (name, tone, communication style)
2. Environment limitations (no sudo, specific paths)
3. Common corrections (don't do X, do Y instead)
4. Project context (current repo, active task area)
5. Older one-off facts (move to Layer 3)

### Layer 2 — Honcho Memory Backend (Warm)

| Property | Value |
|----------|-------|
| Setup | `hermes honcho setup` → cloud or self-hosted |
| Capacity | Unlimited (cloud-backed) |
| Key Features | Semantic search, dialectic reasoning, session summaries, user modeling |
| Tools | `honcho_search`, `honcho_reasoning`, `honcho_profile`, `honcho_conclude`, `honcho_context` |

**What Honcho gives you**:
- **Dialectic reasoning**: A background LLM synthesizes facts about the user from conversation, building a structured user model
- **Semantic search**: Query past facts by meaning, not keywords (`honcho_search query="what did we decide about WSL networking?"`)
- **Session summaries**: Auto-compressed digest of each session, injected at session start
- **Per-profile AI peers**: Each profile gets its own identity, with isolated observations

**Config** (in `config.yaml`):
```yaml
memory:
  provider: honcho
  memory_enabled: true
  user_profile_enabled: true
```

**When to use each tool**:
| Situation | Tool |
|-----------|------|
| Session start warmup | `honcho_profile` (fast, no LLM cost) |
| Search specific past fact | `honcho_search query="..."` |
| Deep user understanding | `honcho_reasoning query="..."` |
| Write permanent fact | `honcho_conclude conclusion="..."` |
| Full snapshot | `honcho_context` |

**Pitfalls**:
- Honcho dialectic costs tokens on Honcho's backend — don't call `honcho_reasoning` every turn
- Auto-injection handles ongoing context refresh — only call tools when injected context is insufficient
- `dialecticCadence: 2` means dialectic fires every other turn — tune up/down based on verbosity vs cost

### Layer 3 — Self-Improvement Logs (Cold)

| Property | Value |
|----------|-------|
| Location | `~/.learnings/` |
| Files | `LEARNINGS.md`, `ERRORS.md`, `FEATURE_REQUESTS.md` |
| Capacity | Unlimited (markdown files) |
| Retrieval | `grep`, `session_search`, or direct `read_file` |

**What goes where**:
| Content | File |
|---------|------|
| User corrections, best practices, knowledge gaps | `LEARNINGS.md` |
| Command failures, tool errors, integration issues | `ERRORS.md` |
| Features the user wants but don't exist yet | `FEATURE_REQUESTS.md` |

**Entry format**:
```markdown
## [LRN-YYYYMMDD-XXX] category

**Logged**: ISO-8601 timestamp
**Priority**: low | medium | high | critical
**Status**: pending | resolved | promoted | wont_fix
**Area**: config | env | tool | workflow | behavior

### Summary
One-line summary

### Details
What happened, what was learned

<!-- For recurring patterns -->
**Pattern-Key**: some.unique.key
**Recurrence-Count**: 1
```

**Cron for maintenance** (optional but recommended):
```
# Daily: archive stale facts from memory to .learnings
# Weekly: review pending entries, promote high-value to skills
```

### Layer 4 — Vector Database (Semantic Index)

| Property | Value |
|----------|-------|
| Recommended | Chroma (local, no API key needed) |
| Setup | `pip install chromadb sentence-transformers` |
| Storage | `~/.hermes/memory/chroma/` (persistent) |
| Model | all-MiniLM-L6-v2 (default, ~80MB) |

**What it does**: Creates embeddings (vector representations) of all learnings, memories, and important facts. Lets you search by meaning: searching "networking problem" can find entries about "cloudflared binding issue" even though those words don't overlap.

**Quick setup**:
```python
import chromadb

client = chromadb.PersistentClient(path="~/.hermes/memory/chroma/")
collection = client.get_or_create_collection(name="agent-memory")

# Index a learning
collection.add(
    documents=["WSL sudo is disabled. Use sudo-less workarounds or Windows PowerShell Admin for admin operations."],
    metadatas=[{"layer": "memory", "area": "env", "date": "2026-05-04"}],
    ids=["MEM-001"]
)

# Query semantically
results = collection.query(query_texts=["admin privileges"], n_results=3)
```

**Integration with Hermes**: Not built-in — triggered on demand or via cron. Best used when:
- You need to find "something about X" but can't remember the exact keywords
- `.learnings/` has grown large (>30 entries) and grep becomes unwieldy
- You want to cross-reference across all four layers in one query

### Layer 5 — Cron Automation (Glue)

A set of scheduled tasks that keep the architecture healthy:

| Frequency | Task | Purpose |
|-----------|------|---------|
| **Daily** 01:00 | Compress memory → archive to .learnings | Prevent memory cap saturation |
| **Weekly** Sun 03:00 | Review .learnings, promote to skills | Convert lessons into reusable procedures |
| **Monthly** 1st 04:00 | Rebuild Chroma index | Keep vector search up to date |

**Example daily compression script** (conceptual):
```bash
#!/bin/bash
# ~/.hermes/scripts/memory-compress.sh
# 1. Read current memory entries
# 2. Identify saturated/duplicate entries
# 3. Merge old entries into .learnings/LEARNINGS.md
# 4. Replace memory entries with compressed versions
```

**Example weekly review script** (conceptual):
```bash
#!/bin/bash
# ~/.hermes/scripts/memory-review.sh
# 1. List all pending LEARNINGS entries with Pattern-Key
# 2. For entries with Recurrence-Count >= 2: promote to skill
# 3. For resolved entries from >30 days ago: mark verified
# 4. For entries with Recurrence-Count >= 3: also promote to hermes-agent skill
```

## Query Flow

When the agent needs to recall something, the lookup order is:

1. **Check system prompt** (Layer 1 already injected) — is the fact already in current context?
2. **Check built-in memory** (L1) — fast, no tool call needed if auto-injected
3. **Search `.learnings/`** (L3) — `grep` or `session_search` for keyword matches
4. **Honcho search** (L2) — semantic search if keyword fails
5. **Chroma query** (L4) — last resort, broad semantic sweep

This prioritizes speed (system prompt → memory → grep) over comprehensiveness (vector search).

## Implementation Roadmap

### Phase 1: Immediate (already done ✅)
- Layer 1: Built-in memory configured (2,200 chars)
- Layer 3: `.learnings/` initialized with LEARNINGS, ERRORS, FEATURE_REQUESTS
- Layer 5: Git sync every 30 min preserves `.learnings/` across devices

### Phase 2: Honcho (recommended next)
```bash
hermes honcho setup
# → choose cloud or self-hosted
# → set memory.provider: honcho in config.yaml
# → verify with hermes honcho status
```

### Phase 3: Chroma (when .learnings grows)
```bash
pip install chromadb sentence-transformers
# → create ~/.hermes/memory/chroma/ collection
# → index existing .learnings/ entries
# → add a cron job to rebuild index monthly
```

### Phase 4: Automation
```bash
# Create daily compression cron
hermes cron create "0 1 * * *" \
  --name "memory-compress" \
  --prompt "Compress built-in memory: merge stale entries into .learnings/ and rewrite memory with pointers only"

# Create weekly review cron
hermes cron create "0 3 * * 0" \
  --name "memory-review" \
  --prompt "Review .learnings/ entries. Promote high-value recurring ones to skills."
```

## Pitfalls & Gotchas

- **Honcho token cost**: Dialectic reasoning uses an LLM on Honcho's backend. Each `honcho_reasoning` call costs tokens. Don't call it on every turn.
- **Chroma model download**: The default embedding model (`all-MiniLM-L6-v2`) is ~80MB on first run. Ensure disk space.
- **Memory character limits are HARD caps**: Tools will not silently truncate. You must manage space proactively.
- **Cron job context limit**: Cron agents have limited context window. Don't ask a cron agent to review 300 `.learnings/` entries at once — process in batches.
- **Chinese text in embeddings**: `all-MiniLM-L6-v2` works for Chinese but multilingual models (`paraphrase-multilingual-MiniLM-L12-v2`) produce better results for mixed Chinese-English content.
- **Injection order matters**: System prompt may truncate memory injection if total prompt exceeds model context. If agent seems to "forget" injected memory, check if context is being compressed.
