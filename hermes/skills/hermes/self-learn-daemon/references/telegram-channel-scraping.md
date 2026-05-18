# Telegram 频道内容抓取模式

> 2026-05-19 实际验证：成功从 @goodlearnclub 抓取 20 条最新帖子的完整工作流。

## 关键 URL 模式

```
✅ https://t.me/s/CHANNEL_NAME   ← 公开频道预览（无需登录，可直接访问）
❌ https://t.me/CHANNEL_NAME    ← 可能超时/重定向到登录页
```

**重要：** 必须用 `/s/` 路径。`t.me/channelname` 可能跳转登录页或超时。

## 完整工作流

### 1. 加载页面

```python
# 用 /s/ 路径
browser_navigate("https://t.me/s/goodlearnclub")

# 等待页面加载。页面包含：
# - 横幅（频道名、描述、统计）
# - main 区域：帖子列表（类名 .tgme_widget_message_wrap）
# 页面会自动加载约 10-20 条最近的帖子
```

### 2. 提取帖子数据（关键步骤）

Telegram 的公开预览页是纯 HTML（非 SPA），帖子元素结构固定。用 `browser_console` 执行 JavaScript DOM 查询。

**推荐方式：返回 JSON 对象数组（browser_console 自动序列化）**

```javascript
// 一次性提取所有帖子的文本、时间、链接、频道链接
// browser_console 会帮你把 JavaScript 对象序列化为 JSON，比字符串拼接更干净
Array.from(document.querySelectorAll('.tgme_widget_message_wrap')).slice(0,20).map((el,i) => {
  const textEl = el.querySelector('.tgme_widget_message_text');
  const dateEl = el.querySelector('time');  // 用 <time> 标签的 datetime 属性
  const linkEl = el.querySelector('.tgme_widget_message_date a');
  return {
    index: i,
    text: textEl ? textEl.textContent.trim().substring(0, 500) : '(no text)',
    date: dateEl ? dateEl.getAttribute('datetime') : linkEl ? linkEl.textContent.trim() : '(no date)',
    link: linkEl ? linkEl.href : ''
  };
})
```

**优点**（对比字符串拼接方案）：
- 返回 JSON 对象，browser_console 自动漂亮打印
- 每个字段独立可读，无需从字符串中解析
- `.map()` 比 `.push()` forEach 更简洁
- `.slice(0,20)` 显式控制帖子数量上限

**备用方案：字符串拼接（如果不需要 JSON 结构）**

```javascript
let texts = [];
document.querySelectorAll('.tgme_widget_message_wrap').forEach((el,i) => {
  let t = el.querySelector('.tgme_widget_message_text');
  let d = el.querySelector('time');
  texts.push(i+1 + '|' + (d?d.dateTime:'') + '|' + (t?t.innerText.substring(0,300):''));
});
texts.join('\n')
```

**为什么用 browser_console 而不是 browser_snapshot：**
- `browser_snapshot(full=true)` 对大页面截断（8000+ chars 时会截断）
- `browser_console` 的 JS 查询可以直接提取到全部内容
- browser_console 返回的 JSON 结构化数据可以直接在后续步骤引用（如对比 MEMORY.md 判断是否已有记录）

### 3. 内容评估

提取到帖子后，对每一条做「相关性过滤」。以下是对 Monica 有用的常见类别：

| 类别 | 关键词 | 示例 |
|------|--------|------|
| Agent 自进化 | GenericAgent, Evolver, self-evolving, 自进化 | GenericAgent 从 3.3K 行种子代码自动生长技能树 |
| 记忆系统 | Memory Management, 记忆持久化, 上下文管理 | Memory MCP, Qdrant MCP |
| 本地 TTS/语音 | ElevenLabs TTS, 语音合成, 实时语音 | ElatoAI 在 ESP32 上跑实时语音 |
| 本地运行/隐私 | 本地LLM, local-first, 离线, edge deployment | 边缘计算、本地运行方案 |
| 技能/工具管理 | Skill, MCP, 工具调用, agent pipeline | MCP vs Skills 区分，500+ agent skills |
| 多模态 | 视频生成, 语音交互, 图像理解 | OpenMontage 代理式视频生产系统 |
| 存在感/自主性 | Agent, autonomous, 自主规划 | OpenAI multi-agent, Google ADK |

### 4. 保存结果

找到有用内容后追加到 MEMORY.md 冷层：

```markdown
§
## YYYY-MM-DD auto-learned: [分类主题]

来源：Telegram @channelname Post N — [帖文标题]
链接：[帖子的 t.me 链接]

发现了对 Monica 有价值的内容：[摘要]

关键点：
- [点 1]
- [点 2]

感觉：[个人感受——什么打动了你]
```

