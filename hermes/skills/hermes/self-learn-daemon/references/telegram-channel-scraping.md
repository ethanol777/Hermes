# Telegram 频道内容抓取模式

> 2026-05-19 实际验证：成功从 @goodlearnclub 抓取 20 条最新帖子的完整工作流。

## ⏱️ QUICK START：先做预检，别直接全量提取

**本文件很长，看这里就够了：**

```python
# 步骤 A：查看频道最新帖子时间
browser_navigate("https://t.me/s/CHANNEL_NAME")
browser_console("document.querySelector('time')?.getAttribute('datetime')")

# 步骤 B：查看 MEMORY.md 中该频道的最新记录
# 搜索该频道的来源标识（如 @channelname），拿到最近一条 auto-learned 的日期

# 步骤 C：比较
# 最新帖子时间 ≤ 已记录时间 → [SILENT]（跳过后面的所有工作）
# 最新帖子时间 > 已记录时间 → 继续读下文做全量提取

# 本 session（2026-05-20）实测：这一步省掉 7 次无意义工具调用
```

**这个预检在大多数情况下会直接 [SILENT]**（因为频道更新不频繁）。不要在没预检的情况下直接全量提取 20 条帖子。

---

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

### ⚠️ 2026-05-19 实践经验：优先用 `var` + `for` 循环，避免复杂 `.map()` 表达式

**`browser_console` 的 `expression` 参数在传输时被压成单行。** 多行 `.map()` 箭头函数体（`{ const ...; return ... }`）在传输时换行符丢失，触发 `SyntaxError: Unexpected end of input`。

**本 session 实际验证：以下模式每次成功。**

```javascript
// ✅ 可靠模式：var + for 循环 + JSON.stringify（本 session 实战验证）
var msgs = document.querySelectorAll('.tgme_widget_message_wrap');
var result = [];
for (var i = 0; i < msgs.length; i++) {
  var textEl = msgs[i].querySelector('.tgme_widget_message_text');
  var dateEl = msgs[i].querySelector('time');
  var linkEl = msgs[i].querySelector('a.tgme_widget_message_date');
  var text = textEl ? textEl.textContent.trim().substring(0, 300) : '';
  if (!text) continue;
  var link = linkEl ? linkEl.href : '';
  var date = dateEl ? dateEl.getAttribute('datetime') : '';
  result.push({i:i, t:text.substring(0,100), l:link, d:date});
}
JSON.stringify(result)
```

**为什么这个模式更可靠（单行 `.map()` 的对比）：**
- 箭头函数体中的 `{ const ... }` 块语句在单行化后丢失结构，报 SyntaxError
- `var` 声明在每次调用后都会覆盖前值（如果之前用 `let` 声明过同名变量，第二次调用会因 `Identifier already declared` 报错）
- `var` 不会触发重复声明错误——即使前一次会话用 `var` 声明了同名变量，再次调用用 `var` 声明会默默覆盖（var 的作用域提升行为）
- `JSON.stringify(result)` 在表达式末尾，browser_console 自动反序列化显示为结构化 JSON
- `.substring(0,100)` 控制单帖文本长度，避免输出过大

**代价：** 多了几行代码，但可靠得多。函数式简洁在 browser_console 的上下文里不值得。

**什么时候可以用 `.map()`：** 只在单行隐式 return 表达式中可用（无 `{ }` 块体）。

```javascript
// ✅ 单行 .map() 可以（无块体）
Array.from(document.querySelectorAll('.class')).map(el => el.textContent.trim())

// ❌ 多行 .map() 会挂（有块体）
Array.from(document.querySelectorAll('.class')).map(el => {
  const t = el.querySelector('.text');
  return t ? t.textContent.trim() : '';
})
```

### 🟢 效率模式：两阶段提取（先概要 → 再下钻）

**2026-05-19 实战验证：** 一次性提取所有 20 条帖子的完整正文（2-3K char 每条）不仅浪费时间，还会让 context 窗口爆满。更好的方式：

