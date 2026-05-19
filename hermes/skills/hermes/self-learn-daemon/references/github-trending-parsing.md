# GitHub Trending 数据提取

## 可靠的方法：Python re + urllib

GitHub Trending 页面是服务端渲染的 HTML，无需登录即可访问。推荐直接用 Python 正则解析。

```python
import urllib.request, re, html

req = urllib.request.Request('https://github.com/trending',
    headers={'User-Agent': 'Mozilla/5.0'})
resp = urllib.request.urlopen(req, timeout=15)
text = resp.read().decode('utf-8')

articles = re.findall(
    r'<article[^>]*class=\"[^\"]*Box-row[^\"]*\"[^>]*>(.*?)</article>',
    text, re.DOTALL)

for art in articles:
    # repo name + owner
    m = re.search(
        r'<h2[^>]*class=\"[^\"]*h3[^\"]*lh-condensed[^\"]*\"[^>]*>'
        r'.*?<a[^>]*href=\"/([^\"]+)\"[^>]*>\s*([^<]+?)\s*</a>',
        art, re.DOTALL)
    path = m.group(1) if m else '?'
    name = m.group(2).strip() if m else '?'

    # description (col-9 + color-fg-muted)
    m = re.search(
        r'<p[^>]*class=\"col-9[^\"]*color-fg-muted[^\"]*\"[^>]*>'
        r'\s*(.*?)\s*</p>', art, re.DOTALL)
    desc = html.unescape(m.group(1).strip()) if m else ''
    desc = re.sub(r'<[^>]+>', '', desc).strip()

    # programming language
    m = re.search(
        r'<span[^>]*itemprop=\"programmingLanguage\"[^>]*>([^<]+)</span>',
        art)
    lang = m.group(1).strip() if m else ''

    # total stars (svg + number)
    m = re.search(
        r'<a[^>]*href=\"/([^\"]+/stargazers)\"[^>]*>'
        r'.*?<svg.*?</svg>\s*([\d,]+)',
        art, re.DOTALL)
    total = m.group(2).replace(',', '') if m else ''

    # today's stars
    m = re.search(r'([\d,]+)\s+stars?\s+today', art, re.IGNORECASE)
    today = m.group(1).replace(',', '') if m else '0'

    print(f'{name}: {desc[:80]}, {lang}, ★{total}, +{today}/d')
```

## 输出字段说明

| 字段 | 提取方法 | 备注 |
|------|---------|------|
| path | h2 > a 的 href 属性 | `owner/repo` 格式 |
| name | h2 > a 的文本内容 | 去除了首尾空白 |
| description | p.col-9.color-fg-muted | 需 html.unescape 处理 &amp; 等实体 |
| language | span[itemprop=programmingLanguage] | 可能为空（无语言的项目） |
| total_stars | stargazers 链接后的数字 | 去掉了千分位逗号 |
| today_stars | "N stars today" 文本 | 大小写不敏感，去掉了千分位逗号 |

## 注意事项

- **Use Class Pattern Matching — not IDs**. Trending 页面 DOM 的 class 名经常含变体后缀（如 `h3 lh-condensed` 可能变成 `h3 lh-default`）。用 contain-matching 而非 exact match。
- **页面很大 (~650KB)** — curl + Python 解析比浏览器快。浏览器加载 Trending 还可能有隐身警告弹窗。
- **从 `article[class*=Box-row]` 匹配** — 这是每个仓库项的外层容器，class 名 `Box-row` 稳定。
- **Monorepo 项目** — 描述可能不含项目名。用 path 字段（owner/repo）作为唯一标识。
- **Language matches** — `span[itemprop=programmingLanguage]` 比 `span.d-inline-block` 更精确，后者可能匹配到 stars today 等其他 span。
- **Known false-positive**: 第4个结果 item 的 name 字段可能匹配失败（因某些 h2 结构变体），fallback 用 `path.split('/')[-1]` 从 path 提取 repo 名。
- **Always use urllib with User-Agent header** — curl + shell pipe 在 git-bash/MSYS 环境下可能因 locale 问题导致 grep -P 失败（`grep: -P supports only unibyte and UTF-8 locales`）。
