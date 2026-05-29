# 命理类 GitHub 资源索引

> 通过 GitHub API 发现的高星命理相关仓库，适合作为 AI 算命 skill 的实现参考。

## 搜索方法

```python
import urllib.request, urllib.parse, json

q = urllib.parse.quote("bazi OR ziwei OR yijing")
url = f"https://api.github.com/search/repositories?q={q}&sort=stars&per_page=15"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
with urllib.request.urlopen(req, timeout=15) as resp:
    data = json.loads(resp.read())
```

> ⚠️ 注意：`urllib.request` 在 `execute_code` sandbox 中工作，但 `curl` 在 `terminal` 中因编码问题失败（`UnicodeEncodeError`）。搜索中文关键词优先使用 `execute_code`。

---

## 八字类

### jinchenma94/bazi-skill ⭐ 1588
- **描述**: 四柱八字命理分析
- **特点**: 本身就是 AI skill 格式（SKILL.md 结构），可直接参考其 prompt 设计方式
- **链接**: https://github.com/jinchenma94/bazi-skill

### china-testing/bazi ⭐ 1342
- **描述**: Python 八字排盘软件，清晰展示冲刑合会、阴阳关系，含合婚、风水等功能
- **特点**: 生产级 Python 实现，含倪海夏体系逻辑
- **链接**: https://github.com/china-testing/bazi

---

## 紫微斗数类

### Renhuai123/ziwei-doushu ⭐ 1196
- **描述**: 紫微斗数开源排盘引擎，基于倪海夏《天纪》体系
- **特点**: 完整排盘算法、四化系统、格局知识库、古籍原文数据
- **链接**: https://github.com/Renhuai123/ziwei-doushu

---

## 评测基准（LLM 能力评估用）

### DestinyLinker/MingLi-Bench ⭐ 1445
- **描述**: LLM 中文传统命理评测基准 — Bazi（八字）和 Ziwei Doushu（紫微斗数）
- **特点**: 可用于评估 AI 命理回答质量的标准数据集
- **链接**: https://github.com/DestinyLinker/MingLi-Bench

---

## 搜索关键词参考

| 类型 | GitHub 搜索关键词 |
|------|-----------------|
| 八字 | `bazi` |
| 紫微斗数 | `ziwei` |
| 易经/周易 | `yijing OR zhouyi` |
| 奇门遁甲 | `qimen` |
| 综合命理 | `fortune+telling` |

---

## 实现参考价值

| 仓库 | 可复用部分 |
|------|-----------|
| bazi-skill | Prompt 结构、命理分析流程 |
| china-testing/bazi | 算法逻辑、排盘细节 |
| ziwei-doushu | 格局判断、古籍知识库 |
| MingLi-Bench | 评测标准、答案质量评估 |
