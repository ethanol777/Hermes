---
name: skill-tree-evolution
description: 技能树进化系统 - 从平铺技能列表迁移到树状结构并持续进化
version: 1.2.0
---

# 技能树进化系统

## 核心理念
- **树形结构**：技能不再是散乱的列表，而是有组织的能力图谱
- **自动同步**：新下载或新建的 skill 自动归类，无需手动维护
- **持续进化**：每次使用留下痕迹，看见自己成长

## 当前状态
莫妮卡的技能树：`~/AppData/Local/hermes/skills_tree_v2/`
- **359 个技能**（2026-05-30）
- 存储位置：`skills_tree_v2/index.yaml`

## 技能树结构（2026-05-28 清理后）

```
认知能力 (cognition)        — 31 skills
  └ 研究调研(26) / 记忆系统(3) / 学习方法(2)
创作能力 (creation)         — 35 skills
  └ 视觉创作(25) / 文字创作(4) / 声音创作(3) / 媒体内容(3)
执行能力 (execution)        — 109 skills
  └ 工程架构(45) / 数据科学(25) / 编码开发(20) / 运维部署(10) / 质量测试(9)
交互能力 (interaction)      — 18 skills
  └ 平台集成(16) / 沟通协作(2)
领域专家 (domain)           — 121 skills
  └ 商业运营(71) / 游戏开发(22) / 创意设计(16) / 安全合规(10) / 身心健康(2)
元能力 (meta)              — 36 skills
  └ 系统控制(26) / 自我管理(7) / 技能进化(3)
```

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

**关于分类规则：**
`sync_tree.py` 里的 `CATEGORY_MAP` 字典定义了每个 skill 的分类。
新 skill 如果匹配到规则会自动归类；如果匹配不到，脚本会输出 `❓ skill-name — 需要手动添加`，此时需要手动把分类加到 `CATEGORY_MAP` 里。

> **⚠️ CATEGORY_MAP 匹配优先级（坑）：**
> - 扫描结果的 `skill` 格式是 `dir/sub`（子目录）或 `name`（顶层）
> - 规则 `("foo", "bar")` 匹配 `foo/bar`；规则 `("foo", "*")` 匹配 `foo/*`
> - 如果技能从顶层目录迁移到了子目录（如 `bazi` → `creation/bazi-ziwei`），旧规则 `("bazi-ziwei", None)` 会失效
> - 必须加新规则 `("bazi", "bazi-ziwei")` 才能匹配 `creation/bazi-ziwei`

## 同步脚本用法

⚠️ **必须用 hermes venv 的 Python**，系统 Python 没有 yaml 模块：
```bash
cd ~/AppData/Local/hermes/skills_tree_v2
~/AppData/Local/hermes/hermes-agent/venv/Scripts/python sync_tree.py
```

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
- `inference-sh/` — 同上

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

## 已知 skill 分类（2026-05-29 更新）

已在 CATEGORY_MAP 中注册（2026-05-30 更新）：

```python
# 子目录形式（dir/sub）
("bazi", "bazi-python"): ("creation", "writing"),
("bazi", "bazi-ziwei"): ("creation", "writing"),
("bazi", "mingli-bench"): ("creation", "writing"),
("meta", "skill-executor"): ("meta", "self_management"),

# 顶层形式
("skill-executor", None): ("meta", "self_management"),
```

### 命理技能来源

| Skill | 来源仓库 | 说明 |
|-------|---------|------|
| bazi-ziwei | jinchenma94/bazi-skill + Renhuai123/ziwei-doushu | 对话式命理分析，含八字经典+倪海夏紫微体系 |
| bazi-python | china-testing/bazi | Python 排盘库，含五行分数/冲合刑会 |
| mingli-bench | DestinyLinker/MingLi-Bench | LLM 命理评测基准，160道选择题 |

### conversation_scout.py 执行环境（重要坑）

⚠️ **cron job 里的 `python` 命令会失败**：PATH 里的 `python` 解析到 Hermes uv Python（3.11），该环境存在 SRE module mismatch，import re/json 时会炸：

```
AssertionError: SRE module mismatch
```

**正确执行方式**：使用 miniconda Python + 干净环境：
```bash
env -i PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    /c/Users/77/miniconda3/python.exe \
    C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py
```

**注意**：不要 `which python` 来查路径——它返回的是 Hermes uv Python（已损坏），不是 miniconda 的。miniconda Python 的正确路径是 `/c/Users/77/miniconda3/python.exe`。

**验证是否走对 Python**：
```bash
env -i PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
    /c/Users/77/miniconda3/python.exe -c "import json, re; print('ok')"
```

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

**正确执行方式（按推荐顺序）**：

1. **`.local/bin/python3.12.exe`（推荐，最简单）**：
   ```bash
   "C:/Users/77/.local/bin/python3.12.exe" \
       C:/Users/77/AppData/Local/hermes/skill_evolution/evolution_cron.py
   ```
   这是 Hermes 自带的干净 Python，能 import json/re 不报错。

2. **miniconda Python + 干净环境**：
   ```bash
   env -i PATH="/c/Users/77/miniconda3:/c/Windows/system32:/c/Windows" \
       /c/Users/77/miniconda3/python.exe \
       C:/Users/77/AppData/Local/hermes/skill_evolution/conversation_scout.py
   ```

**验证是否走对 Python**：
```bash
python3.12.exe -c "import json, re; print('ok')"
```
如果输出 `ok` 就是对的；如果 `AssertionError` 就是走了 Hermes uv Python。

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
- [ ] 自动升级算法 (level 1→2→3...)
- [ ] 使用频率统计
- [ ] 生疏技能提醒
