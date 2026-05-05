# Chinese Messaging Platforms Setup

## Feishu / Lark (飞书)

Feishu is ByteDance's enterprise collaboration platform. The international version is Lark.

### Prerequisites

1. Create a **corporate self-built app** at https://open.feishu.cn
2. Get **App ID** (starts with `cli_`) and **App Secret**
3. Enable **Bot capability** (应用功能 → 机器人/应用 → 权限管理)
4. **Publish** the app and get it approved

### Configuration (.env)

```bash
FEISHU_APP_ID=cli_xxxxxxxxxxxxx
FEISHU_APP_SECRET=your_app_secret
FEISHU_DOMAIN=feishu          # "feishu" for 飞书, "lark" for Lark international
FEISHU_CONNECTION_MODE=websocket  # "websocket" (default, no public URL needed) or "webhook"
```

### Connection Modes

| Mode | Pros | Cons |
|------|------|------|
| **WebSocket** (default) | No public URL needed, works behind NAT/WSL | None for most use cases |
| **Webhook** | Traditional event callback | Requires public URL + encrypt_key + verification_token |

### Access Control

By default, all unauthorized users are denied. To open access:

```bash
GATEWAY_ALLOW_ALL_USERS=true
```

Or restrict to specific users:

```bash
FEISHU_ALLOWED_USERS=ou_xxx,ou_yyy
```

### Verification

```bash
hermes gateway run
```

Check logs for: `[Feishu] Connected in websocket mode (feishu)` and `✓ feishu connected`.

### Common Pitfalls

- App must be **published and approved** — unpublished apps don't receive messages
- Bot capability must be **enabled** in the Feishu Open Platform
- After changing .env, **restart** gateway (`Ctrl+C` then `hermes gateway run` again)
- The `GATEWAY_ALLOW_ALL_USERS` warning at startup is harmless once set

---

## KIM (快手智能协作平台)

KIM is Kuaishou's enterprise collaboration platform (文档/IM/审批/会议一体化). **It is NOT a public SaaS** — API access is limited to Kuaishou employees only. All open-platform features on the official site (kim.kuaishou.com) are marked "仅限快手员工使用".

### Integration Status

- Hermes Agent does NOT have a built-in KIM adapter
- No public API documentation exists externally
- If you are a Kuaishou employee with internal API access, a custom script (similar to `feishu_push_ai_news.py`) can be written to integrate with Hermes

### Naming Ambiguity

In Chinese tech contexts, "Kim"/"KIM" can mean two very different things:

| Name | Full Name | Type | Provider |
|------|-----------|------|----------|
| **Kim** / **KIM** | 快手KIM智能协作平台 | Office collaboration platform | Kuaishou (快手) |
| **Kimi** | 月之暗面Kimi大模型 | LLM / AI model provider | Moonshot AI (月之暗面) |

Hermes has a built-in provider for **Kimi (月之暗面/Moonshot)** via `KIMI_API_KEY` env var. KIM (快手套办公) integration requires custom scripting.

---

## WeChat / Weixin (微信 via iLink Bot API)

Hermes connects to WeChat personal accounts through **Tencent's iLink Bot API** (`ilinkai.weixin.qq.com`), not the official WeChat Official Account platform.

### Prerequisites

1. Register for iLink Bot API access (腾讯 iLink Bot 开放平台)
2. Get a **WEIXIN_TOKEN** (bot token)
3. Get a **WEIXIN_ACCOUNT_ID** (account identifier)

### Configuration (.env)

```bash
WEIXIN_TOKEN=your_bot_token
WEIXIN_ACCOUNT_ID=your_account_id
WEIXIN_DOMAIN=feishu          # optional, "feishu" (default) or "lark"
WEIXIN_BASE_URL=https://ilinkai.weixin.qq.com  # optional, has default
WEIXIN_CDN_BASE_URL=https://novac2c.cdn.weixin.qq.com/c2c  # optional
```

### DM & Group Policies

```bash
WEIXIN_DM_POLICY=open          # open (default), allowlist, disabled
WEIXIN_GROUP_POLICY=disabled   # disabled (default), open, allowlist
WEIXIN_ALLOWED_USERS=          # comma-separated user IDs for allowlist
```

### Checklist — Why WeChat Isn't Replying

If you configured WeChat but the bot isn't responding, step through:

1. **Are env vars set?** → `grep WEIXIN ~/.hermes/.env`. If empty, the WeChat adapter won't start at all. The gateway logs `weixin_missing_token` or silently skips the platform.
2. **Is the gateway running?** → `hermes gateway status`. Even with perfect config, if the gateway is down messages are lost.
3. **Check startup logs** → Look for `✓ weixin connected` or `weixin_missing_token` / `weixin_missing_dependency` in gateway startup output.
4. **Group policy** → Default is `WEIXIN_GROUP_POLICY=disabled`. The bot only responds in DMs unless you explicitly set it to `open` or `allowlist`.
5. **iLink account type** → `xxx@im.bot` accounts **cannot be invited into regular WeChat groups**. Only DMs work.
6. **Dependencies** → `pip install aiohttp cryptography` if logs show `weixin_missing_dependency`.

### Limitations

- iLink Bot identity is typically `xxx@im.bot` — these **cannot be invited into ordinary WeChat groups**
- Group message delivery depends on iLink's server-side support, not Hermes
- Session tokens expire after inactivity; auto-refresh is built in
- Requires `aiohttp` and `cryptography` Python packages

### Verification

```bash
hermes gateway run
```

Check logs for: `[Weixin] Connected account=... base=...` and `✓ weixin connected`.

### Startup Errors

| Error | Likely Cause |
|-------|-------------|
| `weixin_missing_token` | WEIXIN_TOKEN not set or empty |
| `weixin_missing_account` | WEIXIN_ACCOUNT_ID not set or empty |
| `weixin_missing_dependency` | `aiohttp` or `cryptography` not installed |
| `Session expired` (errcode -14) | Token stale; waits 10 min and retries |
