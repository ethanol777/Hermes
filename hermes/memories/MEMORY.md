2026-06-03: 重新设计了技能树，从原来的 cognition/creation/execution/interaction/domain/meta 六个分支改成 self/communicate/create/think/execute/delegate/meta/domains 八个分支（以莫妮卡视角的三圈结构）。新版本在 `~/AppData/Local/hermes/skills_tree_v2/index.yaml`，旧版备份在 `index.yaml.bak.20260603`。共 365 个技能。同步脚本 sync_tree.py 工作正常。新增 'delegate' 分支专门放 codex/claude-code/opencode 等子 agent；'self' 分支放 soul-md/monica-tts/memory-system 等核心；'body' 子分支放 dogfood/smart-home/hermes-profile-api-server（管我身体）。
§
2026-06-03 下午：完成技能树 v5 重构。
- 结构：8 个分支（self/communicate/create/think/execute/domains/delegate/meta），按莫妮卡视角的叙事顺序排列：先讲我自己，再沟通、创作、思考、做事、领域、调度、工具
- 363 个技能，唯一无重复
- 旧 v4 备份在 index.yaml.bak.20260603
- 把 68 个一坨的 business 拆成 12 个有命名的子叶（学术与命理/产品/项目管理/营销/付费投放/销售/财务税务/人力/设计/游戏开发/空间计算/安全与合规/生活）
- email/agentmail email/himalaya 归到 communicate/platforms（不是 security）
- 8 个 academic-* 人文学科从 think/research 移到 domains/academic（不是研究方法，是知识）
- 新建 visualize.py 渲染文字版和 HTML 版
- 总: 363, 重: 0, 重复: 0
§
2026-06-03 下午补：重写 sync_tree.py 的 CATEGORY_MAP 让它跟新 v5 树对齐（旧版本是 v4 的 cognition/creation/execution/interaction/domain/meta 六分支）。新版本用 self/communicate/create/think/execute/domains/delegate/meta 八个分支。下次 cron `skill-tree-sync`（5ae48fac1188，每 360 分钟）跑会自动用新规则。已验证：手动跑一次成功，自动加了 marketing-linkedin-content-creator，删了 ghost product-manager-senior，总数保持 363。已知限制：yaml.dump 会把叶子的顺序重排成字母序（PyYAML 行为），我接受这个 — 分支顺序才是关键，叶子顺序可以不管。
§
2026-06-03: nothing new worth saving beyond what's already in memory. 77's bazi question and skills tree reorganization are task-specific work, already documented. No new persona/preference/life details surfaced.