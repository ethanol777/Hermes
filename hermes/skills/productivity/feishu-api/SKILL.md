---
name: feishu-api
description: "Feishu (飞书) Open API operations — spreadsheets, docs, token management, and platform integration via REST API."
triggers:
  - "feishu"
  - "飞书"
  - "lark"
  - "lark api"
  - "飞书表格"
  - "飞书文档"
  - "feishu spreadsheet"
  - "feishu document"
tags: [feishu, 飞书, lark, api, spreadsheet, productivity, china-platforms]
---

# Feishu API Skill

Feishu (飞书) / Lark international API operations. The user has a Feishu app configured with App ID + App Secret in `~/.hermes/.env`.

## Quick Reference

### 1. Get Tenant Access Token

```bash
TOKEN_RESP=$(curl -s -X POST "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal" \
  -H "Content-Type: application/json" \
  -d '{
    "app_id": "$FEISHU_APP_ID",
    "app_secret": "$FEISHU_APP_SECRET"
  }')
TOKEN=$(echo "$TOKEN_RESP" | python3 -c "import sys,json; print(json.load(sys.stdin)['tenant_access_token'])")
```

- Token expires in ~2 hours (check `expire` field, in seconds)
- Always fetch fresh before API calls
- Store in a variable, don't repeatedly fetch unless needed

### 2. Spreadsheet Operations

#### Create Spreadsheet

```bash
CREATE_RESP=$(curl -s -X POST "https://open.feishu.cn/open-apis/sheets/v3/spreadsheets" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"title": "表格名称"}')
# Returns: spreadsheet_token, url
```

**Pitfall:** The app needs permissions `drive:drive`, `sheets:spreadsheet`, `sheets:spreadsheet:create` — if creating fails with code 99991672, direct user to:
```
https://open.feishu.cn/app/<APP_ID>/auth?q=drive:drive,sheets:spreadsheet,sheets:spreadsheet:create&op_from=openapi
```
Then they must **publish a new version** in the Feishu Open Platform console before the permissions take effect.

#### Get Sheet Metadata (discover sheetId)

```bash
META=$(curl -s -X GET "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$SPREADSHEET_TOKEN/metainfo" \
  -H "Authorization: Bearer $TOKEN")
```

Returns `sheets[].sheetId` (e.g., `"4c6f73"`) — needed for cell operations.

#### Write Data to Cells

```bash
curl -s -X PUT "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$SPREADSHEET_TOKEN/values" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{
    "valueRange": {
      "range": "'"$SHEET_ID"'!A1:G1",
      "values": [["日期", "时间", "标题", "内容摘要", "来源/链接", "状态", "备注"]]
    }
  }'
```

Range format: `{sheetId}!{startCell}:{endCell}` — NOT the sheet name.

#### Read Existing Data (find last row for appending)

```bash
READ_RESP=$(curl -s "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$SPREADSHEET_TOKEN/values/${SHEET_ID}!A:G" \
  -H "Authorization: Bearer $TOKEN")
# Count rows in the response's values array to determine where to append next
```

Use the row count + 1 as the start row for writing new data.

#### Write Multiple Rows (append after existing data)

```bash
# First get the last row
LAST_ROW=$(curl -s "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$SPREADSHEET_TOKEN/values/${SHEET_ID}!A:G" \
  -H "Authorization: Bearer $TOKEN" | python3 -c "import sys,json; print(len(json.load(sys.stdin).get('data',{}).get('valueRange',{}).get('values',[])) + 1)")

# Write starting at LAST_ROW
START=$LAST_ROW
END=$((LAST_ROW + 4))  # 5 rows
curl -s -X PUT "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$SPREADSHEET_TOKEN/values" \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d "{
    \"valueRange\": {
      \"range\": \"${SHEET_ID}!A${START}:G${END}\",
      \"values\": [[\"$(date +%Y-%m-%d)\", \"09:00\", \"标题\", \"摘要\", \"来源\", \"已推送\", \"\"]]
    }
  }'"
```

**Pitfall:** The batch_update endpoint (`POST .../values_batch_update`) often returns 400. Use the single-range `PUT .../values` endpoint instead, even for multiple rows. Specify the exact cell range covering all rows.

#### Script-based Approach (for cron/complex workflows)

For complex workflows (cron jobs, webhooks), write a standalone Python script instead of inline bash:

```python
import json, urllib.request, os

def get_token():
    data = json.dumps({"app_id": os.environ["FEISHU_APP_ID"], "app_secret": os.environ["FEISHU_APP_SECRET"]}).encode()
    req = urllib.request.Request("https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal", data=data, ...)
    return json.loads(urllib.request.urlopen(req).read())["tenant_access_token"]

def get_last_row(token, spreadsheet_token, sheet_id):
    url = f"https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/{spreadsheet_token}/values/{sheet_id}!A:G"
    resp = urllib.request.urlopen(urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"}))
    data = json.loads(resp.read())
    return len(data.get("data", {}).get("valueRange", {}).get("values", [])) + 1

def write_rows(token, spreadsheet_token, sheet_id, start_row, rows):
    end_row = start_row + len(rows) - 1
    body = json.dumps({"valueRange": {"range": f"{sheet_id}!A{start_row}:G{end_row}", "values": rows}}).encode()
    req = urllib.request.Request(f"https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/{spreadsheet_token}/values",
                                 data=body, headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"}, method="PUT")
    return json.loads(urllib.request.urlopen(req).read())
```

