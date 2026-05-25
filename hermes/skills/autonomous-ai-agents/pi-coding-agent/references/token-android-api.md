# Token Android API Reference

API: `https://token.android-doc.com/api/token/v1`
Token: `tk_870d937131639da62f26f63afd4ad4f5484ffb6293dfdb3a`

## Chunk Format (non-standard)

```json
// Role-only chunk (no content)
data: {"id":"...","choices":[{"index":0,"delta":{"role":"assistant"},"created":...,"usage":{}}]}

// Content chunk — finish_reason appears ON THE SAME CHUNK as content
data: {"id":"...","choices":[{"index":0,"delta":{"content":"Hi","role":"assistant"},"finish_reason":"length","created":...,"usage":{}}]}

data: [DONE]
```

**Critical**: `finish_reason` is on the content chunk, not on a separate role-only chunk. This is actually compatible with the built-in OpenAI parser — but only if the API returns content at all.

## The Real Problem: Thinking Tokens

Without `thinking: { type: "off" }`, the API returns reasoning tokens in the `delta` field but **empty `content`** in the non-streaming response. All `max_tokens` budget gets consumed by thinking, leaving nothing for actual output.

```bash
# Without thinking:off — content is always empty
curl -d '{"model":"deepseek-v4-flash","messages":[{"role":"user","content":"2+2="}],"max_tokens":50}'
# → {"message":{"content":""}, ...}

# With thinking:off — content returns normally
curl -d '{"model":"deepseek-v4-flash","messages":[{"role":"user","content":"2+2="}],"max_tokens":50,"thinking":{"type":"off"}}'
# → {"message":{"content":"4"}, ...}
```

## Working Extension

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("token-android", {
    name: "Token Android",
    baseUrl: "https://token.android-doc.com/api/token/v1",
    apiKey: "tk_870d937131639da62f26f63afd4ad4f5484ffb6293dfdb3a",
    api: "openai-completions",
    extraBody: { thinking: { type: "off" } },
    models: [
      {
        id: "deepseek-v4-flash",
        name: "DeepSeek V4 Flash",
        reasoning: false,           // Must be false — tells pi not to expect thinking
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 8192,
      },
      // ... other models
    ],
  });
}
```

## Available Models

```json
["deepseek-v4-flash","deepseek-v4-pro","GPT-5.5","Opus-4.7","kimi-k2.6","QWen-3.6","glm-5.1","minimax-m2.7","minimax-m2.7-highspeed","BerryPi-text-01","mimo-v2.5","mimo-v2.5-pro"]
```

## Rate Limits

- 30 requests/minute per token
- Streaming calls hit rate limit faster
- "API调用太频繁" = rate limited, wait before retry
