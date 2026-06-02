# Star 项目架构参考（2026-05-18）

基于 VLA 机器人论文答辩项目之外的 Star 虚拟恋人智能体项目。可作为"从设计文档到可运行系统"的完整实现案例。

## 项目结构

```
D:\Code\Star\
├── config.yaml                 # 主配置（LLM/记忆/MCP/心跳）
├── pyproject.toml              # 入口: `star` 命令
├── .env                        # API key（已 .gitignore）
├── data/
│   └── identity/SOUL.md        # 身份文件（名字/价值观/个性/说话风格）
├── star/
│   ├── __main__.py             # 入口 + 优雅关闭 + 资源初始化
│   ├── config.py               # 配置加载 + 字段校验
│   ├── identity.py             # SOUL.md 加载器
│   ├── emotion.py              # 情绪引擎（LLM + 规则降级）
│   ├── presence.py             # 存在感心跳后台任务
│   ├── channels/
│   │   ├── base.py             # ChannelBase 抽象类
│   │   └── cli.py              # CLI 交互（/help /debug /budget /presence）
│   ├── core/
│   │   ├── llm_client.py       # LLM API 封装
│   │   ├── decision.py         # 决策引擎 + 自由度光谱
│   │   ├── roleplay.py         # 回复生成（system prompt + LLM）
│   │   ├── output_router.py    # 输出标记解析
│   │   ├── mcp_client.py       # MCP 协议客户端（JSON-RPC over stdio）
│   │   └── token_budget.py     # Token 预算跟踪
│   ├── memory/
│   │   ├── hot_layer.py        # session 级 deque（10-20 轮）
│   │   ├── warm_layer.py       # SQLite 持久化 + LLM 提取
│   │   ├── cold_layer.py       # Markdown 日记 + 归档
│   │   └── __init__.py         # MemorySystem 整合
│   └── skills/
│       ├── skill_manager.py    # L1/L2/L3 渐进加载 + MCP 预取
│       ├── builtin/
│       │   ├── weather/        # 天气查询（MCP 数据源）
│       │   ├── time-date/      # 时间日期
│       │   └── anniversary/    # 纪念日提醒
│       └── mcp_servers/
│           └── weather_server.py  # 天气 MCP 服务器（open-meteo）
├── tests/
│   └── run_all.py              # 122 项自动化集成测试
└── .gitignore
```

## 数据流

```
用户输入 → Silence 检查 → 规则层 → Skills 匹配 → LLM 兜底
                              ↓               ↓
                          REPLY/CHAT      AGENT 路由
                                            ↓
                                      Skill Manager
                                            ↓
                                    MCP 数据预取(可选)
                                            ↓
                                      LLM 生成回复
```

## 关键指标

- **总代码行**: ~3,800（不含 venv）
- **测试**: 122 项，100% 通过
- **LLM 模型**: deepseek-v4-flash（opencode 通道）
- **MCP 工具**: 2 个（get_forecast, geocode），50+ 中国城市支持
- **启动时间**: ~3 秒（含 MCP 子进程初始化）
- **Token 预算**: deepseek-v4-flash 上限 64K，跟踪 3 级报警

## 关键决策记录

| 决策 | 选择 | 理由 |
|------|------|------|
| 身份存储 | 文件（SOUL.md） | 不受 git 影响，可版本管理，不改代码 |
| 记忆持久化 | SQLite | 零依赖，够用，比 JSON 文件可靠 |
| 技能匹配 | 规则+LLM 双通道 | 规则快（O(n)），LLM 兜底（处理模糊请求） |
| MCP 传输 | stdio subprocess | 简单可靠，不需要 network port |
| 情绪规则降级 | 关键词（无 LLM 时） | LLM 不可用时静默降级，不中断体验 |
| 配置校验 | warning 不阻止启动 | 坏配置不致命，用户可以在运行时改 |
