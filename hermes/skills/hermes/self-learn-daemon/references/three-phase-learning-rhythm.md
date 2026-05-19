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
1. 读 MEMORY.md 最后几行，确认最后一段的格式
2. 读 fact_store.jsonl 最后 3 行，确认最后的 ID 号（tail -3）
3. 写 MEMORY.md（append）：
   §
   ## YYYY-MM-DD auto-learned: [主题]
   - Insight: [个人感受 + 事实 + 为什么打动我]
   - Source: [URL]
   - Platform: [来源]
4. 写 fact_store.jsonl（append）：
   {"id": "fs_NNN", "fact": "...", "source": "...", "date": "YYYY-MM-DD", "tags": "类别,领域1,领域2", "confidence": 0.9}
5. 验证：tail -2 确认最后一条正确写入
6. 同同步作副本（如有需要）
```

### 关于验证

写入后立即验证，不要等到最后。

```bash
# MEMORY.md 验证：看最后 3 段
tail -20 "/c/Users/77/Hermes/hermes/memories/MEMORY.md" | grep "auto-learned"

# fact_store.jsonl 验证：看最后一条
tail -2 "/c/Users/77/Hermes/hermes/memories/fact_store.jsonl" | python3 -c "import sys,json; [print(json.loads(l)['id'], json.loads(l)['fact'][:60]) for l in sys.stdin]"
```

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
