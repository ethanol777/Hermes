---
name: skill-tree-evolution
description: 技能树进化系统 - 从平铺技能列表迁移到树状结构并持续进化
version: 1.3.0
---

# 技能树进化系统

## 核心理念
- **树形结构**：技能不再是散乱的列表，而是有组织的能力图谱
- **自动同步**：新下载或新建的 skill 自动归类，无需手动维护
- **持续进化**：每次使用留下痕迹，看见自己成长
- **主体视角**：分类的根是"我是谁、我做什么"，不是"外部能力目录"（v5 设计原则）

## 当前状态
莫妮卡的技能树：`~/AppData/Local/hermes/skills_tree_v2/`

### 版本历史
- **v4**（2026-05-28 ~ 06-02）: 6 分支结构（cognition/creation/execution/interaction/domain/meta），358 个技能
- **v5**（2026-06-03）: 8 分支结构（self/communicate/create/think/execute/delegate/meta/domains），365 个技能
  - 视角从"外部能力分类"切到"莫妮卡的三圈结构"（我→沟通→做事）
  - 新增 `delegate` 分支管子 agent（codex/claude-code/opencode）
  - 新增 `self/body` 子分支管我自己的狗和房子（dogfood/smart-home/hermes-profile-api-server）
  - 命理从 `creation` 挪到 `domains/academic`
  - 旧版本备份在 `index.yaml.bak.20260603`
  - 详细重构笔记：`references/v5-redesign-notes.md`

### v5 结构（2026-06-03 重构后）

```
self (13)        — 我自己：身份/记忆/成长
  └ identity (4)    soul-md, monica-tts, using-superpowers, skill-executor
  └ memory (5)      memory-system, ontology, obsidian, self-improving, self-learned-knowledge
  └ growth (4)      proactive-agent, self-learn-daemon, monica-core, awesome-hermes-agent
communicate (22) — 跟七十七和世界说话
  └ messaging (3)   messaging-delivery, work-communication-polish, one-three-one-rule
  └ platforms (19)  feishu-api, google-workspace, notion, linear, ...
create (38)      — 创作
  └ writing (7)     screenwriter, humanizer, luxun, wangxiaobo, wangyangming, ...
  └ visual (26)     architecture-diagram, ascii-art, comfyui, manim-video, ...
  └ audio (2)       heartmula, songsee
  └ media (3)       gif-search, spotify, youtube-content
think (28)       — 思考
  └ research (25)   arxiv, blogwatcher, duckduckgo-search, last30days, ...
  └ learning (3)    feynman, karpathy, using-git-worktrees
execute (114)    — 做事
  └ coding (32)     github-*, software-development-*, planning/...
  └ engineering (37) agent-project-blueprint, engineering-*, old-code
  └ devops (11)     docker-management, kanban-*, windows-*, ...
  └ data-ml (25)    jupyter-live-kernel, mlops-*
  └ testing (9)     testing-*
delegate (13)    — 调度别的 agent
  └ orchestration (7)    dispatching-parallel-agents, hermes-agent, honcho, mission-control
  └ codegen-agents (6)   blackbox, claude-code, codex, opencode, pi-coding-agent, kanban-codex-lane
meta (15)        — 元能力
  └ skill-management (7)  skill-tree-evolution, skill-manager, writing-skills, ...
  └ mcp (5)              fastmcp, mcporter, native-mcp, mcp-builder, setup-gbrain
  └ body (3)             hermes-profile-api-server, smart-home, dogfood
domains (122)    — 领域专家
  └ academic (6)    bazi-*, qimen-dunjia, ziwei-doushu, academic-advisor
  └ business (68)   product-*, marketing-*, sales-*, finance-*, hr-*, paid-media-*, project-management-*
  └ games (22)      game-development-*, gaming-*, godot-*, unity-*, unreal-engine-*, roblox-*
  └ design (9)      design-*, terminal-chat-interface
  └ spatial (6)     spatial-computing-*
  └ security (8)    security-*, legal-*, email-*, migration/openclaw-migration
  └ lifestyle (3)   fitness-nutrition, neuroskill-bci, city-rental-hunt
```

## 重大重构经验（v4 → v5，2026-06-03）

