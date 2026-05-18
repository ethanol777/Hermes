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

Telegram 的公开预览页是纯 HTML（非 SPA），帖子元素结构固定。用 `browser_console` 执行 JavaScript DOM 查询：

```javascript
// 一次性提取所有帖子的文本、时间、链接
let postData = [];
document.querySelectorAll('.tgme_widget_message_wrap').forEach((el,i) => {
  let t = el.querySelector('.tgme_widget_message_text');
  let d = el.querySelector('time');
  let links = Array.from(el.querySelectorAll('a'))
    .map(a => a.href)
    .filter(h => h.startsWith('http'));
  postData.push('=== POST ' + (i+1) + ' ===\n' +
    'Date: ' + (d?d.dateTime:'') + '\n' +
    'Text: ' + (t?t.innerText:'') + '\n' +
    'Links: ' + links.join(', ') + '\n');
});
postData.join('\n')
```

**为什么用 browser_console 而不是 browser_snapshot：**
- `browser_snapshot(full=true)` 对大页面截断（8000+ chars 时会截断）
- `browser_console` 的 JS 查询可以直接提取到全部内容

### 3. 快速预览（轻量版）

如果只需快速看标题和链接（不需要完整正文），用精简版：

```javascript
let texts = [];
document.querySelectorAll('.tgme_widget_message_wrap').forEach((el,i) => {
  let t = el.querySelector('.tgme_widget_message_text');
  let d = el.querySelector('time');
  texts.push(i+1 + '|' + (d?d.dateTime:'') + '|' + (t?t.innerText.substring(0,300):''));
});
texts.join('\n')
```

### 4. 内容评估

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

### 5. 保存结果

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

## Pitfalls

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
