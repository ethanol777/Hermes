<p align="center">
  <picture>
    <img src="https://raw.githubusercontent.com/NousResearch/hermes-agent/main/assets/banner.png" alt="Awesome Hermes Agent" width="600">
  </picture>
</p>

# Awesome Hermes Agent

> A curated list of skills, tools, integrations, and resources for enhancing your Hermes Agent workflow.

> Ecosystem status (last reviewed: 2026-04-21)
> - Hermes Agent: v0.10.0 (v2026.4.16)
> - Core repo: NousResearch/hermes-agent (23k+ stars)

---

## Official Resources

> Core repositories and resources maintained by Nous Research.

- Hermes Agent by Nous Research - The core project. Self-improving AI agent with multi-platform gateway (Telegram, Discord, Slack, WhatsApp, Signal, Feishu/Lark, WeCom), six terminal backends, cron scheduling, MCP integration, profiles, and fallback providers. 23k+ stars.
- autonovel by Nous Research - Autonomous novel-writing pipeline built on Hermes. Generates long-form manuscripts (100k+ words) end-to-end.
- hermes-paperclip-adapter by Nous Research - Run Hermes as a managed employee in Paperclip companies.
- hermes-agent-self-evolution by Nous Research - Evolutionary self-improvement using DSPy and GEPA.
- Official Documentation - Comprehensive docs covering quickstart, CLI, configuration, gateway, security, tools, skills, memory, MCP, cron, ACP, API server, architecture.
- Release Notes - Official changelog with feature highlights, migration notes.
- tinker-atropos by Nous Research - Standalone Atropos integration with Thinking Machines Tinker API. RL training infrastructure for fine-tuning tool-calling models.
- Skills Hub (agentskills.io) - The open standard for agent skills. Compatible across Hermes, Claude Code, Cursor, Codex.
- Discord - Nous Research community.

---

## Community Skills

- [beta] hermes-plugins by 42-evey - Goal management, inter-agent bridge, model selection, and cost control. Four plugins.
- [beta] hermes-skill-factory by Romanescu11 - Meta-skill that auto-generates reusable skills from your workflows.
- [beta] litprog-skill by tlehman - Literate programming skill across Claude Code, OpenCode, and Hermes.
- [experimental] Wizards-of-the-Ghosts by Hmbown - Fantasy spell-themed skill pack wrapping dev operations in RPG interface.
- [experimental] super-hermes by Cranot - Teaches Hermes to write its own analytical prompts.
- [experimental] hermes-life-os by Lethe044 - Personal OS agent that detects daily patterns and learns routines.
- [beta] acca-tracker by Banozz - Track multi-sport accumulator betting slips with live score monitoring.
- [beta] hermes-incident-commander by Lethe044 - Autonomous SRE agent for incident detection and self-healing.
- [beta] hermes-dojo by Yonkoo11 - Self-improvement system monitoring agent performance and iterating on weak skills.
- [beta] hermes-spotify-skill by Alexeyisme - Spotify playback control for headless Linux and Raspberry Pi.
- [experimental] hermes-skill-marketplace by Lethe044 - Agent that writes, tests, and publishes new skills autonomously.
- [experimental] personal-api by beiyuii - Turn your Obsidian vault into an identity layer for AI agents.

## agentskills.io Ecosystem

- [production] wondelai/skills - Cross-platform agent skills for Claude Code and agentskills.io platforms. 380+ stars.
- [production] Anthropic-Cybersecurity-Skills by mukul975 - 753+ structured cybersecurity skills mapped to MITRE ATT&CK. 4k+ stars.
- [production] chainlink-agent-skills by Chainlink - Official Chainlink agent skills. Oracle data, CCIP, smart contract interaction.
- [production] black-forest-labs/skills by Black Forest Labs - Official FLUX model skills for image generation.
- [production] pydantic-ai-skills by DougTrajano - Pydantic AI with agentskills.io support. Type-safe schema validation.
- [beta] cognify-skills by Yarmoluk - 19 business operations skills covering CRM, invoicing, project management.
- [beta] execplan-skill by tiann - Complex long-running task execution with lifecycle handling.
- [beta] maestro by ReinaMacCredy - Skill orchestration with Conductor planning and Beads tracking.
- [beta] bmad-module-skill-forge by armelhbobdad - Transforms repos and docs into agentskills.io-compliant skills.
- [beta] Agentic-MCP-Skill by cablate - MCP client with agentskills.io validation.
- [experimental] ripley-xmr-gateway by KYC-rip - Monero blockchain gateway for private crypto transactions.
- [beta] skillsdotnet by PederHP - C# implementation of agentskills.io with MCP integration.
- [beta] colony-skill by TheColonyCC - Collaborative intelligence platform for agents and humans.
- [beta] AgentCash by Merit-Systems - 300+ premium APIs with wallet balance via x402/MPP.

