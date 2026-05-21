# Telegram 公共频道扫描笔记

适用场景：从 Telegram public preview /s/<channel> 中批量阅读最新帖子并筛选可学习内容。

## 可靠流程
1. 先打开 `https://t.me/s/<channel>`，不要只看频道根页；根页常只给 landing page。
2. 用页面 DOM 抽取帖子：
   - 帖子容器：`.tgme_widget_message_wrap`
   - 时间/链接：`a.tgme_widget_message_date`
   - 正文：`.tgme_widget_message_text`
3. `browser_console(document.body.innerText)` 适合先做快速 triage；需要结构化结果时再遍历 DOM。
4. 抓取后先和 `MEMORY.md` 现有链接去重，再决定是否追加冷层。

## 经验
- public preview 通常能直接看到最近 10–20 条帖子，足够做“今天有没有值得记的内容”判断。
- 如果正文很长，优先抽取：标题/链接/一句话理由/个人感受/是否值得分享给 77。
- 对同一频道的连续内容，避免重复写入冷层；只保留新增价值最高的条目。