# WeChat Gateway Connection — Verification Log

**Date:** 2026-05-01
**Session context:** User asked to "restart hermes-gateway, run Feishu and WeChat in separate tmux processes"

## What actually happened

- Gateway was already running as systemd service (PID 7074, started at 21:39)
- systemd service manages it with `--replace` flag
- Feishu connected successfully (`wss://msg-frontier.feishu.cn`)
- WeChat env vars ARE set but startup did NOT show `✓ weixin connected` — status unclear
- WeChat config: `WEIXIN_BASE_URL=https://ilinkai.weixin.qq.com`, `WEIXIN_ACCOUNT_ID=997f49108570@im.bot`

## Follow-up needed

Verify WeChat actually connected by checking:
```bash
hermes gateway status
# OR
grep -i 'weixin\|wechat' ~/.hermes/logs/gateway.log | tail -20
```

If WeChat did NOT connect, common causes per `chinese-messaging-platforms.md`:
- `weixin_missing_token` — WEIXIN_TOKEN empty or wrong
- `weixin_missing_dependency` — `pip install aiohttp cryptography`
- Token stale (errcode -14) — waits 10 min and retries

## Key lesson

The gateway is a **single process** for all platforms. You cannot run "Feishu process + WeChat process" via tmux split — both run in the same gateway instance. Separate tmux sessions are only needed if running WITHOUT systemd, and then there's still only ONE gateway process (tmux just keeps it alive). The `--platform wechat` flag does not exist in the CLI.