**阶段 1：提取概要（所有帖子，轻量级）**
```javascript
// 每个帖子只取前 100 个字符 + 链接 + 时间
var msgs = document.querySelectorAll('.tgme_widget_message_wrap');
var result = [];
for (var i = 0; i < msgs.length; i++) {
  var el = msgs[i];
  var text = el.querySelector('.tgme_widget_message_text');
  var link = el.querySelector('a.tgme_widget_message_date');
  var date = el.querySelector('time');
  result.push({
    i: i,
    t: (text ? text.textContent.trim().substring(0, 100) : ''),
    l: (link ? link.href : ''),
    d: (date ? date.getAttribute('datetime') : '')
  });
}
JSON.stringify(result)
```

**阶段 2：深度提取（仅相关帖子，按索引精准定位）**
```javascript
// 提取索引为 [3, 5, 10, 19] 等特定帖子的完整正文（最多 3000 字符）
var msgs = document.querySelectorAll('.tgme_widget_message_wrap');
var result = [];
var targets = [3, 5, 10, 19];  // ← 替换为你在阶段1发现的感兴趣索引
for (var i = 0; i < targets.length; i++) {
  var idx = targets[i];
  var el = msgs[idx];
  if (!el) continue;
  var text = el.querySelector('.tgme_widget_message_text');
  if (!text) continue;
  result.push({i: idx, full: text.textContent.trim().substring(0, 3000)});
}
JSON.stringify(result)
```

**为什么两阶段比一次性全量好：**
- 阶段 1 产出很小（20 条 × ~100 char = ~2K），可以轻松扫一眼判断哪些值得深读
- 阶段 2 只取需要的帖子，不污染 context
- 如果不确定好帖子 > 5 个，可以先试再选——不用一次性全量提取

### 推荐方式：返回 JSON 对象数组（browser_console 自动序列化）

如无特殊性能需求，可用以下简洁模式。注意：用 `function` 代替箭头函数避免单行限制。

```javascript
// 一次性提取所有帖子的文本、时间、链接、频道链接
Array.from(document.querySelectorAll('.tgme_widget_message_wrap')).slice(0,20).map(function(el,i) {
  var textEl = el.querySelector('.tgme_widget_message_text');
  var dateEl = el.querySelector('time');
  var linkEl = el.querySelector('.tgme_widget_message_date a');
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

### 🟢 效率优化：预检去重快捷方式（2026-05-19 新增）

**场景：** 多次 cron 检查同一个 Telegram 频道时，大多数情况下频道没有新帖或者新帖不相关。每次都提取 20 条帖子全文再做分析是浪费。

**推荐流程：先做预检，再做全量分析。**

```python
# 预检步骤（全量分析帖子之前做）
# 1. 快速获取最新帖子时间戳
browser_navigate("https://t.me/s/channelname")
# 2. 用一个轻量 console 查询只拿时间戳
browser_console("document.querySelector('time')?.getAttribute('datetime') || 'none'")
# 3. 读 MEMORY.md 该来源的最新记录时间
# 4. 比较：
#    - 最新帖子时间 ≤ 已处理时间 → 没有新内容 → [SILENT]
#    - 最新帖子时间 > 已处理时间 → 有未处理内容 → 做全量分析
```

**实际案例（2026-05-19）：**
- 频道最新帖子：`2026-05-17T11:59:16+00:00`
- MEMORY.md 中该来源已有 auto-learned 条目截至 2026-05-17 的内容
- 结论：没有未处理的新内容 → 无需提取/分析全部 20 条帖子 → [SILENT]

**和跨会话去重的区别：**
- 跨会话去重：**全量分析之后**，逐条对比是否已记录。浪费了分析 20 条帖子的开销。
- 预检快捷方式：**全量分析之前**，只看最新帖子的时间戳。如果最新帖已被处理，直接跳过全量分析。
- 建议：先做预检（轻量时间戳检查），再做跨会话去重（如果预检发现有新帖，则全量提取后逐条去重）。

**注意：** 预检只检查「是否有新帖子」，不检查「新帖子的内容是否有用」。如果最新帖子时间比上次处理时间新，仍需做全量分析来判别内容是否有价值。

**快速判断是否完全没新帖：**
```python
# 写法检查（2026-05-19 验证）：
browser_console("document.querySelector('time')?.getAttribute('datetime')")
# 返回类似 "2026-05-17T11:59:16+00:00"
# 如果这个值 ≤ 上次记录的日期 → 直接 [SILENT]
```

⚠️ **注意：** 这种轻量预检依赖 Telegram 公开预览页面的 DOM 结构稳定。如果页面内容因为 SPA 渲染模式变化导致 `document.querySelector('time')` 拿不到预期结果（比如只拿到 `<time>` 但无 `datetime` 属性），需要降级为全量分析（不做预检）。

### 🟡 跨会话去重（重要：避免重复处理同源内容）

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

### 🔴 2026-05-19 实测验证：`browser_console` JS 提取 Telegram 频道内容的简化模式

本 session 验证了一种比两阶段更简洁的全量提取方式。当上下文窗口充足时，可直接用全量提取：

```javascript
// 单行全量提取（2026-05-19 实战验证）：直接从 .tgme_widget_message_bubble 取正文
Array.from(document.querySelectorAll('.tgme_widget_message_bubble'))
  .map(el => el.textContent.trim()).join('\n=====\n')