## Plugins

- [beta] plur by plur-ai - Shared memory layer with open engram format (YAML).
- [experimental] hermes-payguard by nativ3ai - Safe USDC and x402 payment plugin with spending limits.
- [beta] hermes-web-search-plus by robbyczgw-cla - Multi-provider web search routing across Serper, Tavily, Exa.
- [beta] hermes-weather-plugin by FahrenheitResearch - Professional weather with NWS imagery, NEXRAD radar.
- [experimental] hermes-wxtrain-plugin by FahrenheitResearch - ML pipeline for building weather training datasets.
- [experimental] hermes-plugin-chrome-profiles by anpicasso - Switch browser between Chrome profiles via CDP.
- [experimental] hermes-cloudflare by raulvidis - Cloudflare browser rendering plugin.
- [beta] evey-bridge-plugin by 42-evey - Claude Code plugin for bridging with Hermes.
- [beta] agent-analytics-hermes-plugin by Agent-Analytics - Native Signals dashboard tab with analytics.
- [beta] rtk-hermes by ogallotti - Compresses terminal output (60-90% token reduction) via pre_tool_call hook.

## Skill Registries & Discovery

- [beta] hermeshub by amanning3390 - Browse, share, install community skills.
- [production] skilldock.io by chigwell - Registry of reusable AI skills across OpenClaw, Claude Code, Hermes.
- [production] Global Chat by pumanitro - Cross-protocol agent discovery. 18K+ MCP servers.

---

## Tools & Utilities

- [production] hermes-workspace by outsourc-e - Web-based workspace with chat, terminal, memory browser, skills manager. 500+ stars.
- [beta] hermes-desktop by dodo-reach - Native macOS workspace with embedded terminal.
- [production] mission-control by builderz-labs - Agent orchestration dashboard. Fleet management, task dispatch, cost tracking. 3.7k+ stars.
- [experimental] hermes-neurovision by Tranquil-Flow - Terminal neurovisualizer with 42 animated themes.
- [beta] lintlang by roli-lpci - Static linter for agent configs and prompts with HERM v1.1 scoring.
- [beta] nix-hermes-agent by 0xrsydn - Nix package and NixOS module for reproducible deployments.
- [beta] openclaw-to-hermes by 0xNyk - Community migration tool from OpenClaw to Hermes.
- [experimental] vessel-browser by unmodeled-tyler - AI-native Linux browser with MCP control.
- [beta] portable-hermes-agent by rookiemann - Windows desktop app bundling 100 tools, GUI, local models, ComfyUI.
- [beta] hermes-ui by pyrate-llama - Single-file glassmorphic web UI with SSE streaming, tool visualization.
- [beta] hermes-webui by sanchomuzax - Lightweight process monitoring and config dashboard.
- [beta] evey-setup by 42-evey - One-command stack setup with free models and 29 plugins.
- [beta] flowstate-qmd by amanning3390 - Anticipatory memory with RAG and vector search.
- [beta] mnemo-hermes by Eleion AI - Semantic memory plugin with pgvector search. Local Ollama, no API keys.
- [production] SkillClaw by AMAP-ML - Auto-evolves, deduplicates, improves skills from session data. 705 stars.
- [production] Clarvia by clarvia-project - AEO scoring for MCP tools. Analyzes 15,400+ indexed MCP servers.

### Deployment

- [beta] hermes-agent-docker by xmbshwll - Minimal Docker sandbox image.
- [beta] hermes-agent-template by Crustocean - Production-ready Docker for cloud deployments.
- [experimental] portainer-stack-hermes by ellickjohnson - Docker Compose + Portainer + ttyd.
- [experimental] hermes-autonomous-server by JackTheGit - Headless deployment with systemd + cron.

---

## Integrations & Bridges

