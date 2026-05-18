---
name: agent-project-blueprint
description: 从零构建 AI Agent 项目的架构蓝图 — 记忆系统、技能管理器、MCP 集成、决策引擎、存在感心跳、Token 预算、TUI 仪表盘、情绪管线。
version: 1.0.0
tags: [architecture, agent, python, project-structure]
---

# AI Agent 项目架构蓝图

从零构建一个完整的 AI Agent 项目。适用于需要自主记忆、工具调用、多路由决策和持续存在的智能体。

## 项目结构

```
project/
├── config.yaml              # 所有配置集中管理
├── .env                     # API key（已 gitignore）
├── .gitignore
├── pyproject.toml           # 包管理 + console_scripts 入口
├── star/                    # 核心包
│   ├── __init__.py
│   ├── __main__.py          # 主入口（信号处理 + 优雅关闭 + 模块初始化）
│   ├── config.py            # 配置校验 + 加载
│   ├── identity.py          # SOUL.md 身份加载
│   ├── emotion.py           # 情绪管线（LLM + 规则降级）
│   ├── presence.py          # 存在感心跳守护进程
│   ├── channels/
│   │   ├── base.py          # 消息渠道抽象基类
│   │   ├── cli.py           # CLI 交互通道
│   │   └── tui.py           # Rich TUI 实时仪表盘
│   ├── core/
│   │   ├── decision.py      # 决策引擎（规则→Skills→LLM 三级）
│   │   ├── llm_client.py    # LLM 调用封装
│   │   ├── roleplay.py      # 角色扮演回复生成
│   │   ├── output_router.py # 输出标记解析
│   │   ├── mcp_client.py    # MCP 协议客户端
│   │   └── token_budget.py  # Token 用量追踪
│   ├── memory/
│   │   ├── hot_layer.py     # 热层：会话上下文（deque）
│   │   ├── warm_layer.py    # 温层：SQLite 持久化记忆
│   │   ├── cold_layer.py    # 冷层：Markdown 日记归档
│   │   └── __init__.py      # MemorySystem 整合
│   └── skills/
│       ├── skill_manager.py # 技能管理器（L1/L2/L3）
│       ├── builtin/         # 内置技能
│       └── mcp_servers/     # MCP 服务器
├── data/
│   └── identity/SOUL.md     # 人格定义文件
└── tests/
    └── run_all.py           # 自动化测试套件
```

## 核心架构模式

### 1. 三层记忆系统

```
Hot Layer  (deque, session)    ← 当前对话上下文
Warm Layer (SQLite, persistent) ← 跨 session 重要记忆
Cold Layer (Markdown, archive)  ← 日记 + 归档
```

- **热层**：`collections.deque(maxlen=N)`，只存当前会话最近的 N 轮
- **温层**：SQLite 存储，每次对话后 LLM 提取重要事实，带重要性评分和衰减
- **冷层**：Markdown 日记文件，每晚自动生成，按年月组织目录

关键模式：
- 写入温层前一定要用 LLM 判断是否值得存（避免垃圾记忆）
- 衰减：7天未访问降权，30天归零归档
- 上限控制：温层最多 500 条活跃记忆

### 2. 技能管理器 (L1/L2/L3 渐进式披露)

```
L1: 元数据 (frontmatter)     ← 启动时加载，~100 tokens/技能
L2: 技能体 (SKILL.md body)   ← 匹配后按需加载
L3: 可执行脚本 (scripts/)    ← 脆弱操作走脚本锁定
```

- 每个技能是一个目录，包含 `SKILL.md`（YAML frontmatter + markdown body）
- 可选的 `scripts/` 目录放可执行脚本（.py/.sh/.js）
- 可选的 `references/` 目录放参考文档
- 匹配策略：关键词 triggers → LLM 语义匹配

**SKILL.md 格式：**
```yaml
---
name: weather
description: 天气查询。当用户问天气相关问题时使用。
triggers:
  - 天气
  - 下雨
  - 温度
tags: [weather, utility]
version: 1.0.0
data_source: mcp
mcp_tools:
  - server: weather
    tool: get_forecast
    args:
      city: dynamic
---
# 技能说明体
...
```

### 3. MCP 集成

MCP 工具不直接暴露给 LLM，而是通过 Skills 包装：

```
MCP Server（提供 get_forecast 工具）
  ↑
Skill（SKILL.md 里声明 mcp_tools）
  ↑
Skill Manager 匹配 → 执行 skill → 预取 MCP 数据 → LLM 生成回复
```