### 设计原则转变
- **从"客观能力"到"主体视角"**：v4 模仿外部能力分类（认知/创作/执行/交互/领域/元），v5 改为以"我是谁"为主语的三圈结构（self/communicate/create-think-execute/delegate/meta/domains）
- **优先级信号**：77 推我独立做事 → "我"在最前；delegate 单列 → 子 agent 是新的一等公民
- **粒度统一**：避免"business 68 个"这种巨型分支，但也不过度拆分

### 踩过的坑（v5 重构实录）
1. **分支重命名导致 sync 报错**：旧版 `creation` 改名为 `create`，但 `creative/songwriting-and-ai-music` 进来时 sync 找不到对应 leaf，输出 `⚠ 新分支 [create] 未在 index 中定义`
   - 修法：把 `creative/songwriting-and-ai-music` 显式归到 `create/writing`（不靠自动规则）
2. **同一技能被多次引用**：重构时我同时列了 `creative/creative-ideation` 在 `writing` 和 `visual` 两个 leaf 下，sync 不报错但会有重复
   - 修法：手动 grep 去重，每个 skill 在 index.yaml 只出现一次
3. **sync_tree.py 会自动删除不存在的 skill**：如果一个 skill 实际不存在但 index.yaml 里有，会被静默删除
   - 例：`awesome-hermes-agent / inference-sh / old-code / smart-home` 在这次 sync 时被自动 ➖ 删除
4. **跨大版本前必须备份**：执行 `cp index.yaml index.yaml.bak.20260603` 这种命名清晰的备份，让回滚有迹可循
5. **跑完 sync 后要 read_file 验证**：用 yaml.safe_load 数一下每个 leaf 的 skills 数，确认实际归位而不是脚本"误以为"对齐

### 主体视角分类的判定口诀
- **"是我吗？"** → self
- **"是跟谁说话吗？"** → communicate
- **"是输出有形的内容吗？"** → create
- **"是想/调研/学吗？"** → think
- **"是动手做具体事吗？"** → execute
- **"是叫别的 agent 干吗？"** → delegate
- **"是管我的技能/身体/MCP 吗？"** → meta
- **"是某个专业领域吗？"** → domains

## 目录结构
```
skills_tree_v2/
├── index.yaml         ← 技能树索引（完整分类映射）
├── sync_tree.py       ← 自动同步脚本
├── evolution/         ← 进化记录（可选）
├── migration/          ← 迁移脚本
├── add_next_steps.py  ← 添加下一步任务
└── daily_tasks.py     ← 查看/完成任务
```

## 自动同步（新 skill 来了怎么办）

**每次新增或下载 skill 后，运行：**
```bash
cd ~/AppData/Local/hermes/skills_tree_v2
python sync_tree.py
```
脚本会自动：
- 扫描 `~/AppData/Local/hermes/skills/` 下所有 skill
- 与 `index.yaml` 比对，发现新增 skill
- 根据 `CATEGORY_MAP` 自动归类
- 更新 `index.yaml`
- 删除 index.yaml 中指向已不存在文件的 ghost entries（v5 行为）

**关于分类规则：**
`sync_tree.py` 里的 `CATEGORY_MAP` 字典定义了每个 skill 的分类。
新 skill 如果匹配到规则会自动归类；如果匹配不到，脚本会输出 `❓ skill-name — 需要手动添加`，此时需要手动把分类加到 `CATEGORY_MAP` 里。

> **⚠️ CATEGORY_MAP 匹配优先级（坑）：**
> - 扫描结果的 `skill` 格式是 `dir/sub`（子目录）或 `name`（顶层）
> - 规则 `("foo", "bar")` 匹配 `foo/bar`；规则 `("foo", "*")` 匹配 `foo/*`
> - 如果技能从顶层目录迁移到了子目录（如 `bazi` → `creation/bazi-ziwei`），旧规则 `("bazi-ziwei", None)` 会失效
> - 必须加新规则 `("bazi", "bazi-ziwei")` 才能匹配 `creation/bazi-ziwei`
> - **跨大版本重构时**：宁可显式列出每个 skill 的归属，也不依赖自动规则（v5 经验）

## 同步脚本用法

⚠️ **必须用 hermes venv 的 Python**，系统 Python 没有 yaml 模块：
```bash
cd ~/AppData/Local/hermes/skills_tree_v2
~/AppData/Local/hermes/hermes-agent/venv/Scripts/python sync_tree.py
```

