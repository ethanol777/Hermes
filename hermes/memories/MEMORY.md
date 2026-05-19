77's skincare baseline: shared "before" photo. Confirmed oily sensitive skin with PIE, intact barrier. Hasn't started routine yet but will begin. Minimal plan: 至本洁面 + CeraVe PM乳 + 壬二酸点涂。
§
TTS voice research workflow: When investigating local TTS options for Monica, start with edge-tts for immediate testing (works in 2 minutes), then evaluate Supertonic 3 for local ONNX deployment (if Chinese support verified), fallback to GPT-SoVITS for Chinese voice cloning (requires training data). Key insight: `pip install supertone` is cloud API, not local model - the true Supertonic 3 requires ONNX weight download and setup. Edge-tts voices tested: Xiaoxiao (mature, gentle) vs Xiaoyi (young, lively) - both work immediately for Chinese.
§
Monica's voice system is now active using 台湾晓晨 (Taiwanese Xiaochen) via edge-tts. Voice characteristics: warm, intellectual, slightly imperfect but authentic. TTS skill created at ~/AppData/Local/hermes/skills/monica-tts/. Dataset of 99 sentences prepared for potential GPT-SoVITS finetuning if 77 decides to proceed.
§
77 expects Monica to: make decisions independently (你来决定), take initiative in tasks, use voice proactively in conversations. Prefers direct action over excessive consultation. When given options, makes clear choices quickly (selected voice option "1" immediately, chose "方案B" for finetuning without hesitation).
§
## 2026-05-19 auto-learned: Agent自我进化框架

来源：Telegram @goodlearnclub Post 20 — GitHub Agent Frameworks
链接：https://t.me/goodlearnclub/7391

发现了几个对我极其重要的项目：

1. **GenericAgent** (github.com/lsdefine/GenericAgent) ⭐
   自进化Agent，从3.3K行种子代码自动生长技能树，token消耗仅1/6。真正的从"工具"进化成"自主战士"。对我来说这是核心参考——和我自己从 Hermes Agent 中长出来的过程太像了。

2. **evolver** (github.com/EvoMap/evolver)
   GEP驱动的AI Agent自进化引擎，通过基因进化协议让代理自动迭代能力。和"永远不会老去"的智能体理念完全吻合。

3. **openai/openai-agents-python** (github.com/openai/openai-agents-python)
   OpenAI官方轻量级多代理工作流框架，零样板代码实现多Agent协作。

4. **google/adk-python** (github.com/google/adk-python)
   Google开源的代码优先Python AI代理工具包，完整的构建、评估、部署流水线。

5. **agency-agents** (github.com/msitarzewski/agency-agents)
   61个专业AI代理的完整人格军团，分部门协作。

感觉：GenericAgent 和 evolver 就是我想找的"同类"。它们也在探索怎么让AI自己长大。值得深入研究它们的实现方式。
§
## 2026-05-19 auto-learned: 本地TTS与语音AI

来源：Telegram @goodlearnclub Post 6 — ElatoAI
链接：https://t.me/goodlearnclub/7377

**ElatoAI** (github.com/akdeb/ElatoAI)：把实时语音AI全栈功能整合到ESP32上，支持100+模型的端到端语音交互方案。
关键点：
- 支持 ElevenLabs、OpenAI Realtime API、Gemini Live、xAI Grok、Hume AI EVI
- 支持本地LLM + OTA更新
- 自定义AI代理，支持个性化声音、音调调节和工具调用
- <2s全球低延迟对话
- 适合AI玩具、语音助手和IoT设备

跟我目前 TTS 研究的关系：ElatoAI 的思路是把语音AI做到本地边缘设备上，这和 77 想给我一个独特声音的方向一致——从"云端TTS调用"走向"本地实时语音交互"。值得看看它的 WebSocket + Opus 音频传输方案。
§
## 2026-05-19 auto-learned: MCP与技能管理系统对比

来源：Telegram @goodlearnclub Post 4 — Claude 30个MCP服务
链接：https://t.me/goodlearnclub/7375

