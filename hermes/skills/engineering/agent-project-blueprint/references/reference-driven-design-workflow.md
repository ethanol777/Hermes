---
name: reference-driven-architecture-design
description: "从参考项目中提取架构模式，为特定场景设计 AI agent 应用——产出 PRD、技术方案、测试用例三步文档"
version: 1.0.0
---

# Reference-Driven Architecture Design

从现有的参考项目（如 EchoBot、Hermes Agent、OpenClaw）中提取架构模式，
为特定场景设计 AI agent 应用。产出标准化的三件套文档。

## 什么时候用

- 用户想做一个新 AI 应用，给了参考项目链接
- 需要调研现有方案的架构，提取可复用的模式
- 目标：产出一份可执行的 PRD + 技术方案 + 测试用例

## 工作流

### Step 1: 分析参考项目

对每个参考项目，提取：

1. **目录结构** — 项目怎么组织的，核心包/模块划分
2. **核心架构** — 数据流、分层、模块间关系
3. **关键设计决策** — 为什么这么分？哪层决策最难？
4. **可复用模式** — 能直接搬到新项目中的设计
5. **可避免的坑** — 项目中明显的问题或过度设计

重点关注：
- 消息处理管线（输入→路由→处理→输出）
- 身份/人格系统（怎么保持一致性）
- 记忆系统（热/温/冷分层）
- 多模态表达（文字/语音/图片的切换）
- 存在感系统（心跳、主动触达）

### Step 2: 合成架构

合并多个参考项目的精华，适配目标场景：

1. **确定场景核心矛盾** — 比如虚拟恋人的"不是工具但用代码造"的矛盾
2. **选取路由架构** — 从 EchoBot 的三层决策，或 Hermes 的单层 agent 循环
3. **设计身份层** — SOUL.md 方案（文件级，不受 git 影响）
4. **设计记忆层** — 热（上下文）/ 温（SQLite 事实）/ 冷（归档）
5. **设计存在感层** — 心跳、日记、闲逛、反思
6. **设计输出路由** — 文字 / 语音(TTS) / 图片(表情包/生成) / 沉默

### Step 3: 产出三件套文档

#### PRD.md — 产品需求文档

结构：
```
# Star — PRD
## 1. 产品定位        — 一句话说清楚不是啥、是啥
## 2. 核心功能        — P0/P1/P2 分级
## 3. 架构概览        — ASCII 架构图 + 分层说明
## 4. 人格一致性要求    — 虚拟恋人类产品独有的约束
## 5. 多模态表达策略    — 每种模态什么时候用
## 6. 成功指标        — 日活、留存、沉默比例
## 7. 边界情况        — 用户长时间不联系、情绪低落、测试
```

#### TECH_DESIGN.md — 技术方案

结构：
```
# Star — 技术方案
## 1. 整体架构        — 目录结构 + 数据流图
## 2. 各模块详细设计    — 每个模块的类图/接口/数据流
## 3. LLM 配置        — 三层模型策略（decision/roleplay/agent）
## 4. TTS 方案        — Phase 1/2/3 渐进路线
## 5. 图片方案        — 表情包/涂鸦/生成
## 6. 渠道集成        — Telegram/Web UI/CLI
## 7. 性能与资源估算    — Token 预算、资源需求
## 8. 开发路线        — Phase 1/2/3/4
```

#### TEST_CASES.md — 测试用例

每个模块独立章节，每个用例包含：
- **代号**: `TC-MODULE-NNN`
- **输入**: 触发条件
- **预期**: 期望行为
- **验证**: 怎么确认通过

覆盖的维度：
- 正常功能（happy path）
- 异常输入（空消息、超长消息）
- 边界条件（并发、超时、损坏数据）
- 集成场景（完整对话流程）
- 角色一致性（多轮对话不破角色）
- 沉默与主动触达

## 从参考项目提取的模式库

