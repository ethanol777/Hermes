---
name: pi-coding-agent
description: |
  Install, configure, and extend earendil-works/pi — a self-extensible AI coding agent CLI
  with TUI, multi-provider support, and custom provider/extension registration.
trigger: |
  - User asks about "pi" agent or earendil-works/pi
  - User wants to install pi or configure a custom LLM provider
  - User needs to write a custom provider extension
  - Comparing pi with other coding agents (claude-code, codex)
---

# Pi Coding Agent

## Installation

Requires Node.js (v18+):

```bash
npm install -g @earendil-works/pi-coding-agent
```

Verify installation:
```bash
pi --version
```

## Configuration

Set API key via environment variable (provider is auto-detected):

```bash
export OPENAI_API_KEY=sk-...
export ANTHROPIC_API_KEY=sk-ant-...
export GOOGLE_API_KEY=...
```

## Basic Usage

```bash
pi                              # Interactive TUI in current directory
pi /path/to/project             # TUI in specific directory
pi --model gpt-4o              # Specify model
pi --provider openai --model gpt-4o-mini "task"  # One-shot
pi --list-models               # Show all available models
pi --no-tools -p               # Print-only mode (non-interactive)
pi config                      # TUI for enabling/disabling resources
pi install ./my-extension.ts   # Install and register an extension
pi update                      # Update pi and extensions
```

## Custom Providers via Extensions

Pi supports custom LLM providers via TypeScript extensions that call `pi.registerProvider()`.
The extension must export a **default factory function** taking `ExtensionAPI`.

### Extension Locations

Extensions are auto-discovered from:
- `~/.pi/agent/extensions/` — global (use this on Windows)
- `.pi/extensions/` — project-local

Registration (needed for Windows):
```bash
cd ~/.pi/agent/extensions
pi install ./my-provider.ts
```

The install command writes to `~/.pi/agent/settings.json` under `packages`.

### Custom Provider Template

```typescript
import type { ExtensionAPI } from "@earendil-works/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.registerProvider("my-provider", {
    name: "My Provider",
    baseUrl: "https://api.example.com/v1",
    apiKey: "MY_API_KEY",       // literal or env var name
    api: "openai-completions",   // streaming API type
    authHeader: true,            // adds Authorization: Bearer header
    models: [
      {
        id: "my-model",
        name: "My Model",
        reasoning: false,
        input: ["text"],
        cost: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0 },
        contextWindow: 128000,
        maxTokens: 8192,
        // streamSimple: customStreamHandler,  // see below
      }
    ],
  });
}
```

### Custom Streaming (streamSimple)

For non-standard streaming APIs, write a `streamSimple` handler.
This is **required** when the API's SSE format differs from OpenAI's standard chunk format.

Common issue: APIs that put `finish_reason` on role-only chunks (not on content chunks).
Pi's built-in parser requires `finish_reason` on a chunk that also has text delta — if the API only sends `finish_reason` on a separate role-only chunk, streaming breaks with "Stream ended without finish_reason".

Handler skeleton:
```typescript
import {
  type AssistantMessageEventStream,
  type Context, type Model, type SimpleStreamOptions,
  createAssistantMessageEventStream,
} from "@earendil-works/pi-ai";

function streamMyProvider(model: Model<any>, context: Context, options?: SimpleStreamOptions): AssistantMessageEventStream {
  const stream = createAssistantMessageEventStream();

  (async () => {
    const output = {
      role: "assistant", content: [], api: model.api,
      provider: model.provider, model: model.id,
      usage: { input: 0, output: 0, cacheRead: 0, cacheWrite: 0, totalTokens: 0 },
      stopReason: "stop" as const, timestamp: Date.now(),
    };
    try {
      stream.push({ type: "start", partial: output });
      // ... fetch + parse chunks ...
      // KEY: emit text_delta ONLY when content is non-empty
      // KEY: set output.stopReason when you see finish_reason
      stream.push({ type: "done", reason: output.stopReason, message: output });
      stream.end();
    } catch (err) {
      output.stopReason = "error";
      output.errorMessage = err instanceof Error ? err.message : String(err);
      stream.push({ type: "error", reason: "error", error: output });
      stream.end();
    }
  })();
  return stream;
}
```

Attach per-model: `{ ..., streamSimple: streamMyProvider }`.

## Supported Streaming API Types (`api` field)

| `api` value | Use for |
|---|---|
| `openai-completions` | OpenAI Chat Completions and compatible APIs |
| `anthropic-messages` | Anthropic Claude API and compatible |
| `openai-responses` | OpenAI Responses API |
| `mistral-conversations` | Mistral Conversations API |
| `google-generative-ai` | Google Generative AI |
| `google-vertex` | Google Vertex AI |
| `bedrock-converse-stream` | Amazon Bedrock Converse API |

## Key Features

- **Self-extensible**: Agent can modify its own code via extensions
- **Custom providers**: Register any OpenAI-compatible API
- **Interactive TUI**: Terminal UI with differential rendering
- **Multi-provider**: Unified API for OpenAI, Anthropic, Google, and custom
- **Session sharing**: Publish sessions to Hugging Face

## Comparison with Other Agents

| Feature | Pi | Claude Code | Codex |
|---------|-----|-------------|-------|
| Self-extensible | Yes | No | No |
| TUI | Yes | Yes | Yes |
| Multi-provider | Yes | No (Anthropic only) | No (OpenAI only) |
| Custom streaming | Yes (streamSimple) | No | No |

## Pitfalls

- **Windows + Node.js**: Extensions must use `.ts` files (`.js` fails to load via jiti). Use `pi install ./ext.ts` from the extensions directory.
- **Non-standard streaming**: Many third-party APIs have chunk formats that differ from OpenAI spec — the built-in parser will fail with "Stream ended without finish_reason". Always write a custom `streamSimple` handler for these.
- **Extension not loading**: If a provider doesn't appear in `--list-models`, the extension may not be loaded. Check `~/.pi/agent/settings.json` for the package entry. Duplicate entries (e.g. both `.js` and `.ts`) can cause issues — clean up to one.
- **Rate limits**: Some third-party APIs (e.g. token.android-doc.com) have very low rate limits — streaming calls can return 429 quickly.
- **Thinking tokens consuming all output budget**: DeepSeek-based APIs often return `delta` with reasoning tokens but empty `content` — the model spends the entire `max_tokens` budget on internal reasoning, leaving nothing for actual output. **Fix**: set `extraBody: { thinking: { type: "off" } }` on the provider AND `reasoning: false` on each model. See `references/token-android-api.md` for the full reproduction.
- **Setting thinking off in the wrong place**: `thinking: { type: "off" }` must go in `extraBody` at the provider level — not in a custom `streamSimple` handler's body object. The extraBody gets merged into the API request automatically by pi's built-in handler.