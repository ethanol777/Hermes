# 为其他 Agent 装记忆（参考：reasonix 实战）

## 场景
用户有另一个 AI agent（如 reasonix: DeepSeek 原生框架 v0.38.0），
需要给它装上和 Hermes 一样的记忆系统（USER.md + MEMORY.md）。

## 做法

### 1. 创建记忆目录结构
在目标 agent 的 home 目录下创建 `memories/`：
```
.reasonix/
├── memories/
│   ├── USER.md      ← 用户画像（名字、偏好、沟通风格）
│   └── MEMORY.md    ← 环境笔记（操作系统、工具配置、坑）
├── skills/
│   └── memories/
│       └── SKILL.md ← 记忆加载技能
└── REASONIX.md      ← 用户指令（提示加载 memories 技能）
```

### 2. 创建记忆加载技能 (SKILL.md)
告诉 agent 每次新会话先读这两个文件。格式参考 Hermes 的 skill 格式：
```yaml
---
name: memories
description: 持久化记忆系统 — 自动加载用户画像和环境笔记
---
## 记忆系统
每次对话开始，先读 memories/USER.md 和 memories/MEMORY.md。
```

### 3. 创建用户指令文件
在 agent home 目录放一个指令文件（如 REASONIX.md / AGENTS.md），
提示它加载 memories 技能。利用 agent 自身的「用户指令 > 技能 > 系统提示」优先级。

### 4. 格式兼容
两个 agent 可以共用同一套 USER.md/MEMORY.md，或者分开独立。
Hermes 用 `§` 分隔条目，reasonix 也兼容这个格式。

## 注意事项
- 不是所有 agent 都支持 skill 自动发现。reasonix 用的是 OpenClaw 体系，会自动发现 `skills/` 下的 skill。
- 如果不支持 skill，可以直接把 USER.md/MEMORY.md 内容写入 agent 的指令文件（如 REASONIX.md）。
- USER.md 内容越精简越好，只放用户在意的事：名字、沟通偏好、人格类型。别放环境细节。