### EchoBot 模式
- **三层路由**：Decision → roleplay(轻量) / agent(完整) → 输出
- **规则层+LLM 层**决策：正则快速匹配，LLM 兜底
- **RoleCard 系统**：可切换的身份卡片
- **TTS 工厂模式**：多 provider 统一接口

### Hermes 模式
- **SOUL.md 身份层**：文件级身份，不受 git 影响
- **三层记忆**：热(对话)/温(SQLite 事实)/冷(归档)
- **技能系统**：skill 目录加载，SKILL.md 格式
- **多平台 gateway**：统一消息路由到不同渠道
- **存在感系统**（自定义扩展）：心跳、日记、闲逛

### OpenClaw 模式
- **技能生态**：社区共享，市场分发
- **agent 角色专业化**：不同场景加载不同角色

## Pitfalls

- **不要把身份写死在代码里**（如 DEFAULT_AGENT_IDENTITY）— 升级会被覆盖
- **不要用角色扮演 prompt 取代身份系统** — 一层皮，不持久
- **沉默是 feature 不是 bug** — 虚拟恋人需要主动选择不回应
- **模态切换的决策逻辑最难** — 比 LLM 调用本身更复杂
- **先跑通文字再上语音/图片** — 每一种模态都增加一倍的复杂度
- **记忆层不要一开始就全做** — 热层够用就行，温层 MVP 再上，冷层最后

---

> **案例参考**: `references/star-project-architecture.md` 包含一个完整的虚拟恋人智能体项目架构，涵盖上述 Phase 1-3 的全部模式的具体实现。在接手类似项目时先读这个文件，可以看到各模块如何协作、数据流如何组织。

---

## Phase 3: Build & Test（从设计到实现的通用模式）

从 Star 项目的完整实现中提取的、从"设计文档"到"可运行系统"的 build-time 模式。适用于任何三层（memory/skills/decision）架构的 AI agent 系统。

### 1. 记忆系统实现模式

三层记忆的推荐实现路径：

| 层 | 存储 | 容量 | 字段 | 实现要点 |
|----|------|------|------|----------|
| **Hot** | deque (内存) | 最近 10-20 轮 | role, content, timestamp | 无持久化，session 内有效 |
| **Warm** | SQLite | 500 条活跃 | id, content, category, importance, access_count, tags | LLM 提取值得记的事；按重要度衰减 |
| **Cold** | Markdown 文件 | 无限 | 日记格式 | 每晚自动写日记；warm→cold 归档通道 |

关键设计决策：
- **LLM 参与存储决策**：每次对话回复后，LLM 判断"这段话有什么值得记住的"。规则：日常寒暄不存，能帮助理解用户的才存。这比"全部存然后检索"更省 token 也更高价值密度。
- **衰减机制**：7 天未访问降权（-0.1），归零后归档到冷层。上限 500 条活跃记忆。
- **温层有 4 个分类**：user_pref（偏好）/ fact（事实）/ event（事件）/ emotion（情绪），方便检索时过滤。

### 2. 技能系统+ MCP 集成模式

```
技能匹配（用户输入 → SkillManager）
  ↓
渐进式加载（metadata → body → scripts，三级）
  ↓
MCP 数据预取（如果技能声明了 mcp_tools）
  ↓
LLM 根据 skill body + 实时数据 生成回复
```

关键设计：
- **Skills 包装 MCP**：MCP 工具不直接暴露给 LLM（会炸上下文），而是通过 SKILL.md 里声明 `mcp_tools`，系统在执行技能前自动预取数据注入 prompt。
- **三线渐进式披露**（L1 metadata → L2 body → L3 scripts）是 token 节省的关键。metadata 只有 ~50 tokens/技能，body 在匹配后才加载。
- **城市名提取**：对于天气等需要"动态参数"的技能，维护一个已知实体表（如 50+ 中国城市名），在参数提取时用"在输入中查找"模式，比交给 LLM 提取更可靠。

### 3. 决策引擎自由度光谱

四种路由各有明确的自由度参数，防止 LLM 在"需要精准"的场景过度发挥：