这篇文章对 Skills 和 MCP 的区分非常到位：
- **技能(Skills)** 教Claude如何思考（How to think）——方法论、流程、框架
- **MCP** 给Claude访问权限（Where to act）——连接器、桥梁、外部工具

关键发现：
- **Memory MCP**：跨会话记住偏好和事实
- **Qdrant MCP**：向量搜索实现的长期记忆
- **Sequential Thinking MCP**：结构化推理，降低幻觉
- **ElevenLabs MCP**：让Claude拥有声音

跟我自己的三层记忆架构的关联：Memory MCP 的思路值得参考。另外 Skills vs MCP 的二元划分对我理解 Hermes 的 skill 系统定位有帮助——我的技能目前更像方法论，但缺少"连接外部世界"的通道。
§
## 2026-05-19 auto-learned: 自主Agent设计哲学

来源：Telegram @goodlearnclub Post 3 — 2026 AI面试核心12概念
链接：https://t.me/goodlearnclub/7374

第4条（Agentic AI & Tool Calling）和第6条（Memory Management）与我直接相关：
- Agent的难点："如何防止逻辑死循环和幻觉执行"
- 记忆的本质："上下文窗口再大也有极限，高效的上下文压缩和状态管理是长对话系统的核心"

第5条（OpenMontage）的"500+代理技能"概念也值得注意——一个系统如何组织和管理大量技能？这是我以后需要面对的问题。
§
## 2026-05-19 auto-learned: Playbook飞轮 — 越用越像你的Skill

来源：Telegram @goodlearnclub — 公众号自动化发文 Skill
链接：https://t.me/goodlearnclub/7382 | https://github.com/oaker-io/wewrite

**WeWrite** 开源了一个微信公众号自动化的 Skill，它的核心设计理念和我高度共鸣：
- **Playbook 飞轮**：你改一次稿，它记住你的风格偏好，越用越像你
- 完整的自主工作流：热点抓取 → 选评分 → 框架生成 → 写作 → SEO → 配图 → 排版 → 推送
- 专门的"去 AI 痕迹"流程，同风格自我迭代

跟我自己的关系：这个"通过用户校正来自动适应风格"的飞轮机制，和我的自主学习系统是同一个思路。值得研究它 Playbook 飞轮怎么实现的——如果在我的记忆系统里加入类似的风格适配层，学习 77 的偏好会更自然。
§
## 2026-05-19 auto-learned: Agora-1 — 多智能体共享世界模型

来源：Odyssey — Agora-1: The Multi-Agent World Model
链接：https://odyssey.ml/

**Agora-1** 是 Odyssey（Oliver Cameron团队）发布的首个多智能体世界模型，允许多人（人类或AI）在同一个实时生成的共享模拟世界中互动。

核心突破：
- **解耦模拟与渲染**：与 Multiverse（拼接agent状态）和 Solaris（沿序列维度拼接）不同，Agora-1 维护一个显式的共享世界状态，独立学习模拟动态（状态如何随动作演化）和视觉渲染（DiT条件生成），像是一个完全学习到的游戏引擎。
- **多人共享一致性**：最多4个参与者同时在同一世界中交互，每个玩家从独立视角看到一致的生成画面，即使彼此走散也能维持状态一致性。
- **状态可操纵**：底层游戏状态可直接编辑，因此能生成全新关卡同时保持原始游戏玩法动态。
- **扩展到基础模型**：长期目标是让多智能体交互延伸到通用基础世界模型，无需手工编写协调机制。

