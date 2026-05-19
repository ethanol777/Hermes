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
