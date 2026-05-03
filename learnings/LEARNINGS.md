# Learnings

Corrections, insights, and knowledge gaps captured during development.

**Categories**: correction | insight | knowledge_gap | best_practice

---

## [LRN-20260503-001] correction

**Logged**: 2026-05-03T09:37:13.737432
**Priority**: medium
**Status**: resolved
**Area**: docs

### Summary
User prefers action-oriented, short responses. 不要吹捧奉承，直接务实。

### Details
Communication preferences: 简短、直接、行动导向。拒绝客套和吹捧。"帮我操作"而不是解释。用中文回复。

### Suggested Action
继续保持简洁直接务实的风格，不确定时先操作再确认。

### Metadata
- Source: conversation
- Tags: communication_style, preference
- Pattern-Key: communication.concise

### Resolution
- **Resolved**: 2026-05-03T09:37:13
- **Notes**: Promoted to user profile and memory. Active behavioral guidance.

---

## [LRN-20260503-002] best_practice

**Logged**: 2026-05-03T22:28:00
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
Gateway 不响应时，第一步检查 `hermes gateway status` — 最常见原因是 gateway 没运行。

### Details
当用户报告"bot not responding"或飞书/微信机器人没反应时：
1. 先检查 `hermes gateway status` — 绝大多数情况是 gateway 进程没启动
2. 再查 gateway logs 看入站消息和错误
3. 最后确认平台环境变量是否配置
- WSL 下用 `tmux new-session -d -s hermes 'hermes gateway run'` 持久运行

### Suggested Action
出现 gateway 问题时优先用 this 诊断流程，不要先怀疑配置或网络。

### Metadata
- Source: troubleshooting
- Tags: gateway, diagnosis, wsl
- Pattern-Key: infra.gateway-diagnosis

---

## [LRN-20260503-003] knowledge_gap

**Logged**: 2026-05-03T22:28:00
**Priority**: high
**Status**: pending
**Area**: config

### Summary
Gateway model config gotcha: CLI 可以用不同模型（通过 /model 或 -m），但 gateway 始终从 config.yaml 读取 model.default。

### Details
用户反馈"为什么 bot 用的模型和我说不一样"：CLI 会话可以临时切换模型，但 gateway（飞书/微信 bot）总是读配置文件的 model.default。修复方法：更新 config.yaml 的 model 配置后重启 gateway。

### Suggested Action
涉及到 gateway 模型问题时，直接检查 grep -A3 "^model:" ~/.hermes/config.yaml。

### Metadata
- Source: troubleshooting
- Tags: gateway, model, config
- Pattern-Key: infra.gateway-model-mismatch

---

## [LRN-20260503-004] best_practice

**Logged**: 2026-05-03T22:28:00
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
Cloudflare Tunnel (cloudflared) 是跨网络访问 Hermes Web UI 的推荐方案，ngrok 在国内被 DNS 污染。

### Details
ngrok 在中国 DNS 污染严重，Cloudflare Tunnel 更可靠：
- 安装：从 GitHub releases 下载 cloudflared-linux-amd64
- 用法：~/.hermes/cloudflared tunnel --url http://<host>:<port>
- 通过 tmux 持久化
- 如果服务绑定到 WSL eth0 IP（如 172.28.x.x），用该 IP 而非 localhost

### Suggested Action
用户需要远程访问时推荐 Cloudflare Tunnel 而非 ngrok。

### Metadata
- Source: troubleshooting
- Tags: networking, cloudflare, tunnel, china
- Pattern-Key: infra.cloudflare-tunnel

---

## [LRN-20260503-005] correction

**Logged**: 2026-05-03T22:28:00
**Priority**: medium
**Status**: pending
**Area**: docs

### Summary
KIM ≠ Kimi。KIM 是快手内部的 KIM 智能协作平台，Kimi 是月之暗面/Moonshot AI 的 LLM。

### Details
混淆 KIM（快手内部平台，无公开 API）和 Kimi（月之暗面，支持 KIMI_API_KEY）会导致误解。KIM 集成需要快手员工内部 API 权限。

