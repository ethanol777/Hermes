# Memory Compression Recipe

Achieved 99% → 19% compression on 雨晨's system in one session by following this process.

## Recipe

1. Identify verbose entries that can be merged (e.g. 3 separate entries about WSL/Gateway/Git → 1 entry)
2. Identify pure progress-tracker entries that are now obsolete ("已完成XX", "待做XX")
3. **Remove first, add later** — avoid hitting the 2200-char limit mid-operation
4. Write compact replacement entries, combining:
   - Long-standing facts (user alias, environment constraints)
   - Task-specific facts (Feishu config, cron jobs)
   - System facts (memory layers, skills count)
5. Optionally mirror removed entries to Holographic `fact_store` for long-term retention

## Before/After Example

**Before (11 entries, 2189 chars):**
- Separate: Feishu table info | AI cron | Gateway diag | Git repo | Monica name | WSL sudo | Cloudflare | Self-improve | Holographic | 5-layer progress | gitignore

**After (4 entries, 428 chars):**
- "用户叫我莫妮卡"
- "WSL sudo 被禁用..."
- "飞书：APP_ID...表格...cron..."
- "环境：WSL无sudo...Gateway...Git...skills...Holographic"
