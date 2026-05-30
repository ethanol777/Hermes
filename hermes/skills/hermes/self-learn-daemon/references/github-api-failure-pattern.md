# GitHub API 失败模式与 browser fallback（2026-05-30 实测）

## 本次事故记录

执行：
```bash
curl -s "https://api.github.com/search/repositories?q=created:>2026-05-25&sort=stars&order=desc" \
  -H "Accept: application/vnd.github.v3+json"
```
返回：`GitHub API failed`（工具执行失败，非 HTTP 错误）。

同时：
```bash
browser_navigate("https://github.com/trending")
```
✅ 成功返回完整 trending 仓库列表（Star 数、描述、Fork 数等全部可读）。

## 原因分析

GitHub Search API 对未认证请求有严格限频（60 req/h），且返回的错误可能是静默的（不一定是 403）。

## 教训

- GitHub API **不是**可靠的自动采集路径——限频静默，返回的 error 可能被 wrapper 工具吞掉显示为 "failed"
- **Browser navigation 到 GitHub Trending 页面是更可靠的采集方式**，且能拿到完整结构化数据（Star数、语言、Fork数）
- GitHub Trending 页面的 HTML 结构：`<article>` 标签内包含 `<h2>` 仓库名、`<p>` 描述、star/fork 链接。可以用 `browser_snapshot` 或 `browser_console` 提取

## 推荐采集模式

```
GitHub Trending 内容采集：
1. browser_navigate("https://github.com/trending")  ✅ 首选
2. 从 snapshot 中提取仓库名、Star 数、描述、Fork 数
3. GitHub Search API → 降级/备用（需要认证 token 才可靠）
```

## 相关 pitfalls

- `references/reliable-api-sources.md` 中记录了 GitHub Search API 的认证限频问题（60 req/h），但未记录"即使没超限也可能静默失败"的情况
- 本 reference 补充该细节
