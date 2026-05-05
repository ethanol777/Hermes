# Feishu Gateway Diagnosis — Walkthrough

Real session transcript (2026-05-01) diagnosing "why doesn't my Feishu bot reply".

## User Report

User sends messages to Feishu bot. Bot does not respond. No errors visible.

## Diagnosis Steps

### 1. Check Gateway Status

```
hermes gateway status
```

→ `✗ Gateway is not running` — this is the #1 cause of "bot not responding."

**Lesson**: Even with perfect platform config, if the gateway process is dead, messages arrive at the Feishu server but Hermes never picks them up. No error, no log — just silence.

### 2. Verify It Ever Worked

```bash
grep "inbound message" ~/.hermes/logs/gateway.log | tail -10
```

Shows historical inbound messages with timestamps. Last entry was yesterday — confirms the gateway crashed or was killed overnight.

### 3. Check .env for Platform Config

```bash
grep -E "FEISHU|WEIXIN|WECHAT|DINGTALK|WECOM" ~/.hermes/.env
```

Feishu was fully configured. WeChat had nothing — explains why WeChat is silent too.

### 4. Test Feishu API Credentials Directly

```bash
source ~/.hermes/.env
curl -s -X POST https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal \
  -H "Content-Type: application/json" \
  -d "{\"app_id\":\"$FEISHU_APP_ID\",\"app_secret\":\"$FEISHU_APP_SECRET\"}" | \
  python3 -c "import sys,json; d=json.load(sys.stdin); print('code:', d.get('code')); print('has_token:', 'tenant_access_token' in d)"
```

→ `code: 0, has_token: True` — credentials are valid. The issue is purely that the gateway wasn't running.

### 5. End-to-End Test With Spreadsheet

Full read/write/verify cycle on a Feishu spreadsheet to confirm API works end-to-end:

```bash
# Get token
TOKEN=$(curl -s -X POST ... | python3 -c "import sys,json; print(json.load(sys.stdin)['tenant_access_token'])")

# Read spreadsheet metainfo
curl -s -X GET "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$TOKEN/metainfo" -H "Authorization: Bearer $TOKEN"

# Write test cell
curl -s -X PUT "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$TOKEN/values" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"valueRange": {"range": "'"$SHEET_ID"'!H1:H1", "values": [["✅ test"]]}}'

# Read it back
curl -s "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$TOKEN/values/${SHEET_ID}!H1:H1" \
  -H "Authorization: Bearer $TOKEN"

# Clean up
curl -s -X PUT "https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/$TOKEN/values" \
  -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" \
  -d '{"valueRange": {"range": "'"$SHEET_ID"'!H1:H1", "values": [[""]]}}'
```

### 6. Start Gateway Persistently (Recommended for WSL)

```bash
tmux new-session -d -s hermes 'hermes gateway run'
sleep 5
tmux capture-pane -t hermes -p | tail -10
```

→ Look for `[Feishu] connected to wss://msg-frontier.feishu.cn` in the output.

### 7. Verify Running

```bash
hermes gateway status
```

→ `✓ Gateway is running (PID: ...)`

## Root Causes by Frequency

| Cause | How to Detect | Fix |
|-------|--------------|-----|
| Gateway not running | `hermes gateway status` → not running | `tmux new -s hermes 'hermes gateway run'` |
| Env vars missing | `grep FEISHU ~/.hermes/.env` → empty | Add to `.env` |
| App not published | No error, but Feishu silently drops messages | Publish in open.feishu.cn console |
| Token expired | `code: 99991663` on API calls | Auto-refresh is built-in, no action needed |
| Credentials wrong | `code != 0` on token fetch | Check FEISHU_APP_ID / FEISHU_APP_SECRET |
| WebSocket disconnected | No `connected` in startup logs | Restart gateway |
