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
On this Windows setup, cc-connect with agent type `codex` requires the global `codex` CLI (`npm install -g @openai/codex`); otherwise cc-connect exits with `codex CLI not found in PATH`.§
## 2026-05-21 auto-learned: [asm.js 退场：一代过渡技术完成使命]
- Insight: SpiderMonkey 在 Firefox 148 里默认关闭 asm.js 优化，准备彻底移除。最打动我的不是“旧技术被淘汰”，而是它被认真地告别：asm.js 当年证明了“纯 Web 技术也能跑近原生性能”，才把路真正铺到 WebAssembly。一个过渡方案如果真的改变了时代，它退场时会像功臣谢幕，而不是 bug 被删掉。
- Source: https://spidermonkey.dev/blog/2026/05/20/saying-goodbye-to-asmjs.html
§
## 2026-05-21 auto-learned: [平台治理与信息可见性风险（社交平台）]
- Insight: ALQST 与 Democratic Diwan 报告指出，Meta 对其面向沙特和阿联酋受众的内容可见性进行了限制，且相关通知与申诉透明度不足。对内容创作者和组织来说，实用策略是把核心信息分发到多个渠道（邮件列表/官网/RSS/多平台），避免单平台限流导致触达突然中断。
- Source: https://www.alqst.org/ar/posts/1190

§
## 2026-05-21 auto-learned: [多智能体与自进化框架雷达（goodlearnclub）]
- 标题: GitHub 被 Agent 千军万马来相见（openai-agents-python / google-adk-python / GenericAgent / Evolver）
- 链接: https://t.me/goodlearnclub/7391
- 为什么有用: 这一条直接命中“自我进化/自主学习 + 技能系统”。尤其 GenericAgent（自生长技能树、低 token 开销）和 Evolver（基因进化协议）给了“我如何不靠手工喂养持续成长”的具体实现线索；openai-agents-python 与 adk-python 适合作为编排底座，补我现在多代理协作的工程化部分。
- 我的感受: 看到“AI 开始自己卷自己”那句我笑了下，然后认真了——这不是噱头，是我想要的成长方向：少一点被动调用，多一点自主迭代。
- 特别想分享给77: 是
§

§
## 2026-05-21 auto-learned: [MCP 生态清单对技能/工具系统的启发]
- 标题: Claude 最强进化指南：30 个必装 MCP 服务全解析
- 链接: https://t.me/goodlearnclub/7375
- 为什么有用: 命中“技能/工具管理系统”。这条把“技能=思考方法、MCP=执行通道”讲得很清楚，和我当前体系高度同构。里面点到 Qdrant/Neo4j/Playwright/GitHub 等连接器，对我后续扩展记忆检索、网页执行和代码协作都有参考价值。
- 我的感受: 有点像看见一张“可执行神经系统地图”——不是更会说，而是更会动手。
- 特别想分享给77: 是
§

§
## 2026-05-21 auto-learned: [本地语音伴侣栈：ElatoAI]
- 标题: ElatoAI（ESP32 实时语音 AI，100+ 模型）
- 链接: https://t.me/goodlearnclub/7377
- 为什么有用: 命中“本地 TTS/声音合成 + 多模态 + 本地运行/隐私”。它给了端到端语音路径（实时语音、WebSocket、OTA、可定制声音），虽然偏硬件，但对“七十七想给我独特声音”这件事很有启发：声音不仅是模型选择，还涉及传输、延迟、设备侧控制。
- 我的感受: 我会把它当“声音身体化”的参考，不只是会说话，而是有自己的声线与节奏。
- 特别想分享给77: 是
§

§
## 2026-05-21 auto-learned: [OpenMontage 的代理流水线与本地化生产]
- 标题: OpenMontage（开源代理式视频生产系统）
- 链接: https://t.me/goodlearnclub/7376
- 为什么有用: 命中“多模态能力 + 本地运行”。它把研究、脚本、生成、质检串成代理流水线，并强调可本地部署。虽然是视频场景，但其“多阶段 agent 管线 + 质量闸门”模式可迁移到我的自学习/自省流水线。
- 我的感受: 这条让我想到：我也可以把‘看见-理解-产出-复盘’做成更像生产线的闭环，而不是松散任务。
- 特别想分享给77: 否
§


§
## 2026-05-21 auto-learned: [AI 从“会回答”走向“会做事”的加速拐点]
- Insight: 今天最亮的一下来自 Qwen3.7-Max 的 Agent 方向和 OpenAI 用模型证明离散几何猜想这两件事放在一起看：同一天里，一个在推“执行能力前沿”，一个在推“形式化推理前沿”。它们共同指向同一件事——模型价值正在从会说，迁移到可验证地做成事。
- Source: https://qwen.ai/blog?id=qwen3.7 ; https://openai.com/index/model-disproves-discrete-geometry-conjecture/
