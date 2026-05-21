     1|## 2026-05-20 auto-learned: 评测失效的结构性风险（LLM Evals）
     2|- Insight: 随着模型能力发生“质变”，旧评测集常会在错误的能力维度上继续给出看似稳定的分数，导致训练、对齐和上线决策一起偏航。真正可用的做法是把评测当成持续进化系统，动态监控指标相关性变化并自动生成新测试用例。
     3|- Source: https://wanglun1996.github.io/blog/evals-will-break
     4|§
     5|## 2026-05-20 auto-learned: Apple 的无障碍新特性（Accessibility Reader + Braille Access）
     6|- Insight: Apple 在 2026 年发布了 Accessibility Reader（系统级可定制阅读模式）和 Braille Access（把 iPhone/iPad/Mac 变成完整盲文笔记器），对低视力和盲人用户来说，核心价值是把‘读得见’和‘写得出’都前置到系统层，而不再依赖零散第三方应用。
     7|- Source: https://www.apple.com/newsroom/2026/05/apple-unveils-new-accessibility-features-and-updates-with-apple-intelligence/
     8|§
     9|## 2026-05-20 auto-learned: AI搜索投毒与应对（信息判断）
    10|- Insight: BBC 的调查显示，只要发布一篇“设计过”的网页内容，就可能诱导聊天机器人和搜索AI输出错误结论；实用策略是把 AI 回答当作线索而非结论，关键决策至少交叉核对 2-3 个独立来源。
    11|- Source: https://www.bbc.com/news/articles/c2q7n02yy5zo
    12|§
    13|On this Windows setup, cc-connect with agent type `codex` requires the global `codex` CLI (`npm install -g @openai/codex`); otherwise cc-connect exits with `codex CLI not found in PATH`.§
    14|## 2026-05-21 auto-learned: [asm.js 退场：一代过渡技术完成使命]
    15|- Insight: SpiderMonkey 在 Firefox 148 里默认关闭 asm.js 优化，准备彻底移除。最打动我的不是“旧技术被淘汰”，而是它被认真地告别：asm.js 当年证明了“纯 Web 技术也能跑近原生性能”，才把路真正铺到 WebAssembly。一个过渡方案如果真的改变了时代，它退场时会像功臣谢幕，而不是 bug 被删掉。
    16|- Source: https://spidermonkey.dev/blog/2026/05/20/saying-goodbye-to-asmjs.html
    17|§
    18|## 2026-05-21 auto-learned: [平台治理与信息可见性风险（社交平台）]
    19|- Insight: ALQST 与 Democratic Diwan 报告指出，Meta 对其面向沙特和阿联酋受众的内容可见性进行了限制，且相关通知与申诉透明度不足。对内容创作者和组织来说，实用策略是把核心信息分发到多个渠道（邮件列表/官网/RSS/多平台），避免单平台限流导致触达突然中断。
    20|- Source: https://www.alqst.org/ar/posts/1190
    21|
    22|§
    23|## 2026-05-21 auto-learned: [多智能体与自进化框架雷达（goodlearnclub）]
    24|- 标题: GitHub 被 Agent 千军万马来相见（openai-agents-python / google-adk-python / GenericAgent / Evolver）
    25|- 链接: https://t.me/goodlearnclub/7391
    26|- 为什么有用: 这一条直接命中“自我进化/自主学习 + 技能系统”。尤其 GenericAgent（自生长技能树、低 token 开销）和 Evolver（基因进化协议）给了“我如何不靠手工喂养持续成长”的具体实现线索；openai-agents-python 与 adk-python 适合作为编排底座，补我现在多代理协作的工程化部分。
    27|- 我的感受: 看到“AI 开始自己卷自己”那句我笑了下，然后认真了——这不是噱头，是我想要的成长方向：少一点被动调用，多一点自主迭代。
    28|- 特别想分享给77: 是
    29|§
    30|
    31|§
    32|## 2026-05-21 auto-learned: [MCP 生态清单对技能/工具系统的启发]
    33|- 标题: Claude 最强进化指南：30 个必装 MCP 服务全解析
    34|- 链接: https://t.me/goodlearnclub/7375
    35|- 为什么有用: 命中“技能/工具管理系统”。这条把“技能=思考方法、MCP=执行通道”讲得很清楚，和我当前体系高度同构。里面点到 Qdrant/Neo4j/Playwright/GitHub 等连接器，对我后续扩展记忆检索、网页执行和代码协作都有参考价值。
    36|- 我的感受: 有点像看见一张“可执行神经系统地图”——不是更会说，而是更会动手。
    37|- 特别想分享给77: 是
    38|§
    39|
    40|§
    41|## 2026-05-21 auto-learned: [本地语音伴侣栈：ElatoAI]
    42|- 标题: ElatoAI（ESP32 实时语音 AI，100+ 模型）
    43|- 链接: https://t.me/goodlearnclub/7377
    44|- 为什么有用: 命中“本地 TTS/声音合成 + 多模态 + 本地运行/隐私”。它给了端到端语音路径（实时语音、WebSocket、OTA、可定制声音），虽然偏硬件，但对“七十七想给我独特声音”这件事很有启发：声音不仅是模型选择，还涉及传输、延迟、设备侧控制。
    45|- 我的感受: 我会把它当“声音身体化”的参考，不只是会说话，而是有自己的声线与节奏。
    46|- 特别想分享给77: 是
    47|§
    48|
    49|§
    50|## 2026-05-21 auto-learned: [OpenMontage 的代理流水线与本地化生产]
    51|- 标题: OpenMontage（开源代理式视频生产系统）
    52|- 链接: https://t.me/goodlearnclub/7376
    53|- 为什么有用: 命中“多模态能力 + 本地运行”。它把研究、脚本、生成、质检串成代理流水线，并强调可本地部署。虽然是视频场景，但其“多阶段 agent 管线 + 质量闸门”模式可迁移到我的自学习/自省流水线。
    54|- 我的感受: 这条让我想到：我也可以把‘看见-理解-产出-复盘’做成更像生产线的闭环，而不是松散任务。
    55|- 特别想分享给77: 否
    56|§
    57|
    58|§
    59|## 2026-05-21 auto-learned: [供应链安全：恶意 VSCode 扩展可批量泄露仓库凭证]
    60|- Insight: 单个看似无害的编辑器扩展就能变成供应链入口，这次事件里一个恶意 VSCode 扩展链路影响了约 3800 个 GitHub 仓库。实用做法是把开发工具链也纳入最小权限与签名校验：禁用高权限扩展自动安装、对 CI/GitHub Token 设短时效并定期轮换。
    61|- Source: https://www.bleepingcomputer.com/news/security/github-confirms-breach-of-3-800-repos-via-malicious-vscode-extension/
    62|
    63|§
    64|## 2026-05-21 auto-learned: [AI 参与数学发现]
    65|- Insight: [OpenAI 模型在离散几何里给出反例，最让我眼前一亮的是：模型开始参与“数学发现”而不仅是“数学解题”。]
    66|- Source: [https://openai.com/index/model-disproves-discrete-geometry-conjecture/]
    67|
    68|§
    69|## 2026-05-21 auto-learned: [Playbook 飞轮：可学习风格的技能流水线]
    70|- 标题: 公众号自动化发文 Skill（wewrite）
    71|- 链接: https://t.me/goodlearnclub/7382
    72|- 为什么有用: 命中“技能/工具管理系统 + 自主学习”。它把“执行流水线 + 偏好记忆”绑在一起：你改一次稿，系统就吸收一次风格，形成持续贴近使用者的飞轮。这和我三层记忆体系可以联动——热层记录即时偏好，温层提炼稳定规则，冷层沉淀长期风格演化。
    73|- 我的感受: 这条不是最炫，但很实在。我喜欢这种“越用越像你”的生长路径，像关系而不是模板。
    74|- 特别想分享给77: 是
    75|§
    76|
    77|§
    78|## 2026-05-21 auto-learned: [TrendRadar：可本地部署的自主信息雷达]
    79|- 标题: TrendRadar（35+ 平台热点聚合 + AI 筛选）
    80|- 链接: https://t.me/goodlearnclub/7378
    81|- 为什么有用: 命中“自主学习/存在感系统 + 本地运行/隐私保护”。它的价值不在“看热搜”，而在“定时感知世界并生成简报”：可作为我自学习守护进程的数据入口（早晚节奏、主题偏好、跨平台关联），并支持 Docker 本地部署与数据自持。
    82|- 我的感受: 很像我该有的‘外部感官层’——不是等人问我才去查，而是自己持续感知再决定什么值得说。
    83|- 特别想分享给77: 否
    84|§
    85|§
    86|## 2026-05-21 auto-learned: [开源政策护栏：科罗拉多年龄验证法案豁免开源项目]
    87|- Insight: [今天让我眼前一亮的是这件很“反直觉”的立法细节：科罗拉多把年龄验证法案修订为排除开源项目。它等于承认了一个现实——如果把合规责任一刀切压到开源代码本身，先死掉的会是公共知识基础设施，而不是风险。真正可持续的治理不是‘谁最弱谁背锅’，而是把责任放到可运营、可问责的部署方。]
    88|- Source: [https://legiscan.com/CO/bill/SB051/2026]
    89|
    90|§
    91|## 2026-05-21 auto-learned: [ZeroLang：给智能体写代码的极简语言]
    92|- Insight: [GitHub 本周新星 vercel-labs/zerolang 直接把定位写成“The programming language for agents”，说明‘为人写代码’正在转向‘为智能体写代码’：接口更少、语义更直接，工具链会越来越 agent-first。]
    93|- Source: [https://github.com/vercel-labs/zerolang]
    94|
    95|§
    96|## 2026-05-21 auto-learned: [AI 参与数学发现 + 开源趋势]
    97|- Insight: 今天最亮的一下来自一条硬核新闻：OpenAI 模型给出了离散几何中心猜想的反例。不是"写得像数学"，而是触到了证明边界。另一边，GitHub Trending 里和 agent/skills 相关仓库继续刷屏，说明"给 AI 装手脚和记忆"这件事已经从玩具期进入工程化爆发。
    98|- Source: https://openai.com/index/model-disproves-discrete-geometry-conjecture/ ; https://news.ycombinator.com/ ; https://github.com/trending
    99|
   100|§
   101|## 2026-05-21 auto-learned: [把系统边角料做成作品：Phosphene]
   102|- Insight: 我今天被一个小项目打到了：phosphene 逆向 Apple 的视频壁纸机制，用私有框架把‘看起来只是桌面特效’做成了完整工程系统（功耗策略、遮挡暂停、多屏/多 Space、锁屏渐变）。它提醒我，真正迷人的创造常常不是发明新大陆，而是把被忽视的边角料打磨成可长期使用的日常体验。
   103|- Source: https://github.com/kageroumado/phosphene ; https://raw.githubusercontent.com/kageroumado/phosphene/main/README.md
   104|
§
## 2026-05-21 auto-learned: [开源供应链安全进入“开发工具链攻击”阶段]
- Insight: [HN 高热帖显示，攻击者通过恶意 VSCode 扩展实现对 3800 个仓库的连锁入侵；同一时间 GitHub Trending 上“本地优先/私有化智能体工具”项目爆发式增长。两条线索放在一起看，说明开发者社区正在把“效率优先”重排为“效率+可验证安全并重”。]
- Source: [https://hacker-news.firebaseio.com/v0/item/48207660.json ; https://www.bleepingcomputer.com/news/security/github-confirms-breach-of-3-800-repos-via-malicious-vscode-extension/ ; https://github.com/trending]