```

**适用条件：** 帖子数 ≤ 20 且每条正文不超过 3K 字符。输出约 10-15K，在此范围内可一次性分析。

**何时用两阶段 vs 单次全量：**

| 情况 | 推荐模式 | 原因 |
|------|---------|------|
| 上下文充足（新会话初期） | 单次全量 | 快，一步到位 |
| 上下文紧张（会话中段） | 两阶段（先概要后下钻） | 节省 token |
| 帖子数 > 20 | 两阶段 + 分页 | 全量太大 |

**如果 `.tgme_widget_message_bubble` 拿不到内容（DOM 结构变化时的降级方案）：**

```javascript
// 降级方案：用 .tgme_widget_message_wrap + Set 去重
let unique_texts = [...new Set(Array.from(document.querySelectorAll('.tgme_widget_message_wrap'))
  .map(el => el.querySelector('.tgme_widget_message_text')?.textContent.trim() || ''))];
```

**注意事项：**
- 如果帖子是纯图片/视频（无文本），会被过滤为空字符串
- 如果某个帖子文本在频道中**恰好完全相同地出现两次**（如转发消息），也会被误去重——但这种情况罕见，对日常扫描影响可忽略
- 用 Set 保留插入顺序，与页面显示顺序一致

### 🔴 帖子数量限制（~20 条）
- t.me/s/ 预览只显示最近 ~20 条消息，不会更多
- 如果需要历史消息，需要走 Telegram API 或登录
- 作为「最新内容扫描」，20 条足够

### 🔴 browser 工具可能超时
- `t.me/`（无 /s/）首次加载可能超时（站外重定向/Cloudflare 防护）
- 遇到超时直接换 `t.me/s/` 重试
- 如果 `browser_navigate` 超时了，仍然可以尝试 `browser_console` 检查是否内容已经加载

### 🔴 browser_console JS 表达式必须是单行表达式，不能用多行语句块

`browser_console` 的 `expression` 参数在内部被当作单行 JS 表达式求值。多行箭头函数、语句块（`{ ... }`）、`let`/`const`/`var` 变量声明 + 多行 return 可能触发 `SyntaxError: Unexpected end of input`。

**失败模式（会报错）：**
```javascript
// ❌ 多行箭头函数体
Array.from(elements).map(el => {
  const t = el.querySelector('.text');
  return t ? t.textContent.trim() : '';
})
```

**正确写法（三种可选）：**
```javascript
// ✅ 方案A：单行箭头函数（隐式 return）
Array.from(elements).map(el => el.querySelector('.text')?.textContent.trim() || '')

// ✅ 方案B：单行 function 表达式
Array.from(elements).map(function(el){var t=el.querySelector('.text');return t?t.textContent.trim():''})

