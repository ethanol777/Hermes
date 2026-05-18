# Chat UI 模式参考

基于 rich 的对话界面实现笔记。适用于 AI Agent 项目的 CLI 前端改造。

## 文件结构

```
star/channels/
├── chat_ui.py    # ChatUI 类：消息渲染、spinner、输入、启动/退出
├── cli.py        # CLIChannel：对话主循环，集成所有模块
└── tui.py        # Dashboard：全屏实时监控仪表盘（独立的 Live 布局）
```

## ChatUI 类接口

```python
class ChatUI:
    def __init__(self, title="✨ Star"):
        # 初始化 Console，静音 HTTP 日志

    def start(self, info_lines=None):
        # 显示启动头部：名称 + 版本 + 时间戳 + 模块状态 + /help 提示

    def show_user(self, content):
        # 用户消息：cyan 圆角 Panel，标题 "👤 你  20:44:10"

    def show_star(self, content):
        # Star 回复：magenta 圆角 Panel，标题 "✨ Star  20:44:10"

    def show_system(self, content):
        # 系统消息：dim 圆角 Panel，无角色标签

    def show_raw(self, content):
        # 纯文本输出（命令反馈用）

    async def show_thinking(self, message="正在思考"):
        # 启动后台 spinner（dots 动画）

    async def hide_thinking(self):
        # 停止 spinner，清除痕迹

    async def input(self) -> str:
        # 彩色提示 "你 >"，async wrapper

    def goodbye(self):
        # 退出 Panel "✨ Star: 好的，下次见。"
```

## 对话主循环流程

```
用户输入 → show_user() → show_thinking() →
  [记忆系统处理] → [情绪更新] → [决策路由] → [技能/角色扮演生成] →
  hide_thinking() → show_star() → [记忆记录] → [情绪反馈] → [Token 追踪]
```

关键：`hide_thinking()` 放在 `finally` 块中保证异常时也执行。

## 日志静音配置

```python
NOISY_LOGGERS = [
    "httpx",
    "httpcore",
    "openai._base_client",
    "openai._client",
    "urllib3.connectionpool",
]

def suppress_noisy_loggers():
    for name in NOISY_LOGGERS:
        logging.getLogger(name).setLevel(logging.WARNING)
```

在 `__main__.py` 的 `async def main()` 中，`load_config()` 之后立即调用：

```python
config = load_config(str(config_path))
for _noisy in ["httpx", "httpcore", "openai._base_client", "openai._client"]:
    logging.getLogger(_noisy).setLevel(logging.WARNING)
logging.basicConfig(...)
```

## 终端测试

验证 spinner 和消息渲染：

```bash
timeout 5 .venv/Scripts/python -c "
import asyncio
from star.channels.chat_ui import ChatUI
ui = ChatUI('Star')
ui.start(['📚 记忆: 0 条', '🔌 MCP: 已连接'])
ui.show_user('今天天气怎么样？')
ui.show_star('挺好的，阳光很好～')
ui.show_system('系统消息正常')
print('✅ UI 正常')
"
```

验证日志静音（应输出 0 行 HTTP 噪声）：

```bash
cd D:/Code/Star
timeout 5 .venv/Scripts/python -m star 2>&1 <<< '/exit' | grep -cE 'httpx|openai.*Retrying'
# 输出: 0
```

## 已知问题

1. **Windows 控制台主题**：`box.ROUNDED` 的边框字符在旧版 Windows 终端（conhost）中可能显示为乱码。Windows Terminal / VS Code 内置终端正常。必要时降级为 `box.SQUARE`。
2. **Live + 多线程**：`rich.Live` 不是线程安全的。所有 Live 操作必须在主事件循环线程中执行。
3. **Spinner 退出时机**：如果 `show_thinking()` 和 `hide_thinking()` 之间的代码抛出同步异常且不被捕获，spinner 任务会泄漏。必须用 `try/finally` 确保 `hide_thinking()` 被调用。
4. **日志级别全局影响**：将 HTTP 库日志升到 WARNING 是全局的，会影响非对话场景（如后台 cron 也想看到 HTTP 请求日志）。如需细粒度控制，用 `logging.Logger.manager.disable` 或临时恢复级别。
