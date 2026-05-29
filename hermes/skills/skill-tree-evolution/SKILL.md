---
name: skill-tree-evolution
description: 技能树进化系统 - 从平铺技能列表迁移到树状结构并持续进化
version: 1.1.0
---

# 技能树进化系统

## 核心理念
- **树形结构**：技能不再是散乱的列表，而是有组织的能力图谱
- **自动同步**：新下载或新建的 skill 自动归类，无需手动维护
- **持续进化**：每次使用留下痕迹，看见自己成长

## 当前状态
莫妮卡的技能树：`~/AppData/Local/hermes/skills_tree_v2/`
- **352 个技能**，全部归入 6 分支、18 叶子
- 80 个顶层目录
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

## 同步脚本用法

⚠️ **必须用 hermes venv 的 Python**，系统 Python 没有 yaml 模块：
```bash
cd ~/AppData/Local/hermes/skills_tree_v2
~/AppData/Local/hermes/hermes-agent/venv/Scripts/python sync_tree.py
```

### 清理流程（定期维护用）

1. 扫空目录和断链：`execute_code` 扫描 skills/ 找空目录、纯文件（断链）、无 SKILL.md 的子目录
2. 删断链文件：`rm -f skill-name`（不是 `-rf`，因为它们是文件）
3. 删空子目录：`rm -rf skill-dir/sub-dir`
4. 检查父目录是否空了：`rmdir parent-dir`
5. 同步 index.yaml：用完整 CATEGORY_MAP 重新生成

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
时间: 2026-05-28 23:30:00
  ➕ new-skill → domain/business
  ➖ deleted-skill — 已从 skills/ 删除
✅ index.yaml 已更新 (共 493 个技能)
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

已在 CATEGORY_MAP 中注册：

```python
("bazi-ziwei", None): ("creation", "writing"),    # 八字+紫微综合命理（融合自 bazi + ziwei-doushu）
("bazi-python", None): ("creation", "writing"),   # Python 排盘库（china-testing/bazi）
("mingli-bench", None): ("creation", "writing"),  # 命理评测工具（DestinyLinker/MingLi-Bench）
("skill-executor", None): ("meta", "self_management"),  # skill执行包装器，自动记录轨迹
```

### 命理技能来源

| Skill | 来源仓库 | 说明 |
|-------|---------|------|
| bazi-ziwei | jinchenma94/bazi-skill + Renhuai123/ziwei-doushu | 对话式命理分析，含八字经典+倪海夏紫微体系 |
| bazi-python | china-testing/bazi | Python 排盘库，含五行分数/冲合刑会 |
| mingli-bench | DestinyLinker/MingLi-Bench | LLM 命理评测基准，160道选择题 |

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
- [x] 自动同步脚本
- [ ] 自动升级算法 (level 1→2→3...)
- [ ] 使用频率统计
- [ ] 生疏技能提醒