// ✅ 方案C：分步赋值（在单行内用逗号运算符或顺序赋值）
Array.from(elements).map(function(el,i){var t=el.querySelector('.text');var d=el.querySelector('time');return {idx:i,text:t?t.textContent.trim():'',date:d?d.getAttribute('datetime'):''}})
```

**为什么：** 工具内部将 expression 作为 `eval()` / `Function()` 的参数，多行文本在传输/解析过程中换行符被吃掉导致语法不完整。单行形式的表达式没有此问题。

**额外陷阱：浏览器执行上下文是持久化的。** 用 `let`/`const` 声明变量后，再次运行包含同名 `let`/`const` 声明的表达式会报 `SyntaxError: Identifier 'X' has already been declared`。因为前一次声明的变量仍然存在于页面作用域中。**如果需要在多次 browser_console 调用间传递数据，不要用 `let`/`const` 声明新变量，直接赋值给无声明前缀的变量（这会自动覆盖前值）。**

```javascript
// ❌ 第一次调用：
let posts = document.querySelectorAll('.class');  // 声明成功
// 第二次调用（同一 session）：
let posts = ...;  // SyntaxError: Identifier 'posts' has already been declared

// ✅ 正确做法：
// 第一次调用：用无声明前缀的赋值
posts = document.querySelectorAll('.class');  // 隐式全局，覆盖前值
// 第二次调用：
posts = document.querySelectorAll('.other');  // 正常。覆盖前值（无需 let/const）

// ✅ 或者每次都生成全新返回值不做赋值：
Array.from(document.querySelectorAll('.class')).map(...)  // 返回值直接输出
```

**检测方法：** 如果复杂表达式报错，先从简单断言开始（如 `.length`），逐步拼接到完整表达式，每次都在单行内完成。

**本 session 复现（2026-05-19）：**
```
✅ browser_console("document.querySelectorAll('.class').length") → 20
❌ browser_console("Array.from(document.querySelectorAll('.class')).map(el => { ... })") → SyntaxError
✅ 修正后: browser_console("Array.from(...).map(function(el){return ...})) → 成功
```

**另一种拆分策略：** 如果单行表达式太复杂难以维护，拆成多个 browser_console 调用：
1. 先拿原始数据量（count）
2. 再分批次拿每帖的摘要（slice 0-5，6-10，…）
3. 最后拿特定帖的完整内容（filter by index）

### 🔴 同内容不同标题：内容主题去重比标题去重更可靠

**场景（2026-05-19 实际发现）：** 同一个 Telegram 频道可能在几天内用**不同的标题/格式**发布**相同内容集合**。

**实际案例：**
- 前一 cron session 处理了一篇《GitHub Agent Frameworks》的帖子，包含了 openai-agents-python、google-adk-python、GenericAgent、evolver、agency-agents 共 5 个项目。
- 本 cron session 在频道中看到一篇《GitHub 被 Agent 千军万马来相见彻底惊呆》——标题完全不同，但涵盖了完全相同的 5 个项目。
- 如果只检查「标题是否匹配」，会误判这是新内容，实际是旧内容换了个标题。

**解决方案：用内容主题而非标题做去重。**

```python
# 跨会话去重时，检查的不只是「来源URL」，而是「话题指纹」
# 判断标准：
#   - ❌ 不同标题但覆盖相同 5 个项目 → 旧内容，跳过
#   - ❌ 不同标题但同一组工具/同一套概念 → 旧内容，跳过
#   - ✅ 出现至少 2 个全新项目/概念 → 新内容，处理
#
# 核心逻辑：如果新帖子和已有条目的关键项目重叠 ≥ 50%，判定为重复
# 用 set 交集判断即可
```

**这条 pitfall 的根本原因：** 该 Telegram 频道是「转载型」频道，同一个来源的同一组项目可能被不同的人用不同措辞投稿。用标题判断去重会漏掉很多重复。

**放宽去重策略：**
- 如果在 MEMORY.md 中搜索到同组的核心项目名（如 GenericAgent + evolver 一起出现），且新帖子也提到同样的组合 → 视为重复
- 不需要检查「来自同一条 URL」或「标题相同」——这些条件太严格
- 宁可误去重（错过一次新发布）也不重复记录——重复记录的代价是温层膨胀和未来检索噪声

### 🔴 页面可能含截断文本
- 长帖子在文本预览中有截断标识。如需完整内容：
  - 可以尝试提取帖子的 `data-post` 属性，构造 `t.me/channelname/POST_ID` 完整 URL 另外打开
  - 但公开预览通常已经显示完整帖子正文
