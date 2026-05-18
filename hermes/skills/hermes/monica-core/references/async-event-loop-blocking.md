# Async Event Loop Blocking — Diagnosis & Fix

## 问题现象

Python async 守护进程跑着多个协程（心跳、思考、Telegram 轮询），但只有部分协程在运行，其他的饿死（starvation）。典型症状：

- 心跳停止（heartbeat.log 不再追加）
- 日志只有启动记录，没有后续输出
- Telegram 能收到消息但无法回复
- 所有协程挂起，只有最外层的事件循环还在

## 根因

在 async 函数里直接调用同步阻塞的 `requests.get/post/put`。`requests` 库是同步的，它在等待网络 I/O 时会阻塞整个线程，不让事件循环调度其他协程。

```python
# ❌ 错误：同步 requests 在 async 函数里阻塞事件循环
async def get_updates(self):
    resp = requests.get("https://api.telegram.org/...", timeout=15)  # 阻塞！
    return resp.json()
```

## 诊断方法

1. **检查 heartbeat 日志** — 如果心跳间隔突然拉长或停止，说明事件循环被阻塞
2. **加详细日志** — 在每个协程的开始和结束打日志，看哪个协程饿死
3. **检查 timeout 配置** — 阻塞操作通常是因为长 timeout 的同步网络调用
4. **`asyncio.all_tasks()`** — 打印当前所有任务的状态，看哪些在 pending

```python
# 诊断 snippet
async def debug_tasks():
    for task in asyncio.all_tasks():
        print(f"Task: {task.get_name()}, done={task.done()}, "
              f"cancelled={task.cancelled()}, stack={task.get_stack()}")
```

## 修复方案

### 方案 A：asyncio.to_thread（推荐，零依赖）

把同步调用拆成 `_sync_*` 方法，用 `asyncio.to_thread` 包装：

```python
async def get_updates(self, timeout=10):
    return await asyncio.to_thread(self._sync_get_updates, timeout)

def _sync_get_updates(self, timeout):
    import requests
    resp = requests.get("https://api.telegram.org/...", timeout=timeout+5)
    return resp.json()
```

### 方案 B：httpx（需要安装 httpx）

把 `requests` 替换为 `httpx.AsyncClient`：

```python
import httpx
async def get_updates(self, timeout=10):
    async with httpx.AsyncClient(proxies=proxy) as client:
        resp = await client.get("...", timeout=timeout+5)
        return resp.json()
```

### 方案 C：aiohttp（需要安装 aiohttp）

```python
import aiohttp
async def get_updates(self, timeout=10):
    async with aiohttp.ClientSession() as session:
        async with session.get("...", timeout=aiohttp.ClientTimeout(timeout+5)) as resp:
            return await resp.json()
```

## 选择建议

| 方案 | 优点 | 缺点 |
|------|------|------|
| asyncio.to_thread | 零依赖，改动最小 | 有线程切换开销 |
| httpx | API 接近 requests | 需要额外安装 |
| aiohttp | 性能最好 | API 不同，需要重写 |

Monica Core 用方案 A（asyncio.to_thread），因为：
- 不需要额外装依赖
- 改动最小
- 对 Telegram 长轮询 (5-15s) 来说，线程开销可忽略

## 需要包装的调用点

所有同步网络 I/O 都必须在 `asyncio.to_thread` 里运行：

- `requests.get()` — Telegram poll, web scraping
- `requests.post()` — API calls, Telegram send message
- `time.sleep()` — 用 `asyncio.sleep()` 替代
- `subprocess.run()` — 用 `asyncio.create_subprocess_exec()` 或 `to_thread`

## 反例验证

如果怀疑事件循环阻塞，把其中一个协程的 await 换成简单的时间戳打印：

```python
async def _heartbeat_loop(self):
    while self._running:
        print(f"Heartbeat at {time.time()}", flush=True)  # 如果这行不打了 → 事件循环被阻塞
        await asyncio.sleep(60)
```
