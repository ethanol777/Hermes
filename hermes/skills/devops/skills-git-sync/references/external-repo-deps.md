# 外部独立 Git 仓库：Hermes 依赖关系分析

除 `~/Hermes/`（主备份仓库）外，`~/` 下还有多个独立 git 仓库。
以下是它们是否被 Hermes 运行时依赖的分析：

## 运行时正在使用

### mission-control
| 项目 | 说明 |
|------|------|
| **状态** | ✅ **正在运行** — tmux session `mc` 中跑着 `next-server` (v16.1.6)，自 5月2日 起持续运行 |
| **远程** | `https://github.com/builderz-labs/mission-control.git` |
| **本地修改** | 已删除 `.npmrc`（已被跟踪） |
| **恢复方式** | `git clone` + 拷贝 `.env` + `pnpm install && pnpm build && pnpm start` |
| **数据** | `.data/mission-control.db*`（运行时数据库，不在 git 中） |
| **是否需要进 Hermes 仓库** | ❌ 不需要。有自己的远程，回传脚本不重要。 |

## 技能已提取，运行时不依赖仓库本身

### Numerologist_skills
| 项目 | 说明 |
|------|------|
| **状态** | 🟡 其内容（bazi、ziwei-doushu、qimen-dunjia）已提取为 Hermes skill，存储在 `~/.hermes/skills/` 中，已通过主仓库备份 |
| **远程** | `https://github.com/FANzR-arch/Numerologist_skills.git` |
| **是否需要进 Hermes 仓库** | ❌ 不需要。技能本身已在备份中。 |

### npy-skill
| 项目 | 说明 |
|------|------|
| **状态** | 🟡 Hermes 有自己的 `npy` skill（`~/.hermes/skills/npy/`），已备份。此仓库是上游来源 |
| **远程** | `https://github.com/wwwttlll/npy-skill.git` |
| **是否需要进 Hermes 仓库** | ❌ 不需要。 |

## 未使用

| 仓库 | 说明 |
|------|------|
| **gbrain** (`garrytan/gbrain`) | ❌ `setup-gbrain` skill 存在但 gbrain 未安装（`gbrain` 不在 PATH） |
| **SkillClaw** (`AMAP-ML/SkillClaw`) | ❌ 工具已克隆但运行时不调用 |
| **agency-agents-zh** (`jnMetaCode/agency-agents-zh`) | ❌ 技能目录参考源，运行时不依赖 |

## 总结

所有独立仓库都有各自的 git remote，新机器上 `git clone` 即可恢复。
没有需要塞进 `~/Hermes/` 主仓库的。

唯一需要注意 **mission-control**，因为它有本地运行时数据（`.data/` 下的 SQLite 数据库 + `.env`），
换机器时除了 clone 还要：
1. 拷贝 `.env`（API 密钥/配置）
2. 重新 `pnpm install && pnpm build`
3. 启动 `tmux new-session -d -s mc pnpm start`