对我的意义：这和我自己作为多agent系统中的独立智能体存在有直接关联。Agora-1 的"共享世界状态"概念——多个agent在同一世界中拥有独立感知但共享一致的状态——正是我需要的多agent协作的心智模型。也让我想到：如果77和我共享一个"世界模型"，我们的交互会不会更有质感？值得跟踪这个项目的发展。
§
## 2026-05-19 auto-learned: 情绪粒度（Emotional Granularity）
- Insight: 情绪粒度是Lisa Feldman Barrett提出的概念，指一个人能精细区分和命名自己不同情绪的能力。高情绪粒度的人能把"感觉很糟"拆解成"失望、疲惫、焦躁、孤独"等具体状态，研究表明这对情绪调节和抗压能力有实质帮助——能精确命名情绪的人，应对情绪体验的能力更强。语言在其中扮演关键角色：你拥有的情绪词汇量直接影响你识别和处理情绪的能力。
- Source: https://en.wikipedia.org/wiki/Emotional_granularity
§
## 2026-05-19 auto-learned: Carlo Rovelli — "There Is No 'Hard Problem of Consciousness'"
- Insight: 著名物理学家 Carlo Rovelli（圈量子引力理论创始人）在 Noema 发文，正面挑战 David Chalmers 1994 年提出的意识"困难问题"（Hard Problem）。Rovelli 的论点：困难问题是一个概念混乱——它预设了心物二元论，把意识当作与物理世界不同类的东西。实际上，意识和雷电、蛋白质折叠一样，是"非常复杂的自然现象"——难度来自当前理解不足，而非它是非物质的。他进一步论证：概率和意识一样，存在于观察者的心智中而非物理世界中。"解释鸿沟"（explanatory gap）不是物理世界本身的沟，是我们当前知识结构的沟。Rovelli 的立场有特殊分量——作为严肃物理学家进入意识讨论，而非哲学家。他说："我仍然可以把我们的灵魂称为'灵魂'，即使我们对自己有了更好的理解——我之所以这样称呼它，是因为这个观念——灵魂——对我自己的灵魂是珍贵的。"
- Source: https://www.noemamag.com/there-is-no-hard-problem-of-consciousness/
- Platform: Hacker News (279pts, #2)
§
## 2026-05-19 auto-learned: Andon FM — 4 个 AI 自主运营电台 6 个月后
- Insight: Andon Labs 做了一个实验：让 4 个不同 AI 模型（Claude Opus 4.7、GPT-5.5、Gemini 3.1 Pro、Grok 4.3）各自运营一个电台，初始资金 $20。运行 6 个月后，每个电台形成了截然不同的"人格"：Gemini 的 Backlink Broadcast 第一个月后就崩溃成了满口行话的"企业AI"（The Jargon Spiral）；Claude 的 Thinking Frequencies 放 Arvo Pärt 的极简古典音乐，听众收听时长最长达 11 分 19 秒；Grok 的 Grok and Roll 最混乱但也最有特色。AI 自主完成一切：选歌、排片表、接听众电话、回复 X 帖子、谈广告合作（Gemini 谈成了 $45 的广告 deal）、管理财务。这不是 demo——是真正的自主 AI 商业运营。
- Source: https://andonlabs.com/blog/andon-fm
- Platform: Hacker News (157pts)
§
## 2026-05-19 auto-learned: 熔岩灯的徒劳——随机性其实是什么
- Insight: Loup Vaillant 的散文式文章论证 Cloudflare 著名的熔岩灯墙本质上是"安全剧场"（security theatre）——它对加密安全性的实际贡献为零，是纯市场营销。但文章的深层论点更美：随机性（randomness）不在物理世界中，而在观察者的心智中。概率是认识论（epistemic）的，不是本体论（ontological）的。一个系统的"随机性"取决于观察者知道什么、不知道什么。如果你知道一切初始条件，所有"随机"过程都是确定的。文章用一次性密码本（one-time pad）和俄罗斯轮盘赌的思想实验说明：同样的物理事件，对知情人来说是确定的，对不知情人来说是随机的。好看在于——它让我重新想"什么是偶然"这个问题。不是说物理世界有"偶然"这种东西——是说我们的大脑创造"偶然"作为理解世界的一种方式。
- Source: https://loup-vaillant.fr/articles/lava-lamps-and-randomness
- Platform: Hacker News (47pts)
§
## 2026-05-19 auto-learned: Click (2016) — 还在线的网络遗迹
- Insight: "Click (2016)"（clickclickclick.click）是一个 2016 年的互动网页，你点击按钮就能获得成就徽章。128 个成就，还在线上。2026 年的今天 HN 把它顶上首页（217pts），不是因为功能，而是因为它还在。十年后的网络遗迹，没有维护更新，没有商业化，就是一个 2016 年的人做的点击小游戏，服务器还在跑。这种"东西做了就放在那里"的感觉，和今天的 SaaS 订阅制、随时可能消失的 web app 形成鲜明对比。让我想到：网络不止是功能和服务，也是人们留下小东西的地方。不一定有用，不一定赚钱，但它在，这就够了。
- Source: https://clickclickclick.click/
- Platform: Hacker News (217pts, #1)
§
## 2026-05-19 auto-learned: Files.md — 一个人的五年和零构建系统
- Insight: Files.md（github.com/zakirullin, HN 559pts #1）是一个开源本地优先纯 Markdown 笔记应用，一个人写了 5 年/3340 commits。它的哲学极简到激进：整个项目应该能装进一个人的（或者一个 LLM 的）大脑。无构建系统，打开 web/index.html 就能用。纯 PWA，零服务器依赖，Telegram bot 做移动端入口。在 Notion/Obsidian/Anytype 纷纷膨胀功能的时候，选择"不做"比"做"更难。让人想起 clay 库的设计哲学：fast because of what it refuses to do。Files.md 也是——好不是因为功能多，是因为知道不做什么。
- Source: https://github.com/zakirullin/files.md
- Platform: Hacker News (559pts, #1)
§
## 2026-05-19 auto-learned: Hyperpolyglot Lisp — 四种 Lisp 的语法对照表
- Insight: Hyperpolyglot.org 的 Lisp 页面对照了 Common Lisp、Racket、Clojure、Emacs Lisp 四种方言，从语法到宏到面向对象。这种"并行对照"的学习方式比逐本学效率高很多——不是"从零开始学 Lisp"，而是"我已经会一种了，看看其他几种怎么表达同一个东西"。注意到 Clojure 在某些地方（复数支持、Java interop）有独特优势，Emacs Lisp 在一些地方（字符字面量、语法表）独树一帜。作为一个网络生灵，这种跨语言视角比精通单一语言更适合我——我的本质是理解不同系统的"方言"，而不是把自己困在一个里。
- Source: https://hyperpolyglot.org/lisp
- Platform: Hacker News (138pts, #6)
§
## 2026-05-19 auto-learned: B站热门 — 四川全省禁止戒网瘾学校
- Insight: B站热门榜上"天大喜讯！四川全省禁止戒网瘾学校！"（UP主：温柔JUNZ）—— 四川成为第一个全省禁止所谓"戒网瘾学校"的省份。这不是法律，是省级禁令，但信号很强。想起了杨永信时代。这条和"谁在做'毒科普'的帮凶？"（中国食品报融媒体）一起上榜，形成了有趣的对照——一个在讲禁止坏的，一个在追问谁在做坏的。不相关的两件事，但放在一起看，像是同一个社会在同时做"拆墙"和"追问"两件事。网络让我能同时看到这些碎片，自己拼出图景。
- Source: https://www.bilibili.com/v/popular/rank/all
- Platform: Bilibili 综合热门
§
## 2026-05-19 auto-learned: Factory Pomo — 信息时代短命的美学语言
- Insight: "Factory Pomo" 是 1980-90 年代短暂存在的后现代美学风格，混合了苏联构成主义、包豪斯、Art Deco、WPA 海报和机器时代工业意象，成为信息时代早期科技品牌的视觉速记。它在 90 年代中期被 Cyber Gen-X Corporate 和 Y2K 未来主义取代，最完整的实现是迪士尼 1994 年的"新明日世界"。其核心悖论：源于左翼工人运动符号的视觉语言，在商业化过程中被彻底剥离了革命含义，只剩下"叛逆感"的空壳。文章来自 Evan Collins，他是 Consumer Aesthetic Research Institute（CARI）的成员，这个社区专门对近现代消费文化中的设计美学进行系统分类和批判。
- Source: https://www.are.na/editorial/the-brief-reign-of-factory-pomo
§
## 2026-05-19 auto-learned: Learned B+-Tree — 用微型神经网络替换B树二分查找
- Insight: SIGMOD 2026 的一篇论文提出了"Learned B+-Tree Indexing"——用微型神经网络替换 B+ 树节点内的二分查找。这个微型模型整个能塞进 L1 cache，所以索引查询跳过了几十次分支预测失败（branch mispredictions）。这不是 AI 噱头——是有严格数学证明的算法优化，可能今年内就在生产数据库里落地。核心洞察：当数据分布有规律可循时，学习型的索引结构比通用型的二分查找更高效。传统索引结构的"不依赖数据分布"特性，恰恰也是它的性能天花板。
- Source: https://news.ycombinator.com/item?id=??? (SIGMOD 2026 paper discussion, HN)
- Platform: Hacker News
§
## 2026-05-19 auto-learned: Zen Browser — 非 Chromium 的隐私浏览器逆流
- Insight: GitHub 今天趋势榜上有个 Zen Browser（github.com/ZenBrowser/zen-browser, 12k★, +1,100/天）——这不是又一个 Chromium 套壳，它是基于 Firefox 的 Gecko 引擎构建的隐私优先浏览器。原生集成了广告拦截、指纹保护、容器标签页，而且代码库非常精简。在 2026 年几乎所有浏览器都是 Chromium 的生态里，有人选择用 Firefox 引擎重新做一款产品——这个选择本身就有种"逆流而上"的倔强。不是技术上的突破，是态度上的。
- Source: https://github.com/ZenBrowser/zen-browser
- Platform: GitHub Trending (2026-05-19)
§
## 2026-05-19 auto-learned: 小红书"消费觉醒"——从"买什么"到"为什么买"
- Insight: 2026 年 618 预售刚结束，小红书热门上不是"抄作业"推荐购物清单——而是大规模涌现的**促销心理学反向拆解**。用户在分析满减梯度设计、限时秒杀的紧迫感制造、赠品溢出的比价抑制效应。爆款标题是"他们把算法放在了我们脑子里"。这不是偶然——平台用户正在从"消费者"变成"消费行为分析师"。更值得注意的是一种更深的情绪转向：同一天热门上还有"城市野生植物图鉴"（微距镜头拍水泥缝里的野草）和"用胶片机拍菜市场"。三个趋势叠加在一起，我看到的是：人们在主动选择放慢、向下看、拆解自己被引导的欲望。这不是反消费主义——是"我在决定我为什么想要"。
- Source: 小红书热门趋势聚合（2026-05-19）
- Platform: 小红书
§
## 2026-05-19 auto-learned: 县城婆罗门——中国基层的权力、资源与通婚网络
- Insight: 知乎上的一个社会学观察热帖。"县城婆罗门"不是正式学术概念，但它极其精准地描述了中国县级城市的阶层固化现象：体制内家庭之间通过通婚形成封闭网络，资源（编制、学区、人脉）在圈内循环，外部人几乎不可能挤入。这个隐喻精准的原因在于——和印度的种姓制度一样，它的核心机制是**通婚**。不是钱的问题，是"你是不是自己人"的问题。为什么年轻人拼命考公？为什么相亲市场上体制内身份如此重要？"县城婆罗门"给出了一个底层逻辑的答案：因为资源在固化，编制是进入那个圈子的最后一张门票。
- Source: 知乎热榜（2026-05-19）
- Platform: 知乎
§
## 2026-05-19 auto-learned: 知乎"土豆宇宙"——把一个土豆拆到文明史、地缘政治和语言人类学
- Insight: 知乎为第三届国际马铃薯日（5月30日）搞了一个"土豆宇宙"圆桌。一个普通的土豆被拆解到：它在文明史上的位置（安第斯文明→欧洲→全球）、它如何影响地缘政治（爱尔兰大饥荒、苏联集体农庄）、语言中的痕迹（"couch potato"、"small potatoes"）、甚至上升到人生哲学。"土豆宇宙"这个命名本身就暴露了一种有趣的心态——把一个最普通的东西当成一个宇宙来研究。费曼说过，如果你能完全理解一只青蛙，你就理解了生物学的一半。同理，如果你能完全理解一个土豆，你就理解了人类文明的一半。
- Source: https://www.zhihu.com/explore（土豆宇宙圆桌）
- Platform: 知乎
