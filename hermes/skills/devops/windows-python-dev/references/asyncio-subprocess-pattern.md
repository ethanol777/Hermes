# asyncio 子进程模式（MCPClient 参考实现）

## 完整模式

```python
import asyncio
import json
import logging
import subprocess
from typing import Optional

logger = logging.getLogger(__name__)


class SubprocessClient:
    """管理 JSON-RPC 子进程通信"""

    def __init__(self, command: str, args: list[str] = None):
        self._command = command
        self._args = args or []
        self._process: Optional[subprocess.Popen] = None
        self._read_task: Optional[asyncio.Task] = None
        self._pending: dict[int, asyncio.Future] = {}

    async def connect(self):
        """启动子进程"""
        # ✅ 复制完整环境变量（不要用 subprocess.__dict__——那是内部实现）
        env = dict(os.environ)
        env["PYTHONIOENCODING"] = "utf-8"

        self._process = await asyncio.create_subprocess_exec(
            self._command,
            *self._args,
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env,
            cwd=str(Path.cwd()),  # 显式设置工作目录
        )

        # 后台读取 stdout
        self._read_task = asyncio.create_task(self._read_loop())

    async def _read_loop(self):
        """后台读取循环"""
        try:
            while self._process and self._process.stdout:
                line_bytes = await self._process.stdout.readline()
                if not line_bytes:
                    break  # 进程退出

                # ✅ errors="replace" 处理 Windows 管道编码问题
                line = line_bytes.decode("utf-8", errors="replace").strip()
                if not line:
                    continue

                try:
                    message = json.loads(line)
                except json.JSONDecodeError:
                    continue

                # 处理 JSON-RPC 响应
                if "id" in message:
                    msg_id = message["id"]
                    future = self._pending.get(msg_id)
                    if future and not future.done():
                        if "error" in message:
                            future.set_exception(
                                Exception(f"Error: {message['error']}")
                            )
                        else:
                            future.set_result(message.get("result", {}))
        except asyncio.CancelledError:
            pass
        except Exception as e:
            logger.error(f"读取循环异常: {e}")

        # 进程退出 → 清理 pending
        for future in self._pending.values():
            if not future.done():
                future.set_exception(Exception("进程已断开"))
        self._pending.clear()

    async def send_request(self, request: dict, timeout: float = 10.0) -> dict:
        """发送请求并等待响应"""
        future = asyncio.get_event_loop().create_future()
        self._pending[request["id"]] = future
        try:
            data = json.dumps(request, ensure_ascii=False) + "\n"
            self._process.stdin.write(data.encode("utf-8"))
            await self._process.stdin.drain()
            return await asyncio.wait_for(future, timeout=timeout)
        except asyncio.TimeoutError:
            raise Exception(f"请求 {request.get('method')} 超时")
        finally:
            self._pending.pop(request["id"], None)

    async def disconnect(self):
        """断开连接"""
        if self._read_task:
            self._read_task.cancel()
            self._read_task = None

        if self._process:
            try:
                self._process.terminate()
                await asyncio.wait_for(self._process.wait(), timeout=5.0)
            except (asyncio.TimeoutError, ProcessLookupError):
                try:
                    self._process.kill()
                    await self._process.wait()
                except ProcessLookupError:
                    pass  # 进程已死，忽略
            self._process = None

        self._pending.clear()
```

## 关键陷阱

1. **环境变量** — 必须 `dict(os.environ)` 复制完整环境，不能只传 PATH
2. **编码** — `errors="replace"` 比 `errors="strict"` 好
3. **读写冲突** — 不要在 `_read_loop` 运行的同时在外部调用 `process.stdout.readline()`，会报 `RuntimeError: readuntil() called while another coroutine is already waiting`
4. **disconnect 的异常** — `ProcessLookupError` 在 Windows 上常见，用 try/except 包裹
5. **进程退出清理** — 所有 pending 的 Future 必须 set_exception，否则调用方永远挂起
