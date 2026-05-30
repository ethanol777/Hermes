# Node.js 作为 API 解析替代方案

**日期:** 2026-05-30
**背景:** `execute_code` 的 Hermes venv Python stdlib 损坏（`re`、`json`、`encodings` 全部 `AssertionError: SRE module mismatch`），GitHub Trending HTML 无法直接 curl+grep 解析出 repo 列表。

## 核心发现

Node.js (`node -e`) 可以完全替代 Python 做 JSON API 调用和解析：

```bash
# ✅ GitHub Trending 最近新建的高星项目
node -e "
fetch('https://api.github.com/search/repositories?q=created:>2026-05-25&sort=stars&order=desc&per_page=8').then(r=>r.json()).then(d=>{
  d.items.slice(0,10).forEach(r=>{
    console.log('★ '+r.full_name);
    console.log('  '+ (r.description||'').substring(0,100));
    console.log('  '+r.stargazers_count+' stars | '+r.language);
    console.log('');
  });
});
"

# ✅ HN Firebase API top stories
node -e "
fetch('https://hacker-news.firebaseio.com/v0/topstories.json').then(r=>r.json()).then(ids=>{
  return Promise.all(ids.slice(0,10).map(id=>
    fetch('https://hacker-news.firebaseio.com/v0/item/'+id+'.json').then(r=>r.json())
  ));
}).then(items=>{
  items.forEach(i=>{
    console.log('▸ '+i.title);
    console.log('  '+ (i.url||'').substring(0,80));
    console.log('');
  });
});
"

# ✅ B站排行榜
node -e "
fetch('https://api.bilibili.com/x/web-interface/ranking/v2?rid=0&type=all').then(r=>r.json()).then(d=>{
  if(d.data && d.data.list) {
    d.data.list.slice(0,8).forEach(v=>{
      console.log('▸ '+v.title+' | '+v.owner.name+' | '+v.stat.view+' views');
      console.log('  https://www.bilibili.com/video/'+v.bvid);
      console.log('');
    });
  }
});
"

# ✅ 提取网页正文（去掉 HTML 标签）
node -e "
fetch('https://example.com/article').then(r=>r.text()).then(html=>{
  const m = html.match(/<article[^>]*>([\s\S]*?)<\/article>/);
  let text = m ? m[1] : html;
  text = text.replace(/<[^>]+>/g,' ').replace(/&[a-z]+;/g,' ').replace(/\s+/g,' ').substring(0,3000);
  console.log(text);
});
"
```

## 优势

- `node` 是 git-bash 内置的，不依赖 conda/MSYS2 Python 环境
- `fetch` 是 Node 18+ 内置 API，无需额外安装
- JSON 解析原生支持（`r.json()` 直接返回 JS 对象）
- 字符串操作比 bash grep 更可靠（无正则歧义）

## 适用场景

当以下任一条件满足时，用 Node.js 替代 Python：
1. `execute_code` 的 `import json` / `import re` 失败
2. `terminal('python3 -c "..."')` 报 `ModuleNotFoundError: No module named 'encodings'`
3. 需要比 `grep -oP` 更可靠的 JSON 提取

## 与 Python 的分工

| 场景 | 工具 | 原因 |
|------|------|------|
| JSON API 调用 + 解析 | `node -e` | 内置 fetch + 原生 JSON，无环境依赖 |
| 纯文本 HTML 解析 | `terminal curl + grep` | 无需结构化解析 |
| 复杂文本处理/正则 | `node -e` | 比 grep -oP 更可靠 |
| 文件 I/O | `terminal cat >>` 或 `patch` | 不依赖 Python 环境 |

## 注意事项

- Node.js `fetch` 默认超时较长，API 不响应时等待较久
- `substring()` 是 JS 方法（不是 `substr()`），注意不要混用
- 中文内容在 console.log 输出时默认正常，URLencode 问题少见
