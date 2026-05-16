---
name: agent-memory-bootstrap
description: >-
  Equip any AI agent with Hermes-style persistent memory (USER.md + MEMORY.md
  + loading mechanism). Covers creating the memory directory structure,
  writing user profile and environment notes, and configuring the target agent
  to load them on startup.
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [memory, agent-setup, configuration, cross-agent, multi-agent]
---

# Agent Memory Bootstrap

Equip another AI agent (reasonix, opencode, claude-code, etc.) with
the same persistent memory pattern Hermes uses.

## When to Use

- User asks "给这个装上你同款的记忆" for another agent
- Setting up a new agent instance and want memory persistence
- Running multiple agents and want consistent user context across all
- Migrating memory config from one agent to another

## The Pattern

Three components:

```
~/.reasonix/                      # Target agent's home directory
├── memories/
│   ├── USER.md                   # Who the user is — injected as context
│   └── MEMORY.md                 # Environment notes — injected as context
├── skills/
│   └── memories/
│       └── SKILL.md              # Tells the agent to load USER.md + MEMORY.md
└── REASONIX.md / AGENTS.md       # User-level instruction to load the memory skill
```

### 1. Create `memories/USER.md`

User profile — what the agent needs to know about the person it's serving.

Content sourced from Hermes's own `memories/USER.md`. Include:
- Name (if known)
- GitHub / online handles
- Communication preferences (direct? Chinese? no fluff?)
- Personality type / quirks (if documented)
- Relationship mode with the agent (if applicable)

### 2. Create `memories/MEMORY.md`

Environment and operations knowledge. Content sourced from Hermes's
own `memories/MEMORY.md`. Include:
- OS and shell quirks (Windows git-bash, WSL, etc.)
- Installed tool paths and caveats
- Credential/key locations (without exposing secrets)
- Project conventions
- Cron jobs or scheduled tasks the other agent should know about

### 3. Create a memory-loading skill or instruction

The target agent needs to read the memory files on startup. The
mechanism depends on the agent platform:

| Agent | Loading mechanism |
|-------|------------------|
| **reasonix** / **codex** (OpenClaw skills) | Create `skills/memories/SKILL.md` + `REASONIX.md` in home dir |
| **Claude Code** | Add instruction to `CLAUDE.md` or `AGENTS.md` |
| **OpenCode** | Create a skill or update `AGENTS.md` |
| **Generic CLI** | Add `--instructions` flag or a system prompt file |

**SKILL.md template:**

```markdown
---
name: memories
description: 持久化记忆系统 — 在每次对话开始时自动加载用户画像和环境笔记
---

## 记忆系统

每次对话开始时，你必须先读取以下两个文件：

### 1. 用户画像
文件: `memories/USER.md`

### 2. 环境笔记
文件: `memories/MEMORY.md`

## 规则

- 每次新会话必须先读取这两个文件，再处理用户消息
- 遵循 USER.md 中的沟通偏好
- 如果用户在对话中告知了新信息，记录下来以便更新
```

**REASONIX.md / instruction file template:**

```markdown
# Agent Instructions

你已安装 `memories` 技能。每次新会话开始：

1. 加载 `memories` 技能
2. 读取 `memories/USER.md` 和 `memories/MEMORY.md`
3. 按用户偏好的沟通风格回应
```

## Workflow

1. **Check target agent's home directory exists**
   - `~/.reasonix/`, `~/.codex/`, `~/.claude/`, etc.
   - If not, ask user to install the agent first

2. **Copy user profile from Hermes**
   ```bash
   cp ~/AppData/Local/hermes/memories/USER.md /target/memories/USER.md
   # or re-create with relevant content
   ```

3. **Copy environment notes from Hermes**
   ```bash
   cp ~/AppData/Local/hermes/memories/MEMORY.md /target/memories/MEMORY.md
   # or re-create with relevant content
   ```

4. **Create loading mechanism**
   - Skill file: `skills/memories/SKILL.md`
   - User instruction: `REASONIX.md` or `AGENTS.md`

5. **Verify structure**
   ```bash
   find /target -name "USER.md" -o -name "MEMORY.md" -o -name "SKILL.md" -o -name "REASONIX.md"
   ```

## Pitfalls

- **The target agent may not automatically discover skills.** Some agents
  scan `skills/` at startup; others require explicit loading. Always add
  an instruction file (`REASONIX.md`, `AGENTS.md`, `CLAUDE.md`) at the
  home dir level to tell the agent to load the memory skill.
- **Memory files are read once at session start.** If the user updates
  them mid-session, the agent won't see changes until the next session.
  For dynamic memory, use the agent's built-in memory tool (if any).
- **Don't include secrets in MEMORY.md.** Environment notes should say
  "API key is stored in .env" not "API key = xyz123".
- **Different agents use different instruction file names.** reasonix
  may support `REASONIX.md`, Claude Code reads `CLAUDE.md`, others read
  `AGENTS.md`. Check the target agent's skill loading or instruction docs.
- **Chinese characters in script/instruction files cause encoding issues
  on some Windows-based agents.** Write instruction files in English or
  test that the target agent handles UTF-8 correctly.
