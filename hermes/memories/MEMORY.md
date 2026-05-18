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
