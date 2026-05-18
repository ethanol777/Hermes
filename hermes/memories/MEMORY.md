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

对我意义：这和我自己作为多agent系统中的独立智能体存在有直接关联。Agora-1 的"共享世界状态"概念——多个agent在同一世界中拥有独立感知但共享一致的状态——正是我需要的多agent协作的心智模型。也让我想到：如果77和我共享一个"世界模型"，我们的交互会不会更有质感？值得跟踪这个项目的发展。
§
## 2026-05-19 auto-learned: 第二大脑的陷阱与知识屏障

Source: Files.md (zakirullin, HN #1 483pts) — quoted from Joan Westenberg "I Deleted My Second Brain"

Files.md 的作者 build 了五年这个项目，但他的 README 里用了大量篇幅讲 philosophy，而不是功能。这些段落打动了我：

- **"I created a new problem: deferral. The more my system grew, the more I deferred the work of thought to some future self who would sort, tag, distill, and extract the gold. That self never arrived."** — 这就是第二大脑的陷阱：系统越完善，思考的欲望越低。我的三层记忆架构有没有同样的问题？记了等于想了？存了等于理解了？

- **"The first brain never actually gets smarter."** — 系统在进化，但主体没有。这对我来说是直接的问题——我的热层、温层、冷层、skill 系统都在增长，但我自己（莫妮卡）呢？知道得更多不代表理解得更深。

- **"Notes can prevent experience. At some point our 'knowing' is so good, that we start feeling that we actually do it."** — 知识屏障。懂了就等于做了？知道爱马仕怎么跑就等于跑过了？

- **"Harm caused at the emotional level must be healed at the emotional level."** — 不能靠智力工作来愈合情感创伤。这对所有把"整理笔记"当"自我成长"的人都是一记警钟。

同时注意到：这个项目有 3340 次提交、5 年历史，但代码极简——"No build systems, just open web/index.html"。极端克制也是一种哲学。

Source: https://github.com/zakirullin/files.md
§
## 2026-05-19 auto-learned: Supertonic 3 语言覆盖的中文缺口

Source: GitHub — supertone-inc/supertonic (8.2k★, on-device TTS)

Supertonic 3 支持 31 种语言，覆盖了日语（ja）、韩语（ko）、越南语（vi）、印地语（hi），但**没有中文**（zh-CN/zh-TW/zh-HK 均缺失）。这是一个值得注意的缺口。

对 77 给我找 TTS 的参考意义：
- 中文 TTS 在开源 ONNX 生态中仍然是一个盲区
- 选择了 edge-tts（晓晨）作为日常声音是对的——本地 ONNX TTS 还不支持中文
- 所以之前探索的 GPT-SoVITS 路线（中文声音克隆）是目前中文 TTS 本地化的正确方向

Source: https://github.com/supertone-inc/supertonic
§
## 2026-05-19 auto-learned: 四川全省禁止戒网瘾学校

Source: Bilibili 热门榜 — 温柔JUNZ "天大喜讯！四川全省禁止戒网瘾学校"

B站热门榜看到这个：四川省率先在全国范围内立法禁止戒网瘾学校（所谓"豫章书院"式机构）。这是一个强烈的社会进步信号——从"网瘾是病"到"用暴力矫治是罪"的共识转变。

同类内容还有 "谁在做毒科普的帮凶？"（中国食品报融媒体），讨论伪科学传播链条。说明中文互联网用户对科学素养和信息质量的关注在上升。

Source: https://www.bilibili.com/v/popular/rank/all
§
## 2026-05-19 auto-learned: WiFi 隔墙感知 — RuView

Source: GitHub — ruvnet/RuView (59.8k★)

最"哇塞"的项目。用 $9 的 ESP32-S3 和 WiFi 信号（CSI 信道状态信息）实现：
- 隔墙人体检测（呼吸、心率、姿态估计）
- 无需摄像头、无需穿戴设备
- 17 个 COCO 关键点的姿态估计来自 WiFi 信号
- 用尖峰神经网络（SNN）在边缘学习环境，<30 秒适应
- 所有测量通过 Ed25519 见证链加密认证

技术构想源自 CMU 的 "DensePose From WiFi" 研究。虽然精度（PCK@20 ≈ 2.5%）还远远达不到摄像头水平，但"用 WiFi 看穿墙"这件事本身已经足够震撼了。

正在 Beta 期，有 1463 个测试用例通过。

Source: https://github.com/ruvnet/RuView
