# Hot Layer (Memory Tool) Cleanup Protocol

## When to use

The hot layer (memory tool) has a 5,000 character limit. When it overflows, the memory tool refuses all writes. The only fix is manual removal.

## Diagnosis

Check the memory tool's status by attempting an `add` — the error message shows current usage:

```
Memory at 21,739/5,000 chars. Adding this entry would exceed the limit.
Remove or replace existing entries first.
```

## Cleanup process

The memory tool only supports **one-at-a-time removal** using `memory(action='remove', old_text='unique substring')`. There is no batch delete, no pattern-based delete, no "delete all entries starting with X".

### Identifying entries to remove

Entries injected by cron (auto-learned content) always start with:
```
## YYYY-MM-DD auto-learned: [Topic Title]
```

These are the entries to target. They should only exist in the cold layer (MEMORY.md) and warm layer (fact_store), never in the hot layer.

### Removal strategy

1. Use `old_text` with a short unique substring from the entry title
2. Each call removes exactly one entry; verify by checking `usage` in the response
3. Batch 5 removals per turn to minimize round-trips
4. The `usage` decreases by roughly 500-1,000 chars per entry (depending on entry length)

### Example pattern

```
memory(action='remove', old_text='2026-05-15 auto-learned: 小红书', target='memory')
```

After removal, verify by checking the returned `usage` field drops toward the 5,000 limit.

### Restoration

After cleanup, re-add the essential identity/relationship/configuration entries:

```
memory(action='add', content='[user identity facts]', target='memory')
```

Keep each entry under 200 characters. Target total usage < 1,000 chars.

## Prevention

1. Cron prompts must contain explicit prohibition: "⚠️ 绝对禁止：不要写入 memory 工具"
2. After writing a cron prompt, grep-check for `memory(add` to catch accidental targets
3. The memory-system skill's pitfall section documents this — read it before running maintenance
4. Hot layer = identity/relationship/config only. No auto-learned, no session logs, no facts that belong in cold/warm layers.