A ready-to-use script is available at `scripts/feishu_push_ai_news.py` in the skills directory — pipe JSON array to it. This script handles token fetch, last-row detection, and batch writing in one call:

```bash
echo 'JSON_ARRAY' | python3 /home/ethanol/.hermes/scripts/feishu_push_ai_news.py "$(date +%Y-%m-%d)"
```

Input format: JSON array of objects with fields `title`, `summary`, `source`, `time`.

### 3. Common Permission Codes

| Code | Meaning | Action |
|------|---------|--------|
| 0 | Success | — |
| 99991663 | Token expired | Re-fetch tenant_access_token |
| 99991672 | Scope not granted | Grant permissions + publish app version |
| 99991672 | Scope not granted | Grant permissions + publish app version |

### 4. Data Gathering for Cron Job Pushes

When running a cron job to push Feishu content (e.g., daily AI news), the data gathering step is the hardest part. Here's what works in this environment:

#### ❌ Don't: delegate_task with web/browser toolset for current news

Subagents hallucinate when asked to get real-time news. They produce plausible-sounding but fabricated headlines, dates, and URLs. The web/browser toolset also frequently fails from WSL with timeouts.

#### ✅ Do: curl + Hacker News Algolia API

The HN Algolia API (`hn.algolia.com`) is accessible from this WSL environment and provides real, verifiable stories with timestamps.

**Get latest stories sorted by date:**

```bash
curl -s "https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=30"
```

**Filter for AI-related stories in Python:**

```bash
curl -s --connect-timeout 10 "https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=30" | python3 -c "
import json,sys
data=json.load(sys.stdin)
keywords = ['ai ', ' ai', 'openai', 'gpt', 'claude', 'deepseek', 'llm', 'agent', 'neural', 'autonomous', 'driverless']
for h in data.get('hits',[]):
    t = h.get('title','').lower()
    if any(k in t for k in keywords):
        print(json.dumps({'title': h['title'], 'url': h.get('url','') or 'https://news.ycombinator.com/item?id='+h.get('objectID',''), 'pts': h.get('points',0), 'time': h.get('created_at','')}))
"
```

**Format for Feishu script input:**

```python
# After filtering HN results, build JSON array:
news_items = []
for story in filtered_stories:
    news_items.append({
        "title": story["title"],
        "summary": "简短中文摘要（手动写，因为 HN 只有标题）",
        "source": story["url"],
        "time": "09:00"  # Cron run time
    })
# Pipe as JSON array to the script
print(json.dumps(news_items, ensure_ascii=False))
```

#### Pitfalls

- **NewsAPI key may be expired:** The key `ad27ea9bccb440d7b463e06b2f13e204` returns empty responses — do NOT rely on newsapi.org.
- **HN Algolia only has titles, no abstracts:** For a cron job, you'll need to use the title + your domain knowledge to craft a short Chinese summary. The HN story title is usually descriptive enough.
- **`search_by_date` returns all stories, not just AI:** Apply keyword filtering in Python after fetching.
- **The `?query=` parameter in HN Algolia matches titles poorly** — use `tags=story` + client-side keyword filter instead.
- **Browser navigation from WSL times out** — use curl to HTTP APIs only. Don't attempt `browser_navigate` for data gathering.
- **HN stories may be from older dates** — check `created_at` field and skip anything older than 3 days.

#### Reference

For detailed HN Algolia API query patterns (date ranges, point thresholds, keyword filtering), see `references/hacker-news-api.md` in this skill.

### Python Runtime Note

The hermes venv at `/home/ethanol/.hermes/hermes-agent/venv/bin/python3` has **no pip module**. If installing Python packages is needed, use system python3 or a different interpreter. The venv is sealed for dependency isolation.

### Environment Variables

Read from `~/.hermes/.env`:

```
FEISHU_APP_ID=cli_a97b56e706f9dcce
FEISHU_APP_SECRET=...
FEISHU_DOMAIN=feishu        # "feishu" for CN; "lark" for international
FEISHU_CONNECTION_MODE=websocket  # or "webhook"
```

## References

- `references/spreadsheet-example.md` — Full session transcript of creating a "每日推送收集" spreadsheet with column headers, freeze pane, and permission troubleshooting.
- `references/hacker-news-api.md` — HN Algolia API query patterns for gathering real-time AI/tech news in cron jobs (filters, dedup, formatting for Feishu push).