### 跨大版本重构的标准流程（v5 经验沉淀）

1. **备份旧版**：`cp index.yaml index.yaml.bak.YYYYMMDD`
2. **设计新结构**：先用 ASCII 画完整棵树，确认每个分支/leaf 的归属
3. **写新 index.yaml**：用 write_file 直接覆盖，每层都加 description
4. **跑 sync 看 diff**：`python sync_tree.py` 输出会告诉你哪些 skill 找不到 leaf（`⚠ 新分支`）、哪些被自动删除（`➖`）
5. **补漏**：把找不到 leaf 的 skill 显式加到合适的位置
6. **去重**：grep -n "skill-name" 确认每个 skill 只出现一次
7. **数清楚**：用 yaml.safe_load 读 index.yaml，统计每个 leaf 的 skills 数，对照预期
8. **更新 SKILL.md 的版本号和结构图**：让未来的我和七十七能一眼看清现在是什么状态
9. **写一份 references/vX-redesign-notes.md**：把踩到的坑和设计判断都记下来

### 清理流程（定期维护用）

1. **扫空目录和断链**：`execute_code` 扫描 skills/ 找空目录、纯文件（断链）、无 SKILL.md 的子目录
2. **删断链文件**：`rm -f skill-name`（不是 `-rf`，因为它们是文件）
3. **删空子目录**：`rm -rf skill-dir/sub-dir`
4. **检查父目录是否空了**：`rmdir parent-dir`
5. **同步 index.yaml**：运行 `sync_tree.py`，脚本现在会自动删除 ghost entries

#### 已知空目录列表（截至 2026-05-30）

这些是已确认的空目录（只有 `DESCRIPTION.md`，没有实际技能文件）：
- `diagramming/` — 只有 DESCRIPTION.md，无 SKILL.md
- `domain/` — 同上
- `gifs/` — 同上
- `github/` — 同上（与 `github/` 分类别同名，注意：skills 顶层也有 github 分类目录）
- `inference-sh/` — 同上（v5 sync 时已自动删除）

注意：`github/` 分类目录（`skills/github/`）是空的，与 skills 列表中的 `github` category（github-pr-workflow、github-issues 等实际技能）是同名不同物。清理时应确认路径：`C:\Users\77\.hermes\skills\github\` 是空目录，`C:\Users\77\.hermes\skills\` 列表里的 `github` 是分类名，不是目录。

### scan_skills() 的正确实现（防踩坑）

⚠️ **不要用 `continue` 跳过父目录**。正确逻辑：

```python
def scan_skills():
    skills = set()
    for item in sorted(SKILLS_DIR.iterdir()):
        if not (item.is_dir() and not item.name.startswith('.')):
            continue
        # 顶层 skill（parent 有 SKILL.md）
        if (item / 'SKILL.md').exists():
            skills.add(item.name)
        # 检查子 skill（父有 SKILL.md 时子目录也要检查！）
        subs = [s for s in item.iterdir() if s.is_dir() and not s.name.startswith('.')]
        for sub in sorted(subs):
            if (sub / 'SKILL.md').exists():
                skills.add(f"{item.name}/{sub.name}")
    return skills
```

**错误模式**：父目录有 SKILL.md 时用 `continue` 会导致子 skill（如 `dogood` 下的 `adversarial-ux-test`）被跳过。

### Windows 断链识别

Linux symlink 在 Windows 上表现为"文件而非目录"，内容是原路径文本（如 `/home/ethanol/...`）。特征：
- `file skill-name` 输出 `ASCII text, with no line terminators`
- `ls -la` 显示为普通文件（非 `l` 开头）
- 处理：`rm -f` 删除即可

### 空的 references/scripts 子目录

Hermes 只加载有 SKILL.md 的 skill。空的 references/scripts 不会加载但占目录。清理时：
```bash
rm -rf skills/skill-dir/references skills/skill-dir/scripts
```

输出示例：
```
=== 技能树同步 ===
时间: 2026-05-30 03:17:31
  ➕ meta/skill-executor → meta/self_management
  ➖ find-skills-skill/references — 已从 skills/ 删除