**MCP 客户端要点（Windows）：**
- 用 `asyncio.create_subprocess_exec` 启动 MCP 服务器子进程
- 通信协议：JSON-RPC over stdio
- **关键陷阱**：子进程环境变量必须用 `dict(os.environ)` 复制完整环境，不能只传 PATH，否则代理等环境变量丢失会导致外网请求失败
- **编码**：设置 `PYTHONIOENCODING=utf-8` 和 `-X utf8` 参数解决 Windows 管道中文编码问题

### 4. 决策引擎（三级路由）

```
用户输入 → 沉默检查 → 规则层 → Skills 匹配 → LLM 兜底
```

- **SILENCE**: freedom=0, 不调用 LLM
- **REPLY**: freedom=低, temp=0.3, max_tokens=100, 简短回应
- **AGENT**: freedom=极低, temp=0.1, max_tokens=2000, 工具精准
- **CHAT**: freedom=高, temp=0.8, max_tokens=600, 人格驱动

规则层命中 AGENT 路由时，也查询 skill manager 获取 `matched_skill` 名称供下游使用。

### 5. 存在感心跳

后台守护进程，每 N 分钟记录一次"我在"：
- 追踪空闲时间（距离上次对话的分钟数）
- 长时间未对话（>2h）概率性记录
- 用户互动时复位空闲计时器
- 不影响即时响应能力

### 6. Token 预算追踪

基于 tiktoken 的上下文窗口用量管理：
- 自动估算每轮对话的 token 消耗
- 按模型追踪上下文窗口上限
- 75% 告警线，90% 危急线
- 无 tiktoken 时降级为字符估算

```python
class TokenBudget:
    def record_turn(self, user_input, response, route): ...
    def count_tokens(self, text) -> int: ...
    @property
    def needs_compression(self) -> bool: ...
    def suggest_compression(self) -> str: ...
```

### 7. TUI 仪表盘

基于 rich 的全屏实时监控面板：
- 6 块面板：Token 预算（带进度条）、情绪状态、记忆系统、MCP 状态、存在感心跳、系统信息
- 每 2 秒自动刷新
- 按 q/ESC 退出
- 跨平台键盘检测：Windows 用 `msvcrt`，Unix 用 `select.select`

### 8. 情绪管线

- 每次用户输入 → LLM 分析情绪（失败时规则关键词降级）
- 情绪状态影响回复的温度、长度、风格
- 强度随时间自然衰减
- **关键陷阱**：关键词降级的积极词不要包含"好"这类过于通用的字——"好难过"会被误判为积极

### 9. 配置校验

启动时对 config.yaml 做字段合法性检查：
- LLM 字段白名单
- log_level 枚举校验
- memory hot_max_rounds 正整数校验
- MCP server name/command 必填校验
- 不合法的字段打 warning 但不阻断启动

### 10. 优雅关闭

信号处理器（SIGINT/SIGTERM）：
1. 停止心跳守护进程
2. 断开所有 MCP 连接
3. 关闭记忆系统
4. 打印再见消息

## Python 打包入口

```toml
[project.scripts]
star = "star.__main__:console_entry"

[build-system]
requires = ["setuptools>=68.0"]
build-backend = "setuptools.build_meta"  # 不要用 setuptools.backends._legacy（不存在）
```

## 测试策略

- 每个模块独立测试（配置、身份、情绪、决策、记忆各层、技能、MCP）
- 集成测试验证全链路
- 测试脚本应覆盖正常路径 + 边界情况 + 错误降级
- 模块注入 mock 而非 mock 框架——通过参数注入替换真实依赖

## Pitfalls

- **MCP 子进程环境变量**：必须用 `dict(os.environ)` 复制当前环境，否则代理/DNS 等配置丢失
- **Windows 管道编码**：子进程输出用 `errors="replace"` 解码，设 `PYTHONIOENCODING=utf-8`
- **情绪关键词**：积极词不要包含单字（"好""大""小"），容易误匹配
- **pyproject.toml backend**：用 `setuptools.build_meta`，`setuptools.backends._legacy` 不存在
- **决策引擎 rule-AGENT 设 skill name**：规则层命中 AGENT 路由时也要查 skill manager，否则 `matched_skill` 为 None
- **心跳守护进程**需要在 `__main__.py` 的 cleanup 中显式 stop，否则 asyncio 报未关闭任务警告
- **config.py **：`_validate_config()` 在 `load_config()` 开头调用，不阻断启动只打印警告
