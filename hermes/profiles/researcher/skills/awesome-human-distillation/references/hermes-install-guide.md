# Hermes 安装指南：从 Claude Code Skill 到 Hermes

本仓库列出的 skill 大多为 Claude Code 的 `npx skills` 系统设计，
但多数也兼容 Hermes 的 SKILL.md 格式。以下是已验证的安装流程。

## 标准安装流程

```bash
# 1. 克隆仓库
git clone https://github.com/{author}/{repo}.git ~/{repo}

# 2. 检查分支（有些在主分支，有些在 dot-skill 分支）
cd ~/{repo}
git branch -a  # 看看有没有 dot-skill 等分支
# 如果是 dot-skill 分支：git checkout dot-skill

# 3. 检查 SKILL.md 是否存在
ls SKILL.md

# 4. 创建 symlink 到 Hermes skills 目录
rm -f ~/.hermes/skills/{skill-name}
ln -s ~/{repo} ~/.hermes/skills/{skill-name}

# 5. 安装 Python 依赖（如有）
python3 -m pip install -r requirements.txt

# 6. 验证
# 用 skill_view(name) 检查是否可加载
```

## 已验证安装的案例

| 仓库 | 分支 | 依赖 | 状态 |
|------|------|------|------|
| `wwwttlll/npy-skill` | main | pypinyin | ✅ |
| `titanwings/colleague-skill` | dot-skill | - | ✅ (有 SKILL.md) |

## 常见问题

### 仓库使用非默认分支
部分仓库（如 colleague-skill）主分支不含 SKILL.md，SKILL.md 在 `dot-skill` 分支。
需要用 `git checkout dot-skill` 切换。

### 工具脚本不兼容
Claude Code 技能依赖的 tools（如 `wechat_decryptor.py`、`chat_parser.py`）引用了
`${CLAUDE_SKILL_DIR}` 环境变量。在 Hermes 中可能无法直接运行，
需手动指定脚本路径。

### 路径问题
有些 SKILL.md 内引用文件时写的是 `tools/xxx.py`（相对于项目根目录），
在 Hermes 中需要引用 `{skill_dir}/tools/xxx.py`。
