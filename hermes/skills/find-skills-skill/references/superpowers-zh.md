# Superpowers-zh 技能包详情

## 基本信息

- **仓库**: https://github.com/jnMetaCode/superpowers-zh
- **类型**: 社区技能包（非 ClawHub 发布）
- **星标**: 3.5k+
- **技能数量**: 20 个（14 翻译 + 6 中国特色）
- **支持工具**: Claude Code / Copilot CLI / Hermes Agent / Cursor / Windsurf / Kiro / Gemini CLI / Codex / Aider / Trae / VS Code / DeerFlow / OpenCode / OpenClaw / Qwen Code / Antigravity / Claw Code

## 技能列表

### 14 个翻译 Skills（英文上游 obra/superpowers）

| 技能名 | 用途 |
|--------|------|
| brainstorming | 头脑风暴：需求分析 → 设计规格 |
| writing-plans | 编写计划：把规格拆成可执行步骤 |
| executing-plans | 执行计划：按计划逐步实施 |
| test-driven-development | TDD：先写测试，再写代码 |
| systematic-debugging | 系统化调试：四阶段调试法 |
| requesting-code-review | 请求代码审查 |
| receiving-code-review | 接收代码审查 |
| verification-before-completion | 完成前验证 |
| dispatching-parallel-agents | 并行 Agent 派遣 |
| subagent-driven-development | 子 Agent 驱动开发 |
| using-git-worktrees | Git Worktree 使用 |
| finishing-a-development-branch | 完成开发分支 |
| writing-skills | 编写 Skills 方法论 |
| using-superpowers | 元技能：如何调用技能 |

### 6 个中国特色 Skills（原创）

| 技能名 | 用途 | 调用方式 |
|--------|------|---------|
| chinese-code-review | 符合国内团队文化的代码审查 | 手动 `/chinese-code-review` |
| chinese-git-workflow | 适配 Gitee/Coding/极狐 GitLab/CNB | 手动 `/chinese-git-workflow` |
| chinese-documentation | 中文排版规范、中英混排 | 手动 `/chinese-documentation` |
| chinese-commit-conventions | 适配国内团队的 commit 规范 | 手动 `/chinese-commit-conventions` |
| mcp-builder | MCP 服务器构建 | 自动触发 |
| workflow-runner | YAML 工作流执行器 | 自动触发 |

## 安装步骤

```bash
# 1. 克隆仓库
git clone --depth 1 https://github.com/jnMetaCode/superpowers-zh.git /tmp/superpowers-zh

# 2. 验证技能结构
ls /tmp/superpowers-zh/skills/  # 应看到 20 个目录

# 3. 复制到 Hermes 技能目录
mkdir -p ~/.hermes/skills
cp -r /tmp/superpowers-zh/skills/* ~/.hermes/skills/

# 4. 验证安装
ls ~/.hermes/skills/ | wc -l  # 应显示 20
skill_view(name='brainstorming')  # 测试加载
```

## 关键要点

1. **技能优先级**: 用户指令 > Superpowers 技能 > 默认系统提示
2. **必须调用**: 如果只有 1% 的可能性某个技能适用，必须调用该技能检查
3. **Hermes 调用**: `skill_view(name='skill-name')`
4. **手动调用**: 输入 `/chinese-code-review` 等命令

## 配套生态

- **agency-agents-zh**: 211 个 AI 专家角色库
- **agency-orchestrator**: 一句话调度 211 个专家协作
- **ai-coding-guide**: AI 编程实战教程

## 安装时间

2026-05-20