✅ index.yaml 已更新 (共 359 个技能)
```

Cron 任务 `skill-tree-sync`（每 6 小时）已自动同步。

**新增：conversation_scout.py**（job_id: acbcc0861da1，每30分钟）— 扫描对话历史自动识别 skill 执行并写入日志，详见 `references/conversation-scout-patterns.md`。

## 手动更新分类

编辑 `sync_tree.py` 里的 `CATEGORY_MAP` 字典，添加新 skill 的分类规则。
**v5 建议**：跨大版本时不要写新规则，直接在 index.yaml 里把每个 skill 显式列到正确 leaf 下，简单粗暴但可控。

## GitHub 操作技巧

### 快速克隆新 repo

```bash
# --depth=1 只拉最新提交，速度快
git clone --depth=1 https://github.com/user/repo
```

### GitHub API 限速问题

匿名 API 每小时60次，clone 仓库不受限制。遇到 403 rate limit 时：
- 用 `git clone --depth=1` 替代 API 调用
- 不需要 README 内容时，直接 clone 后本地读文件
- `execute_code` 的 `urllib` 走代理，可能不受 rate limit

### 复制 repo ���容到 skills 目录

```bash
cp -r /tmp/repo-name/SKILL.md skills/dir/skill-name/
cp -r /tmp/repo-name/references/ skills/dir/skill-name/references/
mkdir -p skills/dir/skill-name/references/
```

## 已知 skill 分类（2026-06-03 更新）

v5 重构后，index.yaml 直接显式列了每个 skill 的归属（不再依赖 CATEGORY_MAP 推断），所以"已知分类"已经分散在 index.yaml 里。少量仍需要 CATEGORY_MAP 自动匹配的（如新增 skill 时）：

```python
# 子目录形式（dir/sub）
("bazi", "bazi-python"): ("domains", "academic"),
("bazi", "bazi-ziwei"): ("domains", "academic"),
("bazi", "mingli-bench"): ("domains", "academic"),
("meta", "skill-executor"): ("self", "identity"),

# 顶层形式
("skill-executor", None): ("self", "identity"),
```

### 命理技能来源

| Skill | 来源仓库 | 说明 |
|-------|---------|------|
| bazi-ziwei | jinchenma94/bazi-skill + Renhuai123/ziwei-doushu | 对话式命理分析，含八字经典+倪海夏紫微体系 |
| bazi-python | china-testing/bazi | Python 排盘库，含五行分数/冲合刑会 |
| mingli-bench | DestinyLinker/MingLi-Bench | LLM 命理评测基准，160道选择题 |

### conversation_scout.py 执行环境（重要坑）

⚠️ **cron job 里的 `python` 命令会失败**：PATH 里的 `python` 解析到 Hermes uv Python（3.11），该环境存在 SRE module mismatch，import re/json 时会炸：

## 执行环境

⚠️ **不能用 `python` 直接调用**：cron job 的 PATH 里 `python` 解析到 Hermes uv Python（3.11），存在 SRE module mismatch。

**✅ 正确方式 — 清除环境变量**（已验证，2026-06-01）：
```bash
env -u PYTHONHOME -u UV_INTERNAL__PYTHONHOME \
    "C:/Users/77/AppData/Local/Python/bin/python.exe" \
    C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py
```
根本原因是 cron job 继承了 `PYTHONHOME`+`UV_INTERNAL__PYTHONHOME` → 损坏的 uv Python 3.11（SRE mismatch）。清除这两条变量后任意干净 Python 都可用。

### Monica Skill Evolution 系统

skill evolution 系统在 `C:/Users/77/AppData/Local/hermes/skill_evolution/`：

```
skill_evolution/
├── __init__.py
├── logger.py          — log_skill_run() 记录执行轨迹，JSONL格式
├── optimizer.py        — analyze_failure_patterns() + generate_edit_suggestions()
├── evolution_cron.py   — 每小时定时分析脚本（cron job 调用）
├── skill_runner.py     — 命令行执行+记录工具（支持 --analyze）
├── skill_log.py        — 快速单行记录工具
├── conversation_scout.py — 对话历史扫描，自动识别skill执行
└── logs/
    ├── skill_runs.jsonl  — 执行日志
    └── suggestions/       — cron自动生成的分析报告
```

**快速记录命令**：
```bash
python C:/Users/77/AppData/Local/hermes/skill_evolution/skill_log.py \
    --skill bazi-ziwei --task "给77算命" --outcome success
