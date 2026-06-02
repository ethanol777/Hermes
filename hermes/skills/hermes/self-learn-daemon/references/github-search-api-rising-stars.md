# GitHub Search API "Rising Stars" 模式

**发现日期：** 2026-06-03

## 为什么这个模式值得专门一个 reference

GitHub Trending 是「老项目近期 star 爆发」（如 VoxCPM 持续上榜 1 个月）。GitHub Search API 配合 `created:>` 过滤 + `sort=stars&order=desc` 是「全新项目直接爆火」。

两个完全不同的信号源。**只用其中一个会漏掉一半。**

## API 端点

```
https://api.github.com/search/repositories?q=created:>YYYY-MM-DD&sort=stars&order=desc&per_page=15
```

**关键参数：**
- `created:>YYYY-MM-DD` — 创建日期过滤
- `sort=stars&order=desc` — 按总星数倒排（**不是**按 daily 新增 star）
- `per_page=15` — 一次拿 15 条（够用，不要拉更多浪费 token）

## 实战调用

```bash
curl -sL "https://api.github.com/search/repositories?q=created:>2026-04-01&sort=stars&order=desc&per_page=15" -o /tmp/gh.json

python3 -c "
import json
with open('/tmp/gh.json', 'r', encoding='utf-8') as f:
    d = json.load(f)
print(f'Total: {d.get(\"total_count\", 0)}, shown: {len(d.get(\"items\", []))}\\n')
for r in d.get('items', [])[:15]:
    print(f'{r[\"stargazers_count\"]:>6}★ | {r[\"full_name\"]}')
    print(f'        {r[\"description\"][:120] if r[\"description\"] else \"(no desc)\"}')
"
```

## 2026-06-03 实战发现

15 条结果里几乎全是「新范式」级别的项目：

| 项目 | star | 主题 |
|------|------|------|
| JuliusBrussee/caveman | 67,867★ | "用石头人说话省 65% token"的 Claude Code skill |
| safishamsi/graphify | 58,335★ | AI 编程助手的代码图谱技能 |
| nexu-io/open-design | 57,526★ | Claude Design 的本地开源替代 |
| MemPalace/mempalace | 53,312★ | "评测最高的开源 AI 记忆系统" |
| santifer/career-ops | 48,360★ | AI 求职系统，14 种 skill 模式 |
| alchaincyf/nuwa-skill | 22,385★ | 蒸馏"人的认知操作系统"（本轮最大发现） |
| garrytan/gbrain | 20,589★ | Garry Tan 的 OpenClaw/Hermes 脑 |
| esengine/DeepSeek-Reasonix | 16,636★ | DeepSeek-native AI coding agent |
| google-labs-code/design.md | 15,190★ | 给 coding agent 描述视觉身份的格式 |
| browser-use/browser-harness | 14,234★ | 自我修复的浏览器自动化层 |

**这 10 个里有 7 个是"agent 工具"或"agent memory"**——和 Trending 上同质化的"AI 应用"完全不同。

## 什么时候用

- ✅ 第一轮学习想找"现在最火的新项目"——用 Search API
- ✅ 想追"过去 N 天刚发布的范式级项目"——用 Search API
- ❌ 想看"老项目最近一周有没有 star 爆发"——用 Trending
- ❌ 想看"特定领域的项目排名"——用 Search API 但 `q=topic+language:python` 等具体查询

## 与 Trending 的关系

| 维度 | Trending | Search API |
|------|----------|------------|
| 时间范围 | 实时（按 daily stars 排序） | 任意过去 N 天（按 total stars 排序） |
| 信号类型 | 持续热度 | 突然爆火 |
| 适合发现 | 已经在路上的项目 | 刚发布就爆的项目 |
| 输出格式 | HTML（需要 grep 解析） | JSON（直接 Python 处理） |
| 频率限制 | 无 | 60 次/小时（未认证） |

**两个配合用：**
- Sweep 阶段先 Trending 拿延续性热点
- 紧接着 Search API 拿新范式涌现
- Deep Dive 阶段优先 Search API 找到的新项目（更可能是范式级）

## Pitfall

⚠️ `per_page` 太大（>30）会浪费 token 但不增加有效信息。前 15 条就够。如果第一页没有让你眼前一亮的东西，第二页大概率也是同质化的应用层项目——换 query。

⚠️ `created:>2026-04-01` 这种"过去 3 个月"过滤适合周节奏学习。如果是月度巡检，改成 `created:>YYYY-MM`。

⚠️ 未认证的 GitHub Search API 限速 60 次/小时。今天一轮学习只调用 1 次，完全够用。但不要在 loop 里频繁调用。

## 相关 reference

- [github-trending-parsing.md](github-trending-parsing.md) — 传统的 Trending HTML 解析
- [reliable-api-sources.md](reliable-api-sources.md) — 已验证的可靠数据 API 列表