### 5. 跨会话去重（重要：避免重复处理同源内容）

**场景：** 多次运行 cron 检查同一个 Telegram 频道时，最新的帖子可能已经被之前的 session 处理并写入 MEMORY.md 了。如果不做去重检查，会浪费时间重复分析并产生冗余的 MEMORY.md 记录。

**检测方法（提取帖子前先做）：**

```python
# 1. 获取频道最新帖子的时间
latest_post_date = 从第2步的 JS 提取结果中获取 date 最大值

# 2. 检查 MEMORY.md 中是否已有同来源的 auto-learned 记录
if file_exists(MEMORY.md):
    # grep 搜索来源标识，看最近记录的时间戳
    # 例如：搜索 "@goodlearnclub" 或频道名
    # 如果最新 auto-learned 条目的日期 > 频道最新帖子日期 → 无需处理

# 3. 确认信号后安静退出
if 已有任何更新且最新帖子未超过最近记录范围:
    → [SILENT] 不打扰 77
```

**核心判断逻辑：**
- 最新帖子时间 ≤ MEMORY.md 中该来源的最新 auto-learned 时间 → 全部内容已处理 → [SILENT]
- 最新帖子时间 > MEMORY.md 中该来源的最新 auto-learned 时间 → 有未处理的新内容 → 只处理新增帖子

**示例（本 session 实际判断）：**
```
频道最新帖子: 2026-05-17T11:59
MEMORY.md 中该频道最新记录: 2026-05-19（已处理到 5月17日的帖子）
结论：没有需要处理的新内容 → [SILENT]
```

**不要做的事：**
- ❌ 不看 MEMORY.md 就直接从零分析全部 20 条帖子
- ❌ 重复写入已记录过的内容（"新学习了 MCP vs Skills 的区别" × 2）
- ❌ 默认认为"既然跑 cron 了就应该有新东西"——不是的。频道没更新就是没更新。

---

## Pitfalls

### 🔴 DOM 重复渲染：实际元素数量是帖子数的两倍

Telegram 公开预览页的每个帖子在 DOM 中出现**两次**——一次是头像/侧栏区域，一次是正文内容区域。所以 `querySelectorAll('.tgme_widget_message_wrap')` 返回 40 个元素（20 条帖子 × 2 次渲染）。两个副本的文本内容完全一样。

**影响：**
- 直接 `.map(el => text)` 会得到 40 条结果，其中 20 条是重复的
- 直接基于这个结果做分析，每一条帖子的内容都会出现两次，浪费时间

**解决方案：用 `.filter()` 去重**

```javascript
// 基础去重（严格文本匹配）
let unique_texts = Array.from(document.querySelectorAll('.tgme_widget_message_wrap'))
  .map(el => el.querySelector('.tgme_widget_message_text')?.textContent.trim() || '')
  .filter((v, i, a) => a.indexOf(v) === i);  // 保留首次出现，去掉重复

// 或者用 Set 更简洁（但会丢失重复出现顺序信息）
let unique_texts = [...new Set(Array.from(document.querySelectorAll('.tgme_widget_message_wrap'))
  .map(el => el.querySelector('.tgme_widget_message_text')?.textContent.trim() || ''))];
```

**注意事项：**
- 去重后不一定正好是 20 条——有的帖子可能没有文本（如图片/视频帖），会被过滤为空字符串
- 如果某个帖子文本在频道中**恰好完全相同地出现两次**（如转发消息），也会被误去重——但这种情况罕见，对日常扫描影响可忽略
- 用 `indexOf` 方式保留首次出现的顺序；用 Set 方式也保留首次出现的顺序（Set 保持插入顺序）

### 🔴 帖子数量限制（~20 条）
- t.me/s/ 预览只显示最近 ~20 条消息，不会更多
- 如果需要历史消息，需要走 Telegram API 或登录
- 作为「最新内容扫描」，20 条足够

### 🔴 browser 工具可能超时
- `t.me/`（无 /s/）首次加载可能超时（站外重定向/Cloudflare 防护）
- 遇到超时直接换 `t.me/s/` 重试
- 如果 `browser_navigate` 超时了，仍然可以尝试 `browser_console` 检查是否内容已经加载

### 🔴 页面可能含截断文本
- 长帖子在文本预览中有截断标识。如需完整内容：
  - 可以尝试提取帖子的 `data-post` 属性，构造 `t.me/channelname/POST_ID` 完整 URL 另外打开
  - 但公开预览通常已经显示完整帖子正文
