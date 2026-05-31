# Shellspace — Live Demo 优先发现模式

## 本轮发现（2026-05-31）

**项目：** I-found-a-seashell-in-the-middle-of-the-desert (github.com/hawzen)
**标题：** 在沙特沙漠里捡到一块贝壳，然后用机器学习追溯它 1.5 亿年前的身份
**Live Demo:** https://shell.hawzen.me — Shellspace，交互式贝壳形态空间可视化

## 关键洞察

当 GitHub README 提到独立域名（如 `shell.hawzen.me`）或 `Live:`/`Demo:` 关键词时，**优先访问 demo** 而不是继续读 README。

**原因：**
- demo 传达核心价值比 README 更快——你 10 秒内就知道它在做什么
- README 可能是 3000 字的长文，但 demo 可能是 3 秒的动画
- 有些 demo 是 README 里描述的"那件事"的完美视觉呈现

**识别方式：**
- 独立域名（`*.me`, `*.io`, `*.app` 等）
- README 中的 `Live Demo:` / `Demo:` / `Try it:` 行
- README 中指向独立托管演示的 URL

**实际效果：**
- Shellspace 案例：README 很长，写了实验过程和趋同进化的讨论。但 demo（shell.hawzen.me）10 秒内就传达了核心价值：一个可以旋转、缩放、搜索贝壳形态的 3D 空间。"沙漠里的贝壳"这个隐喻也是在 demo 页面上产生了情感共鸣。
- 如果只读 README 而不去 demo，这轮可能就不会被"打动"。

## 对应的 skill 记录

已更新 SKILL.md 的 GitHub Trending 采集 pitfall，加入：
```
- **🆕 发现信号：live demo** — 2026-05-31 实测：部分项目在 README 中提供独立域名线上演示（如 `shell.hawzen.me`）。发现这类链接时优先访问 demo，比 README 更快传达核心价值。识别方式：搜索 `Demo:`/`Live:` 关键词或独立域名 URL。
```
