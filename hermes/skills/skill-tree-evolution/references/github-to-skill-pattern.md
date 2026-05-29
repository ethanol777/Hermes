# GitHub 仓库 → Hermes Skill 模式

从 GitHub 仓库安装技能时的标准流程。

## 何时使用

找到一个有用的 GitHub 项目，想把它变成 Hermes skill 时使用。

## 标准流程

### 1. 判断仓库类型

| 类型 | 处理方式 |
|------|---------|
| 已有 SKILL.md | 直接 clone → 复制到 `skills/` |
| Python 库/工具 | 写 SKILL.md 描述用途，保留核心代码路径 |
| Web 应用 | 写 SKILL.md 描述用途，注明在线地址 |
| 评测基准/数据集 | 写 SKILL.md 描述用法 |
| 重型应用（Next.js/移动端） | 写 SKILL.md 做索引，不 clone 代码 |

### 2. GitHub API 限速

GitHub API 未认证请求 60次/小时。达到后：
- 改用 `git clone` 获取仓库内容
- `--depth=1` 减少下载量

```bash
git clone --depth=1 https://github.com/owner/repo
```

多个仓库并行 clone 时用 `&` 背景执行 + `wait`。

### 3. 分类

参考 `sync_tree.py` 里的 `CATEGORY_MAP`，找到合适的分支/叶子。
未匹配到规则 → 输出 `❓ skill-name — 需要手动添加`，然后手动添加到 `CATEGORY_MAP`。

### 4. 安装路径

- 单 skill：`skills/<category>/<skill-name>/`
- 有子技能：`skills/<category>/<skill-name>/<sub-skill>/`

## 本次新增

- `creation/bazi` → 重名，已合并入 `academic/bazi-fortune-analysis`
- `creation/bazi-python` → Python 排盘库（china-testing/bazi）
- `creation/ziwei-doushu` → 倪海夏紫���斗数排盘引擎
- `creation/mingli-bench` → 命理评测基准

## 快速检查清单

1. 仓库有没有现成 SKILL.md？
2. 是 Python 库 / Web 应用 / 评测工具 / 知识库中的哪一种？
3. 安装到哪个分类分支？
4. CATEGORY_MAP 是否需要更新？
5. 运行 `sync_tree.py` 同步 index.yaml
