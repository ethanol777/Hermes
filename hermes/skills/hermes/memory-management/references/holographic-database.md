# Holographic Database Reference

SQLite database at `~/.hermes/memory_store.db`.

## Schema

```sql
-- Core fact table
CREATE TABLE IF NOT EXISTS facts (
    fact_id         INTEGER PRIMARY KEY AUTOINCREMENT,
    content         TEXT NOT NULL UNIQUE,
    category        TEXT DEFAULT 'general',   -- user_pref | project | tool | general | error
    tags            TEXT DEFAULT '',
    trust_score     REAL DEFAULT 0.5,         -- 0.0-1.0, <0.3 gets pruned daily
    retrieval_count INTEGER DEFAULT 0,
    helpful_count   INTEGER DEFAULT 0,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    hrr_vector      BLOB                     -- 1024-dim phase vector for HRR retrieval
);

-- Entity resolution
CREATE TABLE IF NOT EXISTS entities (
    entity_id   INTEGER PRIMARY KEY AUTOINCREMENT,
    name        TEXT NOT NULL,
    entity_type TEXT DEFAULT 'unknown',
    aliases     TEXT DEFAULT '',
    created_at  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Fact-entity linking
CREATE TABLE IF NOT EXISTS fact_entities (
    fact_id   INTEGER REFERENCES facts(fact_id),
    entity_id INTEGER REFERENCES entities(entity_id),
    PRIMARY KEY (fact_id, entity_id)
);

-- FTS5 full-text search
CREATE VIRTUAL TABLE IF NOT EXISTS facts_fts
    USING fts5(content, tags, content=facts, content_rowid=fact_id);
```

## Seeding from .learnings

When setting up on a new machine or importing historical data:

```python
import sqlite3, re, os

DB = os.path.expanduser('~/.hermes/memory_store.db')
conn = sqlite3.connect(DB)
cur = conn.cursor()

def seed_from_learnings(path, priority_map=None):
    """Parse .learnings markdown files into Holographic facts."""
    if priority_map is None:
        priority_map = {'high': 0.8, 'medium': 0.6, 'low': 0.4, 'critical': 0.95}
    
    with open(path) as f:
        content = f.read()
    
    # Split on ## headers (works for both LRN- and ERR- format)
    entries = re.split(r'(?=## \[(?:LRN|ERR)-)', content)
    inserted = 0
    
    for entry in entries:
        # Parse summary (LEARNINGS.md uses **Summary**, ERRORS.md uses ### Summary)
        m = re.search(r'(?:\*\*Summary\*\*|### Summary)\n(.+?)(?:\n### |\n---|\Z)', entry, re.DOTALL)
        if not m:
            continue
        summary = m.group(1).strip()[:400]
        if not summary:
            continue
        
        # Parse metadata
        m2 = re.search(r'\*\*Area\*\*: (\w+)', entry)
        area = m2.group(1) if m2 else 'general'
        m3 = re.search(r'\*\*Tags\*\*: (.+?)(?:\n|$)', entry)
        tags = m3.group(1).strip() if m3 else ''
        m4 = re.search(r'\*\*Priority\*\*: (\w+)', entry)
        trust = priority_map.get(m4.group(1), 0.5) if m4 else 0.5
        
        cur.execute(
            "INSERT OR IGNORE INTO facts (content, category, tags, trust_score) VALUES (?, ?, ?, ?)",
            (summary, area, tags, trust)
        )
        if cur.rowcount > 0:
            inserted += 1
    
    conn.commit()
    return inserted
```

## Trust Score Dynamics

| Change | Trigger | Delta |
|--------|---------|-------|
| Initial | Add fact | default_trust (0.5) |
| +0.05 | User calls fact_feedback('helpful') | retrieval_count++ |
| -0.10 | User calls fact_feedback('unhelpful') | — |
| Decay | cron maintenance pass | configurable via temporal_decay_half_life |

Pitfall: `temporal_decay_half_life` is configurable in `plugins.hermes-memory-store` 
in config.yaml. Default 0 = no decay. Set to e.g. 30 (days) to auto-decay 
unretrieved facts.

## HRR Vector Notes

- 1024-dim phase vectors, deterministic from SHA-256
- Requires numpy for encoding/search; degrades gracefully without it
- `hrr_weight: 0.3` in config controls HRR contribution vs FTS5 score
- Vectors are not human-readable — stored as BLOB in the facts table