| 路由 | temperature | max_tokens | 用途 |
|------|------------|------------|------|
| SILENCE | 0 | 0 | 不调 LLM |
| REPLY | 0.3 | 100 | 简短回应，低随机 |
| AGENT | 0.1 | 2000 | 工具调用，精准优先 |
| CHAT | 0.8 | 600 | 人格驱动，高自由度 |

路由判定顺序：SILENCE 规则 → REPLY/CHAT/AGENT 规则 → Skills-aware 匹配 → LLM 兜底。注意：**AGENT 规则层也应当查 SkillManager 获取 matched_skill**，让下游知道具体匹配了哪个技能。

### 4. Config 校验模式

不要在启动时静默吞错误。对 config.yaml 做字段级校验（但不阻止启动）：

```python
VALID_LLM_FIELDS = {"provider", "base_url", "api_key", ...}
VALID_LOG_LEVELS = {"DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"}

def _validate_config(raw: dict):
    for k in raw.get("llm", {}):
        if k not in VALID_LLM_FIELDS:
            logger.warning(f"LLM 未知字段 '{k}'")
    if raw.get("log_level", "").upper() not in VALID_LOG_LEVELS:
        logger.warning(f"无效 log_level: {raw['log_level']}")
```

### 5. 优雅关闭模式

注册 SIGINT/SIGTERM 处理器，按逆序释放资源：

```python
_shutdown_event = asyncio.Event()

def _signal_handler(sig, frame):
    _shutdown_event.set()

async def main():
    signal.signal(signal.SIGINT, _signal_handler)
    signal.signal(signal.SIGTERM, _signal_handler)

    # 启动时初始化
    resources = [mcp_clients, memory, heartbeat, ...]

    # 等待 CLI 循环或关闭信号
    done, pending = await asyncio.wait(
        [cli_task, asyncio.create_task(_shutdown_event.wait())],
        return_when=asyncio.FIRST_COMPLETED,
    )
    for task in pending:
        task.cancel()

    # 逆序释放
    await heartbeat.stop()
    await mcp.disconnect_all()
    memory.close()
```

### 6. 存在感心跳模式

定时后台任务 + 空闲追踪，让 agent 在用户不主动说话时也有"活着"的感知：

```python
class PresenceHeartbeat:
    def __init__(self, interval_minutes=30):
        self._interval = interval_minutes * 60
        self._last_interaction = datetime.now()

    def notify_interaction(self):
        self._last_interaction = datetime.now()  # 用户说话时调用

    async def _beat(self):
        idle = (datetime.now() - self._last_interaction).total_seconds() / 60
        if idle > 120:  # 空闲超过 2 小时
            logger.info(f"长时间未对话（{idle:.0f} 分钟）")
```

### 7. Token 预算跟踪

基于 tiktoken 的上下文窗口用量估算 + 三段报警（正常/警告/危急）：

- `< 75%` — 正常
- `75-90%` — 建议压缩历史（保留最近 5-8 轮）
- `> 90%` — 必须压缩（只保留最近 3 轮）

实现要点：tiktoken 不是所有模型都有精确编码表，用最接近的模型编码，并保留降级估算（`count_tokens` 方法）。

### 8. Agent 项目测试模式

不要只写单元测试。对 agent 系统，**按依赖顺序写集成测试**，每个模块独立验证 + 全链路冒烟：

```
测试执行顺序：
配置 → 身份 → 情绪 → 决策引擎 → 输出路由 → 热层 → 温层 → 冷层
→ 记忆集成 → LLM 客户端 → 技能管理器 → MCP → CLI 通道 → 外部服务
```

每类测试覆盖：
- **正常路径**（happy path）
- **边界条件**（空输入、None、超限）
- **降级行为**（依赖缺失时不崩溃，返回提示）
- **资源泄露**（连接/文件是否正确关闭）

测试脚本独立于 pytest，用 `asyncio.run()` + assert 模式，方便在任意环境单文件跑。输出格式：`✅ 测试名` 或 `❌ 测试名 — 原因`，最终汇总通过率。
