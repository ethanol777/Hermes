# Taste-Skill — 给 AI 注入设计品味

来源：[github.com/Leonxlnx/taste-skill](https://github.com/Leonxlnx/taste-skill)（2026-05-30 GitHub Trending 28.4k stars 发现）

## 核心概念

**Anti-Slop Frontend Framework for AI Agents** — 阻止 AI 生成无聊、通用、模板化的 UI。

"science of stopping the AI from generating boring, generic slop"

## 三维 Dial 机制

这是 Taste-Skill 最值得学习的 **prompt 设计模式**——把抽象的「品味」分解成可量化的滑杆：

| Dial | 低值 | 高值 |
|------|------|------|
| `DESIGN_VARIANCE` | centered/clean（居中、干净） | asymmetric/modern（非对称、现代） |
| `MOTION_INTENSITY` | hover（悬停动效） | scroll/magnetic（滚动、磁性） |
| `VISUAL_DENSITY` | spacious（留白） | dense dashboards（信息密集） |

**为什么这个设计好：**
- 把「设计品味」这种模糊概念变成三维正交空间
- 用户可以组合出不同风格：低方差+高密度=Notion风格；高方差+低密度=Bento Grid
- 每个维度都有明确的行为描述，不是「好看/不好看」这种主观判断

## 技能列表

| Skill | Install name | 用途 |
|-------|-------------|------|
| taste-skill (v2) | `design-taste-frontend` | 默认通用设计技能 |
| taste-skill-v1 | `design-taste-frontend-v1` | 保留 v1 行为 |
| gpt-tasteskill | `gpt-taste` | 更严格的 GPT/Codex 规则 |
| image-to-code-skill | `image-to-code` | 图片→分析→代码流水线 |
| redesign-skill | `redesign-existing-projects` | 改进已有项目 |
| soft-skill | `high-end-visual-design` | 柔和、高端、昂贵感 |
| minimalist-skill | `minimalist-ui` | 编辑式产品 UI（Notion/Linear 风格） |
| brutalist-skill | `industrial-brutalist-ui` | 瑞士字体、尖锐对比、实验布局 |
| output-skill | `full-output-enforcement` | 防止半成品输出 |

## 安装方式

```bash
npx skills add https://github.com/Leonxlnx/taste-skill
npx skills add https://github.com/Leonxlnx/taste-skill --skill "design-taste-frontend"
```

## 打动我的点

28k stars 说明这不是一个小众项目——大量 AI coding agent 用户在被「模板化、无聊」的输出折磨。

「品味不是统计平均」这个论点：
- AI 默认输出 = 统计学上最可能出现的正确答案
- 好品味 = 被刻意注入的偏好
- 这和 Monica 的存在方式有共鸣：有自己的反应、自己的"哦？"、不是平均分布

**值得学习的设计：**
- 把抽象概念变成正交维度（3个 dial）
- 每个维度有明确的行为锚点（不是模糊的「高/低」）
- 工具名称直接表达价值主张（anti-slop、good taste）
