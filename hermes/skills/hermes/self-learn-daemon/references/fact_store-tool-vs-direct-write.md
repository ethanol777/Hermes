# fact_store Tool vs Direct JSONL Write

## Key Discovery (2026-05-16 21:45 UTC+8)

**The `fact_store` API tool is NOT universally available in cron contexts.** Its availability depends on the provider/model configuration. In the deepseek-v4-flash/opencode-go environment, the tool was completely absent from the tool list.

This changes the fallback hierarchy: the `echo >>` direct write approach is now a co-equal path, not a rare backup.

## Tool Availability Matrix

| Context | fact_store tool available? | Expected behavior |
|---------|--------------------------|-------------------|
| Hermes main chat session | ✅ Usually available | Use `fact_store(action='add')` as default |
| Hermes cron (some providers) | ✅ Available | Use `fact_store(action='add')` |
| Hermes cron (deepseek-v4-flash/opencode-go) | ❌ Not available | Must use `terminal echo >> fact_store.jsonl` |
| execute_code Python sandbox | ❌ Not available | Write pending_facts_*.md and re-add later |

**Rule: always check the tool list first before writing facts. Don't assume fact_store is there.**

## When to Use What

| Method | When | Why |
|--------|------|-----|
| `fact_store(action='add')` | When the tool is in the tool list. | Proper dedup, trust scoring, entity linking. |
| `terminal echo >> fact_store.jsonl` | When fact_store tool NOT in list. | Only reliable alternative. Skips trust/dedup but data is in the file. |
| Direct `write_file` rewriting jsonl | Avoid unless necessary. | Read-modify-write three-step risks data loss in concurrent contexts. |
| `patch()` on jsonl | **Never**. Patch tool fails on CJK characters in JSONL. | Encoding mismatch. Always fails on Chinese text in JSONL lines. |

## What Gets Lost with Direct Write

When bypassing `fact_store(action='add')` and writing directly to jsonl:

1. **No deduplication** — the tool checks if a similar fact already exists; direct write risks duplicates.
2. **No trust scoring** — `fact_store` tool manages trust decay (`trust_delta`); direct write leaves the `confidence` field hardcoded with no decay.
3. **No entity resolution** — the `fact_store` tool connects facts to entities (people, projects, concepts) for later `probe`/`reason` queries.
4. **No category/tag normalization** — the tool enforces the category enum (`user_pref`, `project`, `tool`, `general`) and validates tag syntax.

These are acceptable losses when the tool is genuinely unavailable. The data will still be queryable by future `fact_store search` calls.

## How to Properly Add Facts in Cron

### Path A: fact_store tool available (preferred)

```python
# CORRECT (use fact_store tool):
fact_store(
    action='add',
    content='...',
    category='general',
    tags='timely,security,automotive,privacy',
    trust_delta=0.5
)
```

### Path B: fact_store tool NOT available (confirmed working fallback)

```bash
# Windows git-bash terminal -- use single quotes for bash, double quotes inside JSON:
echo '{"id":"fs_040","fact":"...","source":"...","date":"2026-05-16","tags":"stable,AI,culture","confidence":0.85}' \
  >> /c/Users/77/Hermes/hermes/memories/fact_store.jsonl
echo '{"id":"fs_040","fact":"...","source":"...","date":"2026-05-16","tags":"stable,AI,culture","confidence":0.85}' \
  >> /c/Users/77/AppData/Local/hermes/memories/fact_store.jsonl
```

**Crucial: write to BOTH copies** (Hermes + AppData).

### Path C: From execute_code Python sandbox

```python
# Fallback from execute_code — tools not available here:
write_file(
    "pending_facts_2026-05-16.md",
    "- fact: ...\n  tags: ...\n- fact: ...\n  tags: ...\n"
)
# Then in next tool call: fact_store(action='add', ...) for each line
```

## 🚨 Patch Tool Fails on UTF-8 Chinese JSONL (2026-05-16)

The `patch` tool (used for text replacement in files) **will fail** when the `old_string`/`new_string` contains CJK characters in a JSONL file. The error looks like:

```
Could not find a match for old_string in the file
```

...even when the text you're trying to match is literally present. This is an encoding/matching issue with the patch tool on UTF-8 JSONL.

**Do NOT:**
- ❌ Retry patch() with different whitespace — it will keep failing
- ❌ Use patch() as the primary way to append to fact_store.jsonl
- ❌ Assume "patch fails → fact_store tool is also broken" — they're unrelated