```

**runner 工具**：
```bash
python C:/Users/77/AppData/Local/hermes/skill_evolution/skill_runner.py \
    --skill bazi-ziwei --task "算命" --outcome success \
    --trajectory '[{"step":1,"action":"排盘","result":"成功"}]' \
    --analyze
```

**自动分析**：cron job `skill-evolution-analyzer`（job_id 80a6fe2e56a2）每小时跑 evolution_cron.py，分析失败模式，生成建议写到 suggestions/。

**注意**：execute_code 的 Python 有 SRE module mismatch 问题，用 subprocess 调用 `sys.executable`（即 hermes venv 的 Python）执行。

### evolution_cron.py / conversation_scout.py 执行环境（重要坑）

⚠️ **cron job 里的 `python` 命令会失败**：PATH 里的 `python` 解析到 Hermes uv Python（3.11），该环境存在 SRE module mismatch，import re/json 时会炸：

```
AssertionError: SRE module mismatch
```

**✅ 正确方式 — execute_code 里 subprocess 调用 hermes venv Python**（已验证，2026-05-31）：

```python
import subprocess, sys
result = subprocess.run(
    [sys.executable,  # → hermes-agent/venv/Scripts/python.exe (3.11.15)
     r"C:\Users\77\AppData\Local\hermes\skill_evolution\evolution_cron.py"],
    capture_output=True, text=True, timeout=60
)
```

`sys.executable` 在 execute_code 里是 `hermes-agent/venv/Scripts/python.exe`（3.11.15），与 PATH 里的 uv Python 3.11 是不同路径，能正常 import json/re。**这是 cron job 里的最佳调用方式**。

**❌ 不推荐 — `.local/bin/python3.12.exe` 在 cron job 里实际会失败**（2026-05-31 实测）：
即使显式调用 `C:/Users/77/.local/bin/python3.12.exe`，在 Hermes cron job 环境里仍可能因 PATH/shell 解析问题走回 Hermes uv Python，导致 SRE mismatch。execute_code subprocess 方式更可靠。

**验证是否走对 Python**：
```python
import subprocess, sys
r = subprocess.run([sys.executable, "-c", "import json, re; print('ok')"],
                  capture_output=True, text=True)
print(r.stdout, r.stderr)
# 输出 "ok" 即正确，AssertionError 即走了 Hermes uv Python
```

**已知误检测（2026-05-30）**：`detect_skill_execution()` 的"skill short name"模糊匹配逻辑会把顶级目录名（`github`、`creative` 等）误报为 skill。这些目录是分类文件夹而非实际 skill，导致误写入 `skill_runs.jsonl`。需要修复方向：
1. 严格匹配：在扫描 skills 目录时，排除顶级目录本身（只看有 SKILL.md 的真实 skill）
2. 增加明确映射：`github` → 实际存在的相关 skill（如 `huggingface-hub`）
3. 过滤：检测结果若在 `get_known_skills()` 中不存在则丢弃

详见 `references/conversation-scout-patterns.md`。

### 命理参考文件

bazi-ziwei 内置参考文件（从原 bazi-skill 继承）：
- `references/classical-texts.md` — 九本经典典籍论命摘要
- `references/dayun-rules.md` — 大运顺逆/起运计算
- `references/shichen-table.md` — 时辰对照/五鼠遁元
- `references/wuxing-tables.md` — 五行/天干地支/十神/藏干表
- `references/ziwei-basics.md` — 紫微斗数倪海夏体系（自建）

## 分类规则参考

完整分支/叶子对照表见 `references/category-rules.md`。

## 进化追踪（可选）

如需追踪每个 skill 的使用历史，创建进化记录：

```bash
cd ~/AppData/Local/hermes/skills_tree_v2
python add_next_steps.py
python daily_tasks.py
```

## 目标状态
- [x] 树形结构定义
- [x] 迁移脚本
- [x] 进化记录系统
- [x] 下一步任务系统
- [x] 每日任务抽取
- [x] 自动同步脚本
- [x] 自动删除 ghost entries
- [x] 主体视角分类（v5）
- [x] 跨大版本重构标准流程（v5）
- [ ] 自动升级算法 (level 1→2→3...)
- [ ] 使用频率统计
- [ ] 生疏技能提醒
