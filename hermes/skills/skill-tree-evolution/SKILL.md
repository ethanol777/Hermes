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

## 手动更新分类

如果新 skill 匹配不到规则，编辑 `sync_tree.py`，在 `CATEGORY_MAP` 中添加：

```python
("skill-dir", "sub-skill-name"): ("branch", "leaf"),
# 或整目录匹配：
("skill-dir", "*"): ("branch", "leaf"),
```

然后重新运行 `sync_tree.py`。

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