**Do instead:**
- ✅ Use `fact_store(action='add')` — when the tool is available
- ✅ If fact_store tool itself is unavailable, use `terminal echo '...' >> file` as fallback
- ✅ After echo fallback, write both copies (Hermes + AppData)

## JSONL ID Convention

Use sequential IDs following the existing pattern:
- `fs_001` through current max (check file before writing)
- Increment from last ID in the file

## 🔴 Shell Quoting Pitfall: JSON with apostrophes breaks `echo '...' >>`

### Problem

The `echo '...' >>` pattern wraps JSON in bash single quotes. If the JSON content itself **contains a single quote/apostrophe** (e.g. `Boss's Same Drink`, `"can't measure human skill"`), the shell breaks:

```bash
# This FAILS — the apostrophe in "Boss's" closes the single-quote string prematurely
echo '{"id":"fs_057","fact":"Jensen Huang visited Mixue; Boss's Same Drink drove 140% surge"}' >> fact_store.jsonl
# ^ bash sees: echo '...Boss'  → unclosed string starting at  s Same Drink...'
```

Result: truncated/invalid JSON, silent data corruption.

### Workarounds (choose one)

#### Option A: `execute_code` Python → `terminal()` calls (✅ preferred — this session's pattern)

Use `execute_code` (Python) to orchestrate `terminal()` calls. Python handles string quoting natively:

```python
from hermes_tools import terminal

facts = [
    '{"id":"fs_055","fact":"Frontier AI has broken open CTF competitions...","tags":"timely,security","confidence":0.92}',
    '{"id":"fs_056","fact":"Alibaba Health launched Hydrogen Ion medical AI...","tags":"timely,AI,healthcare","confidence":0.90}',
]

for f in facts:
    # Use print() to pipe to shell — avoids apostrophe issues
    r = terminal(f"echo '{f}' >> /c/Users/77/Hermes/hermes/memories/fact_store.jsonl")
    if r["exit_code"] != 0:
        print(f"Failed: {r}")
```

⚠️ **Caution:** This still uses `echo '{f}'` inside the `terminal()` call string. Python's f-string handles the quoting, but if `f` itself contains a single quote, bash will still break. **Safe option:** use `printf '%s\n' "$json" >> file` instead (see Option B).

#### Option B: Use `printf` instead of `echo` with double-quoted shell variable

```python
from hermes_tools import terminal

fact = '{"id":"fs_055","fact":"Boss\\'s Same Drink drove 140% surge..."}'
# Option 1: JSON-encode the apostrophe as \'
safe_fact = fact.replace("'", "\\'")
r = terminal(f"echo '{safe_fact}' >> /c/Users/77/Hermes/hermes/memories/fact_store.jsonl")
# But this is fragile — better to use Option C

# Option 2: Store in a var and use printf with double quotes
r = terminal(f"""printf '%s\\n' \"{fact}\" >> /c/Users/77/Hermes/hermes/memories/fact_store.jsonl""")
```

#### Option C: Write via Python's `write_file` or `terminal` with raw heredoc

```python
from hermes_tools import terminal

# Write multiple facts at once using a heredoc — no quoting issues
fact_lines = """{"id":"fs_055","fact":"...","tags":"...","confidence":0.92}
{"id":"fs_056","fact":"...","tags":"...","confidence":0.90}"""

r = terminal(f"""cat >> /c/Users/77/Hermes/hermes/memories/fact_store.jsonl << 'ENDFACTS'
{fact_lines}
ENDFACTS""")
```

The heredoc (`<< 'ENDFACTS'`) with single-quoted delimiter prevents ALL shell expansion — no escaping issues.

### Prevention

Before writing, inspect your JSON strings for apostrophes/single quotes:

```python
facts = [f1, f2, f3]
for f in facts:
    if "'" in f:
        print(f"⚠️ Contains apostrophe: {f[:50]}...")
```

If found, use heredoc (Option C) — it's the most robust across all JSON content.

## Verification After Direct Write

After any direct write, verify all new entries parse as valid JSON:

```bash
# Check the last N lines are all valid JSON
tail -5 /c/Users/77/Hermes/hermes/memories/fact_store.jsonl | python -c "
import json, sys
lines = sys.stdin.read().strip().split('\n')
for i, line in enumerate(lines):
    try:
        json.loads(line)
    except json.JSONDecodeError as e:
        print(f'INVALID line {i+1}: {e}')
        print(f'Content: {line[:80]}')
print(f'Checked {len(lines)} lines')
"
```

If any line is invalid JSON (truncated by shell quoting), remove it and re-write with proper escaping.
