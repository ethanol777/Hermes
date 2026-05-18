---
name: agent-chat-interface
description: 基于 rich 的终端对话界面设计模式。消息 Panel 渲染、Kawaii 颜文字动画 spinner、状态栏、工具输出格式、HTTP 日志静音。参考 Hermes Agent 的 UI 设计（KawaiiSpinner, skin engine, response box, context bar）。
version: 1.0.0
---

# agent-chat-interface

Design patterns for building rich terminal chat interfaces for conversational AI agents. Inspired by Hermes Agent's UI conventions (KawaiiSpinner, skin engine, response boxes, context bar).

Use this skill when building or modifying a terminal-based chat interface for an AI agent — any time the task involves message display, loading indicators, tool output formatting, status bars, or input handling in a Python CLI chat app.

## Architecture

### Message Rendering (Rich Panel)

```
┌─ 👤 你  20:44:10 ───────────────────────────────────────────┐
│ 今天天气怎么样？                                              │
└──────────────────────────────────────────────────────────────┘

┌─ ⚕ AgentName  20:44:15 ─────────────────────────────────────┐
│ 挺好的，阳光很好～                                            │
└──────────────────────────────────────────────────────────────┘
```

Implementation:
- **User messages**: `Panel` with `border_style="cyan"`, title `👤 你`, `box=box.ROUNDED`
- **Agent replies**: `Panel` with `border_style="magenta"`, title `⚕ {name}`, `box=box.ROUNDED`
- **System messages**: `Panel` with `border_style="dim"`, dim italic text
- All include timestamp; each followed by empty line for spacing

```python
from rich.panel import Panel
from rich.text import Text
from rich import box
from rich.console import Console

console = Console()
panel = Panel(
    Text(content),
    title=f"[bold magenta]⚕ Name[/]  [dim]{ts}[/]",
    title_align="left", box=box.ROUNDED,
    border_style="magenta", padding=(0, 1),
)
console.print(panel)
console.print()  # spacing
```

### Animated Spinner with Kawaii Faces

Run spinner as `asyncio.Task` alongside the LLM call, using `\r` overwrite:

```python
import asyncio

SPINNER_FRAMES = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
THINKING_FACES = [
    "(｡•́︿•̀｡)", "(◔_◔)", "(¬‿¬)", "( •_•)>⌐■-■",
    "(´･_･`)", "◉_◉", "(°ロ°)", "ヽ(>∀<☆)☆",
]

async def thinking_loop(message: str, stop_flag):
    idx = 0
    face_idx = 0
    while stop_flag():
        frame = SPINNER_FRAMES[idx % len(SPINNER_FRAMES)]
        face = THINKING_FACES[face_idx % len(THINKING_FACES)]
        print(f"\r  {frame} {face} {message}...  ", end="", flush=True)
        idx += 1
        if idx % 6 == 0:
            face_idx += 1
        await asyncio.sleep(0.1)
    print("\r" + " " * 60 + "\r", end="", flush=True)
```

Key points:
- `\r` overwrite — no `rich.Live` needed
- Rotate frame and face at different rates
- Clear line before final output
- `asyncio.sleep(0.1)` = ~10fps

### Tool Output (┊ Prefix)

```python
console.print(f"  ┊ [dim]{tool_name}[/] {detail}{dur}")
```
Example: `  ┊ weather get_forecast 北京 (0.3s)`

### Status / Context Bar

```python
console.rule(style="dim")
console.print(f"[dim]━━━ 💰 {pct}  {icon} {emotion}  📚 {h}/{w}  🔌 MCP ━━━[/]")
```

### Input (Cross-Platform)

```python
text = await asyncio.get_event_loop().run_in_executor(
    None,
    lambda: console.input("[bold cyan]你 >[/] ").strip(),
)
```

### Log Suppression

```python
import logging
for name in ["httpx", "httpcore", "openai._base_client", "openai._client", "urllib3.connectionpool"]:
    logging.getLogger(name).setLevel(logging.WARNING)
```

## Pitfalls

- **prompt_toolkit + git-bash/MSYS2**: raises `NoConsoleScreenBufferError`. Use `rich.console.input()` instead.
- **\r spinner + patch_stdout**: `StdoutProxy` corrupts `\r` frames. Use plain `print()`.
- **Noisy HTTP logs**: httpx/openai log every request at INFO. Set to WARNING before chat loop.

## References

- Hermes `hermes_cli/curses_ui.py` — curses multi-select checklists
- Hermes `agent/display.py` — KawaiiSpinner (faces, frames, wings, verbs)
- Hermes `hermes_cli/skin_engine.py` — YAML skin system (colors, spinner, branding, tool_emojis)
- Hermes `cli.py` — prompt_toolkit HSplit layout + status bar + context usage bar
