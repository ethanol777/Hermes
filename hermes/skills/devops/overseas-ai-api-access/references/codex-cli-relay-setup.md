# Codex CLI + API Relay Setup (May 2026)

Session findings from May 8, 2026 — research on using OpenAI Codex CLI through Chinese API relay services.

## Current State

- **Codex CLI** (npm: `@openai/codex`) now supports **ChatGPT Plus login mode** — no API key needed. Just `npm i -g @openai/codex` then `codex` to launch.
- Codex has evolved into a full app with CLI + desktop modes, using GPT-5.3/5.4/5.5 coding-optimized models.
- Cost: ChatGPT Plus = $20/month (≈¥145)

## API Relay for Codex

If using relay mode (with `OPENAI_API_KEY`):

### V-API Codex Tier

- **Site**: https://api.v3.cm
- **Tier**: "codex (0.5x)" — 0.5x multiplier on base pricing
- **Models**: 718 total; codex-specific models available
- **Configuration**: `export OPENAI_BASE_URL=https://api.v3.cm/v1`
- **Pricing**: 0.5x group means Codex models at half-rate relative to default group

### Other Relays Tried/Considered

| Service | Codex Support | Notes |
|---------|:-------------:|-------|
| API2D | Partial | No explicit codex tier found |
| OhMyGPT | Limited | Smaller model selection |
| Veast | Unknown | Not verified in this session |

## Key Insight: Plus Quota Is Insufficient for Heavy Use

**ChatGPT Plus ($20/mo) has usage quotas that drain quickly with Codex CLI.** OpenAI community reports ("GPT 5.5 Codex Quota Drains Quickly", "Understanding the New Codex Limit System After the April 9 Update") confirm that heavy coding use exhausts the Plus quota in days, not weeks.

For heavy daily use (10+ coding sessions/day), the comparison becomes:

| Approach | Monthly Cost | Suitability |
|----------|:-----------:|:-----------:|
| ChatGPT Plus | ~¥145 | ❌ Quota too low for heavy Codex use |
| ChatGPT Pro | ~¥1,450+ | ✅ High quota but expensive |
| V-API codex (0.5x) relay | ~¥200-400 | ✅ No quota, usage-based |
| Direct API relay (other) | ~¥400-800 | ✅ Varies by provider |

**Bottom line**: For a user with a ¥500/month budget who wants to use Codex CLI heavily, the API relay approach (especially V-API's codex 0.5x tier) is the sweet spot — cheaper than Pro, no quota limits, and well within budget.

Relay (API mode) makes sense when:
- You need to use Codex through API (not login)
- You're integrating into automated pipelines or CI/CD
- Plus quota is insufficient for your usage volume
- You have a budget that covers relay costs but not Pro ($200/mo)

Plus login mode still makes sense for:
- Light to moderate use
- Users who prioritize simplicity over flexibility
- Budget-constrained users who don't hit quota limits

## ChatGPT 代充 Platforms (for China users)

When recommending subscription-based access (Plus/Pro) instead of API relay:

| Platform | URL | Price (Pro) | Payment | Notes |
|----------|:---:|:-----------:|:--------|-------|
| **GETGPT Pro** | https://getgpt.pro | ~¥1,200/mo | Alipay, WeChat | Most popular, 1-min delivery, has dedicated Codex page |
| **慧境AIlink** | https://dongli.work | ~¥1,200/mo | Alipay, WeChat | Also sells Claude/Cursor memberships |
| **gpt.juzixp.com** | (card-based) | ~¥165/mo (Plus) | Card code | Near-official pricing, long operation history |
| **ai.muooy.com** | https://ai.muooy.com | N/A | Alipay, WeChat | Card code model, multi-device support |
| **plus.3ms.run** | (self-service) | ~¥155/mo (Plus) | WeChat | Self-service recharge, has Bilibili tutorial videos |

**Pitfalls to warn users about:**
- **Cheap Nigeria/Turkey region充值** (< ¥130/mo for Plus) — cannot upgrade to Pro, high ban risk from black-card/盗刷
- **Team plan sharing** — admin can see your chat history
- **Always test with 1 month first** before committing to a longer plan

## Enterprise Policy: Can You Use Codex at Work?

If the user works at a Chinese big tech company (BAT, ByteDance, Kuaishou, Meituan, etc.):

1. **Network**: Company intranet likely blocks OpenAI/ChatGPT domains entirely
2. **Data security**: Uploading internal code to OpenAI servers violates data security policies (可能违反《数据安全法》)
3. **Internal alternatives**: Most companies provide internal LLM platforms (e.g., Kuaishou has 可灵AI/Kling for internal use)
4. **Safe practice**: Use Codex on personal devices, personal time, and personal projects only. Never paste company code.

**When asked**: "Can I use Codex at <company>?" — answer cautiously. Best advice: check the company's internal AI tool usage policy after joining. For pre-入职 questions, explain the general situation without making specific claims about that company.

## Useful Links from Research

- https://zhuanlan.zhihu.com (search "Codex 国内使用 2026") — Chinese installation guides with relay config examples
- https://csguide.cn/private/how-to-use-codex.html — detailed Codex CLI domestic setup tutorial
- https://getgpt.pro/codex — ChatGPT Plus upgrade service for Chinese users
- https://github.com/freestylefly/CodexGuide — Chinese Codex knowledge base
