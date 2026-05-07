# Reasonix Setup

Reasonix is a DeepSeek-native AI coding agent (terminal-based, similar to Claude Code). On this machine, it's configured to route through the opencode-go provider.

## Installation

```bash
npm install -g reasonix
```

Requires Node 22+.

## Configuration (opencode-go relay)

Reasonix expects `DEEPSEEK_API_KEY` and `DEEPSEEK_BASE_URL`. Since we use opencode-go as provider:

```bash
export DEEPSEEK_API_KEY="sk-ajpaboZaxUygJjxwoHmKahrjfuAu5vcKj2XvGQPUuer1YYqHCRXwJSdqGi5siWo8"
export DEEPSEEK_BASE_URL="https://opencode.ai/zen/go/v1"
```

Or save persistent config:

```json
{
  "apiKey": "sk-...",
  "baseUrl": "https://opencode.ai/zen/go/v1",
  "model": "deepseek-v4-flash"
}
```

to `~/.reasonix/config.json`.

## Known Quirks

- `/user/balance` endpoint is DeepSeek-specific → `reasonix doctor` will show "auth failed" for this check. Ignore it; `/chat/completions` works fine.
- Use `reasonix run "<task>"` for one-shot tasks, `reasonix chat` for interactive TUI, `reasonix code` for coding agent mode.
- Model can be overridden per-run with `-m deepseek-v4-flash`.

## Usage

```bash
reasonix run "你的任务"
reasonix code    # 编程 agent 模式
reasonix chat   # 对话模式
```
