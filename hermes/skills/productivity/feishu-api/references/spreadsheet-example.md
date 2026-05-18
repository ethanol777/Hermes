# 每日推送收集 — Spreadsheet Creation Example

## Context

User wanted a Feishu spreadsheet ("每日推送收集") to collect daily push notifications. Communication was in Chinese, via Feishu DM through the Hermes gateway.

## Steps Taken

### 1. Get Credentials
Read `FEISHU_APP_ID` and `FEISHU_APP_SECRET` from `~/.hermes/.env`.

### 2. Fetch Tenant Access Token
```bash
curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d '{"app_id": "cli_a97b56e706f9dcce", "app_secret": "IAp35s1gBYTUuvwUknSnndS7Kojiwp1u"}'
```

### 3. Create Spreadsheet
```bash
curl -s -X POST "https://open.feishu.cn/open-apis/sheets/v3/spreadsheets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "每日推送收集"}'
```

### 4. Error — Permission Denied (99991672)
Response: `code: 99991672, msg: "Access denied. One of the following scopes is required: [drive:drive, sheets:spreadsheet, sheets:spreadsheet:create]"`

**Resolution:** User granted permissions via Feishu Open Platform console at:
```
https://open.feishu.cn/app/cli_a97b56e706f9dcce/auth?q=drive:drive,sheets:spreadsheet,sheets:spreadsheet:create
```
Then published a new app version.

### 5. Create Success
```json
{
  "code": 0,
  "data": {
    "spreadsheet": {
      "spreadsheet_token": "MiqUs4YnPhyNOJt5yuKcQ45wn8c",
      "title": "每日推送收集",
      "url": "https://my.feishu.cn/sheets/MiqUs4YnPhyNOJt5yuKcQ45wn8c"
    }
  }
}
```

### 6. Discover Sheet ID
Writing to "Sheet1!A1:G1" failed with code 90215 ("sheetId not found"). Needed to use the actual internal sheet ID.

```bash
curl -s -X GET "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$TOKEN/metainfo"
```

Found `sheetId: "4c6f73"`.

### 7. Write Headers
Used `4c6f73!A1:G1` as the range:

Columns: 日期, 时间, 标题, 内容摘要, 来源/链接, 状态, 备注

## Key Takeaways

- **API base URL:** `https://open.feishu.cn/open-apis/` (国内飞书)
- **Sheet range format:** Must use internal `sheetId` (e.g., `4c6f73!A1:G1`), NOT sheet name (`Sheet1!A1:G1`)
- **Permission grant requires app version publish** — granting in console is not enough; the user must publish a new version
- **Token expires ~2 hours**, reuse within session

---

## Cron Job: Daily AI News → Feishu Spreadsheet

After creating the spreadsheet, we set up a Hermes cron job to push AI news daily at 9 AM and write it to the Feishu spreadsheet.

### Cron Prompt Design

The cron prompt instructs the agent to:

1. **Gather news** via curl + HN Algolia API (NOT via `web_search`/`delegate_task` — subagents hallucinate current events)
2. **Filter** for AI-related stories using keyword matching on titles
3. **Format** results as a JSON array with `title`, `summary` (in Chinese, synthesized from title + domain knowledge), `source`, `time` keys
4. **Write** to Feishu using the helper Python script:
   ```bash
   echo 'JSON_ARRAY' | python3 /home/ethanol/.hermes/scripts/feishu_push_ai_news.py "$(date +%Y-%m-%d)"
   ```

### Cron Job Configuration

- Schedule: `0 9 * * *` (daily at 9:00 AM)
- Delivery: `origin` (results come back to the current chat)
- The cron job's prompt should be self-contained — include exact column mapping and script path

### Helper Script

Saved at `scripts/feishu_write_rows.py` in this skill directory. Handles:
- Token refresh on each run
- Auto-detecting the last populated row (reads sheet data to count existing rows)
- Writing multiple rows in a single PUT call
- Accepting JSON via stdin for composability with web_search output
