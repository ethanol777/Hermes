# MCP Context Bloat Analysis — quandri.io

来源：[quandri.io/blog/mcp-is-dead](https://quandri.io/blog/mcp-is-dead)（2026-05-30 发现）

## 核心数据

| 指标 | 数值 |
|------|------|
| Quandri 栈：77个 MCP 工具 | ~84,308 字符 / ~21,077 tokens |
| 占 Claude 200K context | 10.5% |
| 占 GPT-4o 128K context | **16.5%** |
| Linear 一个 MCP server（42工具） | ~12,807 tokens |
| MCP 首次调用 vs REST API | **9.4x 慢** |
| MCP 单次调用 vs REST API | 3x 慢 |

## MCP 的三个核心问题

### 1. Context Window 消耗
工具定义在连接时全部加载，即使只用其中 2 个。

**餐厅比喻：**
- 你坐下，10份菜单铺满桌子
- 没有空间放真正的食物
- 每次点菜，菜单又要重新摊开

### 2. 可靠性低
- 初始化失败、重复认证
- MCP server 进程崩溃（session 中工具死亡）
- 外部进程轮询延迟
- 权限不透明

### 3. 与 CLI/API 功能重叠
| 维度 | CLI/API | MCP |
|------|---------|-----|
| 人机一致性 | 同一命令 | 只在 LLM 对话中有效 |
| 可组合性 | pipes/jq/grep 自由组合 | 锁定在 server 返回格式 |
| 调试 | 终端直接复现 | 只在对话上下文内可复现 |
| 训练数据 | 已有 man pages/StackOverflow | 需单独工具定义 |

## Skills 替代方案

**核心优势：** 按需加载，不用不占 context。

Claude Code 已实现 **Deferred Loading**，将工具定义 context 消耗降低 **85%+**。

```
Skills approach:
- Linear API: https://api.linear.app/graphql
- Auth: Bearer Token ($LINEAR_TOKEN env)
- Get issue: curl -s -H "Authorization: Bearer $LINEAR_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"query":"{ issue(id: \"ISSUE-ID\") { title state { name } } }"}'
→ Prompt: ~200 tokens
→ Response: ~150 tokens
vs MCP: ~13,000 tokens（工具定义）+ 调用开销
```

## 数据库场景的判断

| 场景 | 推荐 | 原因 |
|------|------|------|
| 本地开发/个人 DB | Skills + CLI | 轻量、快速，错误易恢复 |
| 生产 DB/共享团队 | MCP | 安全护栏、查询验证、访问控制必须在 server 层 |

## 结论

MCP 不是「死亡」——是**高工具密度场景**下的架构选择问题。在简单场景（1-2个工具）下，MCP 的标准化优势仍然成立。但在 20+ 工具的企业栈里，context bloat 和进程可靠性是真实的工程代价。

**相关 skill：** `mcp-builder`（MCP 服务器构建方法论）
