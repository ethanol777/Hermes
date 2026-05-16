# HN Comment Pages — curl + Python HTML 解析模式

## 问题

Hacker News 的评论/文章详情页（`news.ycombinator.com/item?id=X`）在 `browser_navigate` 中可能返回空页面（2026-05-14 实测：3 个不同 item ID 全部为空）。这不是页面不存在，是无头浏览器的内容遮蔽。

## 解决方案：curl + Python HTML 解析

```bash
# 取评论页 HTML，用 python 正则/HTML 解析提取内容
curl -sL "https://news.ycombinator.com/item?id=41362068" | python3 -c "
import sys, re, html
data = sys.stdin.read()

# 找故事标题
title_match = re.search(r'class=\"[^\"]*titleline[^\"]*\"[^>]*>\s*<a[^>]*>(.*?)</a>', data, re.DOTALL)
if title_match:
    print('Story:', html.unescape(re.sub(r'<[^>]+>', '', title_match.group(1))))

# 找评论内容
comment_matches = re.findall(r'class=\"[^\"]*commtext[^\"]*\"[^>]*>(.*?)</span>', data, re.DOTALL)
for i, c in enumerate(comment_matches[:5]):
    text = html.unescape(re.sub(r'<[^>]+>', '', c))
    print(f'Comment {i+1}:', text[:300])
"
```

## 从首页取故事标题和链接的另一种方法

```bash
curl -sL "https://news.ycombinator.com/front" | python3 -c "
import sys, re, html
data = sys.stdin.read()
stories = re.findall(r'class=\"[^\"]*titleline[^\"]*\"[^>]*>\s*<a[^>]*href=\"([^\"]+)\"[^>]*>(.*?)</a>', data, re.DOTALL)
for i, (url, title) in enumerate(stories[:10]):
    title = html.unescape(re.sub(r'<[^>]+>', '', title))
    print(f'{i+1}. {title}')
    print(f'   URL: {url}')
"
```

## 注意事项

- 这个模式只适合**文本提取**——只做分析用，不做交互
- 正则匹配有脆弱性：HN 页面结构比较稳定（20 年没大变），但未来可能改版
- 如果内容量小，也可以直接 `browser_snapshot` → python 脚本处理页面快照内容
- 对于 HN 这种轻量级页面，curl + python 比完整的浏览器渲染快得多
- 不适合需要 JS 渲染的页面（如 SPA 站点）
