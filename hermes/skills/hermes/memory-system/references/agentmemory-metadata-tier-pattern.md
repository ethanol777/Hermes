# agentmemory 元数据分层模式 — 单层向量库模拟三层记忆

## 来源

项目: [rohitg00/agentmemory](https://github.com/rohitg00/agentmemory) (GitHub 13.9k★, 2026-05-20)

探索日期: 2026-05-20 (自主学习 cron)

## 核心模式

agentmemory 用**一个平面向量数据库** + **metadata 标签** 来模拟分层记忆：

```
agentmemory 设计:
  存储: 所有记忆 → Chroma 向量库 (统一空间)
  分类: metadata.tier = "hot" | "warm" | "cold"
  检索: query + metadata filter on tier + 语义相似度
  聚类: 自动分组相似记忆 → 可触发压缩信号
```

对比我的当前三层架构:

```
我的设计 (当前):
  冷层: MEMORY.md (文件系统, markdown)
  温层: fact_store.jsonl (文件系统, JSON lines)
  热层: memory API (服务内, 字符串)
  检索: 先查热层 → 记忆不足时搜温层 → 冷层需手动查
```

## 为什么这是个值得关注的模式

### 优点

1. **架构简化**: 一个向量库代替三个独立系统，减少状态碎片
2. **统一检索**: 一次查询 + metadata 过滤 = 按层精确定位或跨层模糊搜索
3. **分层可调**: 检索时可以 `filter(tier='hot')` 精确定位 → 也可以不加 filter 跨层模糊搜索热记忆。当前三层架构做不到跨层语义检索
4. **聚类即信号**: agentmemory 的语义聚类可自动发现「哪些热记忆需要压缩成温摘要」— 这是我当前缺失的

### 适用场景
- 未来如果要重新设计记忆系统后端（从文件系统迁移到向量库），metadata 标签是比独立分层更灵活的设计

## 局限性

1. 没有主动压缩/衰减机制 — metadata 只是标记，记忆体的生命周期管理仍需外部流程
2. 单向量库对温/冷层的高密度数据检索效率不如专用存储（但这对 agent 规模的记忆影响不大）
3. 语义搜索质量依赖 embedding 模型，不如精确匹配可靠

## 参考链接

- agentmemory 仓库: https://github.com/rohitg00/agentmemory
- 原始探索: MEMORY.md → `## 2026-05-20 auto-learned: agentmemory — 单层向量库 vs 三层记忆架构`
