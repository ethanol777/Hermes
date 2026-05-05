# Multi-Layer Memory System Architecture

A layered approach to Hermes Agent memory that prevents context loss ("amnesia") across sessions. Combines hot/warm/cold storage with automated maintenance.

## The Problem

Hermes's built-in memory (`memory` tool) has fundamental limitations:
- **2200 char limit** on memory store, 1375 on user profile
- **No semantic retrieval** — keyword-only via session_search
- **No compression** — old facts pile up linearly
- **No deduplication** — overlapping entries waste space
- **No hierarchy** — all facts have equal weight

## The Solution: Five Layers

```
Hot  ←──────────────────────────────→  Cold
Layer 1         Layer 2        Layer 3        Layer 4        Layer 5
┌─────────┐    ┌─────────┐    ┌──────────┐    ┌─────────┐    ┌─────────┐
│ built-in │←─→│ Honcho  │←─→ │.learnings│←─→ │ Chroma  │←─→ │  Cron   │
│ memory   │   │记忆后端  │    │ 自进化日志 │    │ 向量库   │    │ 自动维护 │
└─────────┘    └─────────┘    └──────────┘    └─────────┘    └─────────┘
```

### Layer 1: Hot Memory (built-in)

**Tool:** `memory(action='add'|'replace'|'remove')`

Stores immediate, high-turnover facts that are needed every session.

| Capacity | What goes in |
|----------|-------------|
| memory: 2200 chars | Environment facts, project setup, tool quirks |
| user: 1375 chars | User name, preferences, personality, communication style |

**Best for:** Current project context, most recent corrections, things referenced frequently.

**Rules:**
- DO NOT save task progress, session outcomes, or completed work logs
- Use `session_search` to recall past transcripts instead
- When near limit, remove old/merged entries before adding new ones
- Prefer short, declarative facts over imperative instructions

### Layer 2: Warm Memory (Honcho)

**Provider:** `memory.provider: honcho`

Semantic, cross-session memory with user modeling and dialectic reasoning.

**Key capabilities:**
- **Semantic search** — `honcho_search(query)` finds related content by meaning, not just keywords
- **User modeling** — Honcho builds a representation of the user across sessions
- **Dialectic reasoning** — `honcho_reasoning(query)` synthesizes answers about user patterns
- **Session summaries** — auto-injected at session start, provides conversational continuity
- **Peer isolation** — each Hermes profile gets its own AI peer with independent observations

**5 Honcho tools:**

| Tool | LLM? | Use |
|------|------|-----|
| `honcho_profile` | No | Quick peer card read/update |
| `honcho_search` | No | Semantic search over stored context |
| `honcho_context` | No | Full snapshot: summary + representation + card |
| `honcho_reasoning` | Yes | LLM-synthesized answer about user patterns |
| `honcho_conclude` | No | Write/delete persistent facts |

**Recall modes:**
- `hybrid` (default): auto-inject + tools available
- `context`: auto-inject only (tools hidden, minimal cost)
- `tools`: tools only (full agent control)

**Three tuning knobs:**
1. **Cadence** — how often context/dialectic fires (min turns between calls)
2. **Depth** — how many reasoning passes per firing (1-3)
3. **Level** — how intensive each pass is (minimal → max)

**Pitfalls:**
- Requires API key from app.honcho.dev (cloud) or self-hosted instance
- Cloud may have connectivity issues from restricted regions (China, etc.)
- Dialectic calls incur LLM cost on Honcho's backend
- Config changes need new session to take effect

### Layer 3: Cold Memory (Self-Improving Agent)

**Location:** `~/.learnings/`

Permanent, unstructured knowledge store with no size limits.

| File | Purpose |
|------|---------|
| `LEARNINGS.md` | Corrections, knowledge gaps, best practices |
| `ERRORS.md` | Command failures, integration errors, stack traces |
| `FEATURE_REQUESTS.md` | User-requested capabilities |

**When to log:**
- User corrects you → `LEARNINGS.md` (correction)
- Command/API fails → `ERRORS.md`
- Discovered better approach → `LEARNINGS.md` (best_practice)
- User wants new capability → `FEATURE_REQUESTS.md`

**Promotion pipeline:**
1. High-value, recurring learnings → **extract as skill** (`skill_manage`)
2. Broadly applicable corrections → **promote to memory**
3. Workflow patterns → **update governing skill**

### Layer 4: Semantic Library (Chroma Vector DB)

**Location:** Local ChromaDB at `~/.hermes/chroma_db/` (optional)

Vector database storing embeddings of all past learnings + memory entries.

**Use case:** "Find everything about network configuration issues" → returns `cloudflared binding gotcha`, `WSL networking`, `netsh portproxy` as semantically related results.

**Setup:**
```bash
pip install chromadb sentence-transformers
```

**Integration pattern:** Cron job indexes `.learnings/` files and `session_search` output into Chroma nightly, enabling RAG-style retrieval across the full knowledge base.

### Layer 5: Automated Maintenance (Cron)

Scheduled tasks to keep the memory system healthy:

| Frequency | Task | Purpose |
|-----------|------|---------|
| **Nightly** | Compress memory → archive to `.learnings/` | Free up hot memory space |
| **Nightly** | Re-index `.learnings/` into Chroma | Keep vector search fresh |
| **Weekly** | Review `.learnings/` → promote to skill | Convert recurring knowledge |
| **Weekly** | Deduplicate `.learnings/` entries | Clean stale/overlapping entries |
| **Monthly** | Chroma DB garbage collection | Remove orphaned embeddings |

## Workflow: How Each Session Uses Memory

```
Session Start
    │
    ├── Layer 1 (built-in memory) auto-injected into system prompt
    │   └── Contains: user profile + environment facts + recent project
    │
    ├── Layer 2 (Honcho) auto-injects session summary + user representation
    │   └── Agent can use honcho_search/reasoning for deeper recall
    │
    ├── Layer 3 (.learnings/) accessible via grep/session_search
    │   └── Referenced manually when debugging or learning
    │
    └── Layer 4 (Chroma) accessible via RAG queries
        └── For broad semantic searches across all knowledge

Session End
    │
    ├── New facts → memory (Layer 1, hot)
    ├── Corrections → LEARNINGS.md (Layer 3, cold)
    ├── Errors → ERRORS.md (Layer 3, cold)
    └── All layers persisted for next session
```

## Memory Priority

When multiple layers have information about the same topic, apply this priority:

1. **Layer 1 (hot)** — most recent, highest churn, may contradict older layers
2. **Layer 2 (Honcho)** — synthesized user model, slower to update
3. **Layer 3 (.learnings/)** — permanent but may be outdated
4. **Layer 4 (Chroma)** — passive index, no opinionated content

## Design Principles

1. **Hot for speed, cold for persistence** — put volatile facts in memory, permanent knowledge in .learnings
2. **Semantic over keyword** — Honcho + Chroma find related content keyword search can't
3. **Compress or die** — without maintenance, hot memory fills up and cold memory becomes noise
4. **Skill extraction** — the end state of any good learning is a reusable skill
5. **Graceful degradation** — if Honcho is down, memory tool still works; if memory is full, .learnings is still there
