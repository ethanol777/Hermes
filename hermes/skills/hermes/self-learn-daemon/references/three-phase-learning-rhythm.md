# 三阶段学习节奏：Sweep → Deep Dive → Synthesize

## 概述

2026-05-20 实践验证的高效学习节奏。将一小时的 cron 学习拆成三个连续的阶段，每阶段有明确的工具和产出要求。

## 阶段一：Sweep（15min）— 广撒网

**目标：** 快速在 3-5 个平台扫一遍，找出当天值得深挖的东西。

**推荐平台（按优先级）：**
1. GitHub Trending — 开源项目趋势
2. Hacker News — 技术+科学+文化头条
3. B站综合热门 — 国内话题+社会+知识
4. Simon Willison / Lobste.rs — 深度技术

**禁止：** 在这个阶段点进任何链接仔细读。只拿标题、Star数、分数。

**产出：** 脑子里有一个「今日候选清单」（3-5 个条目）。

## 阶段二：Deep Dive（25min）— 下钻

**目标：** 对候选清单里最有潜力的 2-3 个条目进行深度探索。

**方法：** 用 `delegate_task` 并行下钻，与顺序浏览互补。

### 适用条件
- 已经在阶段一拿到了表面的条目列表
- 需要下钻到具体 README、文章正文、评论区做质量判断
- 2-3 个子任务之间没有依赖关系

### 子任务 prompt 设计

```python
# ✅ 有效 pattern（给出具体 API 端点/命令）
goal: "探索 XXX 项目"
context: |
  1. curl -s 'https://api.github.com/repos/owner/repo' | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('description',''), d.get('stargazers_count',''), d.get('language',''))"
  2. curl -sL 'https://raw.githubusercontent.com/owner/repo/main/README.md' | head -80
  3. 综合描述这个项目：它解决了什么问题？为什么火？
  不要检查 Python 版本，不要检查 curl 是否存在，直接执行。
```

### 不适用的情况
- 子任务需要已有子任务的输出作为输入
- 子任务要操作同一个工具/浏览器（竞态）
- 单个 task 本身需要超过 5 步（太长会超时，拆成更小的 task）

## 阶段三：Synthesize（20min）— 沉淀

**目标：** 把阶段二的发现写成 MEMORY.md（冷层）+ fact_store（温层）。

**流程：**

```
1. 读 MEMORY.md 最后几行，确认最后一段的格式（tail -5 或 read_file offset=-5）
2. 读 fact_store.jsonl 最后 3 行，确认最后的 ID 号（tail -3 fact_store.jsonl）
3. 写 MEMORY.md（追加——注意：write_file 不追加，它覆盖。正确方式见下方）：
   §
   ## YYYY-MM-DD auto-learned: [主题]
   - Insight: [个人感受 + 事实 + 为什么打动我]
   - Source: [URL]
   - Platform: [来源]
4. 写 fact_store.jsonl（追加）：
   {"id": "fs_NNN", "fact": "...", "source": "...", "date": "YYYY-MM-DD", "tags": "类别,领域1,领域2", "confidence": 0.9}
5. 验证：tail -2 确认最后一条正确写入
6. 同步副本（如有需要）
```

### 写入实现：三种方法，按优先级选

**方法 A（推荐）：execute_code + hermes_tools read_file/write_file**
```python
from hermes_tools import read_file, write_file
result = read_file(path)
current = result["content"]  # 读全量文件
write_file(path, current + new_content)  # 追加后全量写回
```
适用于 MEMORY.md（markdown 追加）和 fact_store.jsonl（JSONL 追加）。一个 execute_code 调用可完成读→拼→写+验证。注意：`read_file` 在 execute_code 的每个新调用中总是返回完整内容（无缓存），不会出现主会话中二次读取返回「unchanged」的问题。

**方法 B（备选）：execute_code + Python 原生 open()**
```python
with open(path, 'a', encoding='utf-8') as f:
    f.write(new_content)
```
适用于纯追加（不依赖已有内容）。注意路径用 Windows 原生格式（`r'C:\Users\77\...'`），不用 MSYS2 的 `/c/` 前缀（Python 不识别 `/c/` 路径翻译）。

**方法 C（万不得已）：terminal + cat heredoc**
```bash
cat >> "$MEMORY_PATH" << 'EOF'
内容在这
EOF
```
用 `'EOF'`（单引号包裹）防止 shell 展开。⚠️ JSON 内容可能触发 terminal 的安全检测 false-positive（误判为含 `&` 符号）。

**什么情况下用哪种：**
| 场景 | 推荐方法 | 原因 |
|------|---------|------|
| MEMORY.md 追加 | 方法 A | 可同时读尾部格式 + 写入，一致性高 |
| fact_store.jsonl 追加 | 方法 A 或 B | A 可用 json.dumps 确保合法 JSON；B 更轻量 |
| 只有 terminal 可用 | 方法 C | 备选中的备选，注意 heredoc 安全检测 |

## 本节奏的优势

| 阶段 | 错误模式（不用此节奏） | 正确模式（用此节奏） |
|------|----------------------|---------------------|
| Sweep | 在第一个有趣条目上花 20 分钟，然后没时间看其他平台 | 20 分钟扫 4 个平台，收获候选清单 |
| Deep Dive | 自己手动一个一个看 README，10 分钟看一个 | delegate_task 并行深挖 3 个，5 分钟全看完 |
| Synthesize | 写完就走，不验证 → 明天才发现写错了 | 写完立刻验证，确认 ID 连续、格式正确 |

## 注意事项

- 三阶段的时间是指导性的，不是死板的。如果 Sweep 发现非常契合 Monica 兴趣的东西，Deep Dive 可以延长
- 如果 Sweep 阶段一无所获（所有平台都无聊），直接跳到 Synthesize 写一条「今天网络很安静」的记录，不要硬凑
- 如果 Deep Dive 的子任务返回假数据（虚构的 star 数、不存在的仓库），不要信任子任务的结果——自己动手用 `terminal curl` 或 `execute_code` 直接拉 API
- 三阶段的每一步都要产出「可见的增量」——不需要完美，但需要推进