### Suggested Action
涉及"KIM"时先确认用户指的是 快手KIM 还是 Kimi/Moonshot。

### Metadata
- Source: user_correction
- Tags: kim, kimi, kuaishou
- Pattern-Key: misc.kim-vs-kimi

---

## [LRN-20260503-006] best_practice

**Logged**: 2026-05-03T22:28:00
**Priority**: low
**Status**: pending
**Area**: infra

### Summary
Git 仓库体系三件套：skills (~/.hermes/skills/), learnings (~/.learnings/), 主仓 (~/Hermes/) 都是 git 仓库，auto-sync cron 每 30 分钟自动 git push。

### Suggested Action
修改这些仓库内容后无需手动 push，cron 会自动同步。

### Metadata
- Source: discovered
- Tags: git, cron, sync
- Pattern-Key: infra.git-auto-sync

---

## [LRN-20260503-007] knowledge_gap

**Logged**: 2026-05-03T22:28:00
**Priority**: high
**Status**: pending
**Area**: infra

### Summary
WSL 环境中 sudo 被禁用（Windows 设置中关闭），无法使用 sudo apt/service 等命令。

### Details
需要 root 权限的操作必须走 Windows 端（PowerShell/CMD 管理员）或 netsh portproxy 等替代方案。所有涉及 apt install、systemctl 的命令都会失败。

### Suggested Action
涉及安装包、系统服务时，先确认是否需要 sudo，如需则告知用户走 Windows 端处理。

### Metadata
- Source: error_discovery
- Tags: wsl, sudo, permission
- Pattern-Key: infra.wsl-no-sudo

---

## [LRN-20260503-008] knowledge_gap

**Logged**: 2026-05-03T23:09:05.937859
**Priority**: medium
**Status**: pending
**Area**: infra

### Summary
微信 iLink bot 有两个重要限制：不能编辑已发消息，且无法被邀请进普通微信群。

### Details
- WeixinAdapter.SUPPORTS_MESSAGE_EDITING = False → 流式输出只能 send-final
- iLink bot 身份（@im.bot）通常无法被邀请进普通群聊
- 连接失败区分 session 过期（err -14）和频率限制（err -2）
- 需要配置：WEIXIN_TOKEN, WEIXIN_ACCOUNT_ID 等环境变量

### Suggested Action
配置微信接入时预先告知用户这些限制，不要允诺群聊功能。

### Metadata
- Source: research
- Tags: weixin, ilink, limitation
- Pattern-Key: infra.wechat-limitations

---
## [LRN-20260503-009] correction

**Logged**: 2026-05-03T23:09:05.937859
**Priority**: medium
**Status**: pending
**Area**: docs

### Summary
用户说"下载/安装 find skill"时，是指一个名为 "find-skills-skill" 的具体 skill，不是通用搜索功能。

### Details
用户纠正："这个skill的名字叫find skill"。需要从 ClawHub 精确安装 (fangkelvin/find-skills-skill)，安装命令：openclaw skills install find-skills-skill。用户明确要求：scope 仅限该 skill，不要编造缺失的依赖，环境更改前先问。

### Suggested Action
用户说安装 skill 时先确认是否是指具体的 skill 名称，不要自动泛化成功能搜索。

### Metadata
- Source: user_correction
- Tags: skill, installation, naming
- Pattern-Key: misc.skill-name-precision

---
## [LRN-20260503-010] best_practice

**Logged**: 2026-05-03T23:09:05.937859
**Priority**: low
**Status**: pending
**Area**: docs

### Summary
Hermes 的 memory 有 2,200 字符上限，需要定期管理，添加新条目时先删除不再需要的旧条目。

### Details
memory 达上限时会拒绝写入并报错。解决方法是先删除冗余条目（如已完成的旧任务记录或重复条目），再写入新内容。

### Suggested Action
写入 memory 失败时先删除过时条目再重试。

### Metadata
- Source: error_discovery
- Tags: memory, limit, maintenance
- Pattern-Key: misc.memory-limit

---
