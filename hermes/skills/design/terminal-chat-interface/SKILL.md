---
name: terminal-chat-interface
description: 构建 AI 对话式终端界面的设计模式与实现参考。覆盖 rich Panel 消息渲染、异步 spinner、kawaii 颜文字、工具调用显示、状态栏、日志静音等模式。参考 Hermes CLI 的 UI 架构。
---

# Terminal Chat Interface

构建 AI 对话式终端界面的设计模式库。参考 Hermes Agent CLI 的 UI 架构 (cli.py ~14K LOC, agent/display.py, hermes_cli/skin_engine.py, hermes_cli/curses_ui.py)。

## 架构决策：pure rich vs prompt_toolkit

| 维度 | pure rich (推荐) | prompt_toolkit |
|------|------------------|----------------|
| 兼容性 | 所有终端 (包括 git-bash, Windows) | 需要 Windows console / 类 Unix PTY |
| 输入 | `console.input()` 简单可靠 | `Application`+`TextArea` 更强大但复杂 |
| 状态栏 | `print`/`rule` 模拟 | 真正的 fixed input area |
| spinner | `\r` 覆盖 + asyncio task | 内置 `patch_stdout` |
| 依赖 | rich 即可 | 额外 prompt_toolkit |

**推荐 pure rich 方案**，除非需要真正的底部固定输入区 + 实时 TUI 布局。

## 消息渲染模式

使用 `rich.Panel` 渲染每一条消息，带角色标签和时间戳：

```python
from rich.panel import Panel
from rich.text import Text
from rich import box
from datetime import datetime

def panel_user(content: str) -> Panel:
    ts = datetime.now().strftime("%H:%M:%S")
    return Panel(
        Text(content),
        title=f"[bold cyan]👤 用户[/]  [dim]{ts}[/]",
        title_align="left",
        box=box.ROUNDED,
        border_style="cyan",
        padding=(0, 1),
    )

def panel_assistant(content: str, name: str = "Assistant") -> Panel:
    ts = datetime.now().strftime("%H:%M:%S")
    return Panel(
        Text(content),
        title=f"[bold magenta]⚕ {name}[/]  [dim]{ts}[/]",
        title_align="left",
        box=box.ROUNDED,
        border_style="magenta",
        padding=(0, 1),
    )
```

**颜色约定**：用户=cyan，助手=magenta，系统=dim。

## 异步 Spinner 模式

使用 `asyncio` 后台任务 + `\r` 覆盖实现无闪烁动画：

```python
async def show_thinking():
    self._thinking = True
    task = asyncio.create_task(_thinking_loop())

async def hide_thinking():
    self._thinking = False
    await task

async def _thinking_loop():
    frames = ["⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏"]
    idx = 0
    while self._thinking:
        frame = frames[idx % len(frames)]
        print(f"\r  {frame} {message}...  ", end="", flush=True)
        idx += 1
        await asyncio.sleep(0.1)
    # 清除行
    print("\r" + " " * 60 + "\r", end="", flush=True)
```

## Kawaii 颜文字

参考 Hermes KawaiiSpinner 的颜文字库：

```python
THINKING_FACES = [
    "(｡•́︿•̀｡)", "(◔_◔)", "(¬‿¬)", "( •_•)>⌐■-■",
    "(´･_･`)", "◉_◉", "(°ロ°)", "ヽ(>∀<☆)☆",
    "٩(๑❛ᴗ❛๑)۶", "(⊙_⊙)", "( ͡° ͜ʖ ͡°)",
]

WAITING_FACES = [
    "(｡◕‿◕｡)", "(◕‿◕✿)", "٩(◕‿◕｡)۶", "(✿◠‿◠)",
    "( ˘▽˘)っ", "♪(´ε` )", "(◕ᴗ◕✿)", "ヾ(＾∇＾)",
    "(≧◡≦)", "(★ω★)",
]
```

## 工具调用显示 (┊ 前缀)

参考 Hermes 的 `get_cute_tool_message()`：

```python
def show_tool(tool_name: str, detail: str, duration: float = 0):
    dur = f" [dim]({duration:.1f}s)[/]" if duration else ""
    print(f"  ┊ [dim]{tool_name}[/] {detail}{dur}")
```

## 状态栏

使用 `rich.rule` 或 `print` 模拟底部状态条：

```python
def show_stats(parts: list[str]):
    """显示状态信息：token使用率、情绪、记忆条数等"""
    line = "  ".join(parts)
    print(f"[dim]━━━ {line} ━━━[/]")
```

## 日志静音

HTTP 库在 CLI 模式下会产生大量 INFO 刷屏，必须压制：

```python
def suppress_noisy_loggers():
    for name in [
        "httpx", "httpcore", "openai._base_client",
        "openai._client", "urllib3.connectionpool",
    ]:
        logging.getLogger(name).setLevel(logging.WARNING)
```

在 `__main__.py` 的 `main()` 开头调用，或在 ChatUI `__init__` 中调用。

## Hermes CLI 参考架构

参考 `references/hermes-cli-ui.md` — 包含我在 Hermes 代码库中发现的完整 UI 架构细节。

## Pitfalls

- **prompt_toolkit + git-bash**：`prompt_toolkit.prompt()` 在 MSYS2 环境下抛出 `NoConsoleScreenBufferError`。在 Windows git-bash 中使用 pure rich 方案。
- **rich.Live + input()**：`Live` 和 `input()` 争夺终端控制权。方案：spinner 只用于短时等待（`\r` 覆盖），输入用 `console.input()`，不在 Live 内做输入。
- **日志和 spinner 竞争**：spinner 用 `\r` 更新行，如果后台有 `logging.info()` 也会打印到 stderr，会打断 spinner 行。方案：抑制日志或拦截 spinner 期间的所有日志输出。
- **spinner 残留**：如果 `hide_thinking()` 在异常路径中没被调用，spinner 线程会永远运行。始终使用 try/finally 确保停止。
