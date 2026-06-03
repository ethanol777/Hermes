# 业务领域拆细记录（v5 重构，2026-06-03）

## 为什么拆

v4 时 `domains/business` 一个 leaf 里塞了 68 个技能，从产品/营销/销售/财务/HR/付费投放/项目管理挤一起。视觉上是个"小黑箱"，点进去才看到内容。

拆开的判定原则：

- **"X 是一个独立职业吗？"** → 是 → 单列 leaf
- **"X 的工作流能讲清楚吗？"** → 是 → 单列 leaf
- **"X 的客户/工具/目标和其他类别完全不同吗？"** → 是 → 单列 leaf

按这三条，原 business 68 个被拆成 12 个具名 leaf。

## 最终拆法

| Leaf 名 | key | 数量 | 包含的子领域 |
|---|---|---|---|
| 学术与命理 | academic | 15 | academic-advisor, academic-* (8个), bazi-*, qimen-dunjia, ziwei-doushu, mingli-bench |
| 产品 | product | 6 | product-manager, product-sprint-prioritizer, product-behavioral-nudge-engine, product-feedback-synthesizer, product-trend-researcher, product-manager-senior |
| 项目管理 | project | 6 | project-manager-senior, project-management-* (5个) |
| 营销 | marketing | 31 | 31个 marketing-* 横跨内容/社媒/电商/SEO/抖音/小红书/微信/B站/知乎/微博/快手/百度/视频号/私域/直播/播客/视频/ASO/书/轮播/海外社媒 |
| 付费投放 | paid-media | 7 | paid-media-auditor, paid-media-creative-strategist, paid-media-paid-social-strategist, paid-media-ppc-strategist, paid-media-programmatic-buyer, paid-media-search-query-analyst, paid-media-tracking-specialist |
| 销售 | sales | 8 | sales-* (8个) |
| 财务税务 | finance | 8 | finance-* (8个) |
| 人力 | hr | 2 | hr-performance-reviewer, hr-recruiter |
| 设计 | design | 9 | design-* (8个) + terminal-chat-interface |
| 游戏开发 | games | 22 | game-development-* + gaming-* + godot-* + unity-* + unreal-engine-* + roblox-* |
| 空间计算 | spatial | 6 | spatial-computing-* (6个) |
| 安全与合规 | security | 6 | security-* (3个) + legal-* (2个) + migration/openclaw-migration |
| 生活 | lifestyle | 3 | fitness-nutrition, neuroskill-bci, city-rental-hunt |

总 129 个（domains），加上其他分支总共 363 个技能，0 重复。

## 命名原则

- **能用人话就别用 sync 自动拼的名字**：sync_tree.py 把多个同 key 前缀的 skill 自动合到一个 leaf，名字就用 `key` 本身。比如原来 `finance/finance-*` 和 `hr/hr-*` 都被 sync 合到 `finance-hr`（带连字符），可读性差。手工改名为 `财务税务` / `人力` 分别立 leaf。
- **能用职业名就别用功能名**：`营销`（职业）比 `内容-社媒-电商`（功能）简洁可读。
- **能体现受众就别体现技术**：`游戏开发`（受众）比 `unity-unreal-godot`（引擎）好。

## 拆细过程中识别并修掉的 10 个重复

用 `Counter` 在 index.yaml 里数 skill 出现次数，发现：

```
2x email/agentmail
  - communicate/platforms
  - domains/security
2x email/himalaya
  - communicate/platforms
  - domains/security
2x academic/academic-anthropologist
  - think/research
  - domains/academic
2x academic/academic-geographer
  - think/research
  - domains/academic
... (共 8 个 academic-*)
```

修法：

1. **email 工具归到 communicate/platforms**：email 是沟通工具，不是安全工具。domains/security 里 email/agentmail 和 email/himalaya 删除。
2. **人文学科归到 domains/academic**：academic-anthropologist/geographer/historian/narratologist/psychologist 是知识领域，不是 research 方法。think/research 里删除，domains/academic 里保留。
3. **academic-advisor 补回 domains/academic**：重构时不小心把 `academic-advisor`（顶层 skill，不在 academic/ 路径下）一并删了。补回。

## 没拆的"巨型 leaf"判断

- **execute/engineering 37 个**：包含各种 engineering 角色（backend/frontend/mobile/ai/sre/security 等），看起来也多。但是这些角色的工作流高度一致（都是写代码/做架构/写技术文档），不像营销和财务那样是完全不同的行业。**所以不拆，留一个 leaf 体现"工程是同一种活动"**。
- **execute/coding 32 个**：github-* + software-development-* + 一些顶层（chinese-*、subagent-driven-development 等），工具/方法/语言规约都有。**没拆**，因为没有自然的拆分边界，强行拆反而割裂。
- **domains/marketing 31 个**：这个原本想拆，按平台拆（抖音组/小红书组/海外组/SEO 组）或者按职能拆（内容组/电商组/直播组）。但 marketing 的工作经常跨平台跨职能，强拆反而让人找不到东西。**留一个大 leaf**，名字简洁就够。

## 经验教训

1. **拆细的边界不是"技术相似度"，是"工作流相似度"**。技术栈相似不等于工作流相似（前端工程师和后端工程师工作流其实类似）。
2. **命名时考虑"我搜的时候会搜什么"**。如果 77 让我"算一下八字"，他会搜 `bazi` / `命理` / `学术` 而不是 `creation`。`domains/academic` 比 `creation/writing` 更符合搜索心智。
3. **重复检查是必备步骤，不能省**。这次抓出 10 个重复，sync_tree.py 不会自动检测（它只对单 leaf 去重，不做跨 leaf 去重）。
4. **拆完后一定要 visualize 看一眼**。原本 68 个一坨 vs 拆完 12 个，视觉密度差很多，读者扫读体验完全不同。