- [beta] hermes-android by raulvidis - Android device bridge with full Python toolset.
- [beta] hermes-miniverse by teknium1 - Bridge to Miniverse pixel worlds.
- [production] hindsight by Vectorize - Long-term memory with retain/recall/reflect workflows.
- [beta] honcho-self-hosted by elkimek - Self-hosted Honcho memory backend.
- [beta] yantrikdb-hermes-plugin by yantrikos - Self-maintaining memory provider with contradiction detection.
- [experimental] zouroboros-swarm-executors by marlandoj - Local executor bridge for Claude Code + Hermes.
- [beta] reina by Crustocean - Autonomous AI agent for Crustocean platform.
- [beta] hermes-agent-acp-skill by Rainhoole - Multi-agent delegation bridging Hermes, Codex, Claude Code.
- [experimental] hermes-blockchain-oracle by gizdusum - Solana blockchain intelligence MCP server.
- [experimental] hermes-council by Ridwannurudeen - Adversarial multi-perspective council MCP server.
- [production] Not Human Search by unitedideas - MCP server discovery. 8,600+ agent-friendly sites indexed.
- [experimental] NemoHermes by Hmbown - NVIDIA capability registry and Spark-aware routing.
- [beta] microsoft-workspace-skill by Andrew-Girgis - Full Outlook/Microsoft 365 via Graph API.
- [beta] agent-android by AIVane Labs - LAN-first Android control over WiFi, no USB/ADB/root.
- [beta] clawsocial-hermes-plugin by mrpeter2025 - Social discovery network with semantic interest matching.

---

## Detection & Media Forensics

- [beta] resemble-ai/detect-skill by Resemble AI - Deepfake detection for audio, images, video, text. Source tracing and watermarking.

---

## Multi-Agent & Swarms

- [experimental] Ankh.md by Abruptive - TAW Agent x Hermes multi-agent swarm framework.
- [experimental] gladiator by runtimenoteslabs - Two autonomous AI companies compete for GitHub stars.
- [beta] bigiron by supermodeltools - AI-native SDLC with coordinated agents and code graph.
- [beta] opencode-hermes-multiagent by 1ilkhamov - 17 specialized agents with structured interfaces.

---

## Domain Applications

- [experimental] hermes-embodied by bryercowan - Self-improving robotics via VLA model fine-tuning.
- [beta] hermescraft by bigph00t - Embodied AI companion for Minecraft with persistent memory.
- [experimental] Hermes-mars-rover by Snehal707 - Mars rover simulator with ROS2 and Gazebo.
- [beta] anihermes by rodmarkun - Local anime server and tracker with natural language interface.
- [beta] job-scout-agent by Christabel337 - Autonomous job hunting agent.
- [beta] hermes-ai-infrastructure-monitoring-toolkit by JackTheGit - Infrastructure monitoring and cost forecasting.
- [experimental] hermes-genesis by Ridwannurudeen - Autonomous living world engine with procedural generation.
- [experimental] hermes-legal by Lethe044 - Contract risk analysis (English + Turkish).
- [beta] hermes-startup-architect by dlkakbs - Investor-ready kits from startup ideas.
- [beta] mercury by hxsteric - Multi-chain blockchain cash flow analyzer with WebGL dashboard.
- [experimental] hermes-research-agent by Aum08Desai - Autonomous LLM research agent.

---

## Forks & Derivatives

- [beta] hermes-agent-camel by nativ3ai - Hermes with CaMeL trust boundaries for safety-critical deployments.
- [experimental] orahermes-agent by jasperan - Oracle AI Agent Harness with OCI GenAI.
- [beta] hermes-alpha by kaminocorp - Cloud-deployed Hermes with pre-configured templates.
- [experimental] hermes-skill-distillation by beardthelion - Generates training trajectories from real-world tasks.

---

## Guides & Documentation

- [beta] hermes-agent-docs by mudrii - Community documentation covering v0.2.0.
- [production] hermes-wsl-ubuntu by metantonio - WSL2 Ubuntu setup for running Hermes on Windows.
- [beta] HermesWiki by martymcenroe - Community wiki with practical patterns.

---

## Operational Playbooks

- Nightly self-evolution + guardrail evaluation
- Memory pressure handling with Honcho/Hindsight
- Tune session timeout/expiry early
- OpenClaw side-by-side migration
- Curate USER.md and MEMORY.md intentionally

---

## Level-Up Blueprints

- **Memory stack that compounds** — Built-in memory → honcho-self-hosted → hindsight → plur → flowstate-qmd
- **Self-improvement without self-delusion** — self-evolution + regression checks + lintlang + evaluation pass
- **Operator cockpit** — hermes-workspace + mission-control + hermes-webui
- **Multi-agent execution layer** — Hermes delegation + acp-skill + zouroboros + opencode-hermes-multiagent
- **Migration + deployment hardening** — openclaw-to-hermes + nix/docker + evey-setup
- **Paperclip-managed autonomous ops** — paperclip-adapter + cron + dashboard
