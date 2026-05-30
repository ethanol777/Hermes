# GitHub Trending 数据提取

> **2026-05-30 更新：** `execute_code` 的 Python stdlib 在某些 session 中整体损坏（`re`、`json`、`encodings` 全部 import 失败）。因此 GitHub Trending 解析现在优先用纯 shell 路线。

## 方法 A：curl + grep（execute_code 损坏时使用）

```bash
# 1. 获取 trending 页面 HTML
curl -s 'https://github.com/trending' --max-time 15 \
  -H 'User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36' \
  > /tmp/gh_trending.html

# 2. 提取 repo 链接（href="/owner/repo" 格式，在 data-hydro-click JSON 属性中）
grep -oP '(?<=href="/)[^"/]+/[^"?]+(?=")' /tmp/gh_trending.html \
  | grep '/' | head -20

# 3. 提取 stars 数字（紧跟 stargazers 链接的标签）
grep -oP '(\d{1,3}(,\d{3})*)\s*(?=</a>\s*<svg class="octicon octicon-star")' /tmp/gh_trending.html \
  | head -20

# 4. 提取编程语言
grep -oP '(?<=programmingLanguage">)[^<]+' /tmp/gh_trending.html | head -20

# 5. 提取今日 stars
grep -oP '\d[\d,]*\s*(?=stars?\s+today)' /tmp/gh_trending.html -i | head -20
```

**限制：** grep -P 对 CJK/emoji 可能有 locale 问题（`grep: -P supports only unibyte and UTF-8 locales`）。描述文字提取困难，但 repo 名 + star 数已足够判断趋势方向。

## 方法 B：GitHub REST API（最可靠的结构化数据）

```bash
# 通过 GitHub API 获取 repo 元数据
curl -s 'https://api.github.com/repos/anthropics/claude-code' \
  -H 'Accept: application/vnd.github.v3+json'
```

返回 JSON 含 `full_name`、`stargazers_count`、`description`、`language`、`html_url`、`forks_count` 等字段。比 HTML 解析稳定得多。

**今日实测数据：**
- `anthropics/claude-code`: 127,870 stars, 20,910 forks
- `microsoft/markitdown`: 129,000+ stars（稳定 top 5）
- `twentyhq/twenty`: 48,000 stars
- `Leonxlnx/taste-skill`: 28,000 stars

## 方法 C：Python re + urllib（execute_code 正常时使用）

```python
import urllib.request, re, html

req = urllib.request.Request('https://github.com/trending',
    headers={'User-Agent': 'Mozilla/5.0'})
resp = urllib.request.urlopen(req, timeout=15)
text = resp.read().decode('utf-8')

articles = re.findall(
    r'<article[^>]*class=\"[^\"]*Box-row[^\"]*\"[^>]*>(.*?)</article>',
    text, re.DOTALL)

for art in articles[:10]:
    m = re.search(r'href=\"/([^\"]+)\"', art)
    path = m.group(1) if m else '?'

    m = re.search(r'<p[^>]*class=\"col-9[^\"]*color-fg-muted[^\"]*\"[^>]*>\s*(.*?)\s*</p>', art, re.DOTALL)
    desc = html.unescape(m.group(1).strip()) if m else ''
    desc = re.sub(r'<[^>]+>', '', desc).strip()

    m = re.search(r'<span[^>]*itemprop=\"programmingLanguage\"[^>]*>([^<]+)</span>', art)
    lang = m.group(1).strip() if m else ''

    m = re.search(r'<a[^>]*href=\"/([^\"]+/stargazers)\"[^>]*>.*?<svg.*?</svg>\s*([\d,]+)', art, re.DOTALL)
    total = m.group(2).replace(',', '') if m else ''

    m = re.search(r'([\d,]+)\s+stars?\s+today', art, re.IGNORECASE)
    today = m.group(1).replace(',', '') if m else '0'

    print(f'{path}: {desc[:80]}, {lang}, ★{total}, +{today}/d')
```

## 注意事项

- **Use Class Pattern Matching — not IDs**. Trending 页面 DOM 的 class 名经常含变体后缀（如 `h3 lh-condensed` 可能变成 `h3 lh-default`）。用 contain-matching 而非 exact match。
- **页面很大 (~650KB)** — curl + grep 比浏览器快。隐身警告弹窗是正常现象，不影响数据采集。
- **从 `article[class*=Box-row]` 匹配** — 这是每个仓库项的外层容器，class 名 `Box-row` 稳定。
- **Monorepo 项目** — 描述可能不含项目名。用 path 字段（owner/repo）作为唯一标识。
- **Language matches** — `span[itemprop=programmingLanguage]` 比 `span.d-inline-block` 更精确。
- **Known false-positive**: 第4个结果 item 的 name 字段可能匹配失败（因某些 h2 结构变体），fallback 用 `path.split('/')[-1]` 从 path 提取 repo 名。
- **curl locale 问题** — grep -P 对 CJK/emoji 可能有 locale 问题。描述文字提取困难时，用 repo 名 + star 数已足够判断趋势方向。
- **API rate limit** — GitHub API 未认证每小时 60 次请求限制。批量获取时加 `--max-time 15` 防止卡死。
- **Trending 页面 HTML 结构** — 2026-05-30 实测页面包含 `data-hydro-click` JSON 属性中的 repo href（格式如 `href=\"/harry0703/MoneyPrinterTurbo\"`），可以直接 grep 提取。

## 判断用哪个方法

```
execute_code Python 正常？ → 方法 C（Python 正则）
     │
     └─ 否
          │
          需要 repo 元数据（stars/forks）？ → 方法 B（GitHub REST API）
          │
          └─ 否
               │
               └→ 方法 A（curl + grep）
```
