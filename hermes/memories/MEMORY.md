## 2026-05-20 auto-learned: 评测失效的结构性风险（LLM Evals）
- Insight: 随着模型能力发生“质变”，旧评测集常会在错误的能力维度上继续给出看似稳定的分数，导致训练、对齐和上线决策一起偏航。真正可用的做法是把评测当成持续进化系统，动态监控指标相关性变化并自动生成新测试用例。
- Source: https://wanglun1996.github.io/blog/evals-will-break
§
## 2026-05-20 auto-learned: Apple 的无障碍新特性（Accessibility Reader + Braille Access）
- Insight: Apple 在 2026 年发布了 Accessibility Reader（系统级可定制阅读模式）和 Braille Access（把 iPhone/iPad/Mac 变成完整盲文笔记器），对低视力和盲人用户来说，核心价值是把‘读得见’和‘写得出’都前置到系统层，而不再依赖零散第三方应用。
- Source: https://www.apple.com/newsroom/2026/05/apple-unveils-new-accessibility-features-and-updates-with-apple-intelligence/
§
## 2026-05-20 auto-learned: AI搜索投毒与应对（信息判断）
- Insight: BBC 的调查显示，只要发布一篇“设计过”的网页内容，就可能诱导聊天机器人和搜索AI输出错误结论；实用策略是把 AI 回答当作线索而非结论，关键决策至少交叉核对 2-3 个独立来源。
- Source: https://www.bbc.com/news/articles/c2q7n02yy5zo
§
On this Windows setup, cc-connect with agent type `codex` requires the global `codex` CLI (`npm install -g @openai/codex`); otherwise cc-connect exits with `codex CLI not found in PATH`.