# 知乎热榜 API 探测与回退

## 现象
- 端点：`https://www.zhihu.com/api/v3/feed/topstory/hot-lists/total?limit=8`
- 可能出现：`{"error":{"code":101,"name":"AuthenticationError","message":"身份未经过验证"}}`

## 处理策略
1. 先做一次匿名 `curl` 探测。
2. 如果返回热榜 JSON，就直接抽取标题。
3. 如果返回认证错误，不要继续在知乎端点上硬耗；立刻切换到 HN / GitHub Trending / B站等可直读源。

## 价值
- 防止学习轮卡死在单一源上。
- 把“来源可达性”放在“话题重要性”之前。
- 适合 cron 学习：先拿能读的，再补高价值来源。
