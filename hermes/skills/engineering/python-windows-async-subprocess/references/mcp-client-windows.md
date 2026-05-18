# MCP Client on Windows — 完整实现参考

来自 Star 项目的 MCP 客户端实现经验。这个客户端通过 JSON-RPC over stdio 管理 MCP 服务器的子进程生命周期。

## 架构

```
MCPManager (管理多个 MCPClient)
  └── MCPClient (管理一个子进程 + JSON-RPC 通信)
        ├── connect() → 启动子进程 → 初始化 → 发现工具
        ├── call_tool(name, args) → 发送请求 → 等待响应
        └── disconnect() → 终止进程 → 清理
```

## 关键实现决策

### 为什么不用 mcp Python SDK？

项目初期未安装 mcp 包（依赖最小化），所以实现了轻量协议兼容版。这在大幅减少依赖的同时也暴露了 Windows 编码问题——如果用 `mcp` SDK 的标准 `stdio_client`，它会自动处理编码。

### 为什么不用 Hermes 的 native-mcp？

Star 是独立项目，不依赖 Hermes 运行时。

### JSON-RPC 消息格式

客户端 → 服务器：
```json
{"jsonrpc": "2.0", "id": 1, "method": "initialize", "params": {...}}
{"jsonrpc": "2.0", "id": 2, "method": "tools/list", "params": {}}
{"jsonrpc": "2.0", "id": 3, "method": "tools/call", "params": {"name": "get_forecast", "arguments": {"city": "深圳"}}}
```

服务器 → 客户端：
```json
{"jsonrpc": "2.0", "id": 1, "result": {"protocolVersion": "2025-03-26", ...}}
{"jsonrpc": "2.0", "method": "notifications/initialized", "params": {}}  // 无 id = 通知
{"jsonrpc": "2.0", "id": 2, "result": {"tools": [...]}}
```

关键：服务器在 initialize 响应后**必须**发 `notifications/initialized` 通知，客户端要用 future 按 id 匹配响应，忽略通知。

### 工具调用结果解析

MCP 的 tool result 有 `content` 数组，每项可能是 text / image / resource：

```python
def _parse_tool_result(self, result: dict) -> dict:
    content = result.get("content", [])
    text_parts = []
    for item in content:
        if item.get("type") == "text":
            text_parts.append(item.get("text", ""))
        elif item.get("type") == "resource":
            text_parts.append(str(item.get("resource", "")))
    return {
        "raw": result,
        "text": "\n".join(text_parts),
        "is_error": result.get("isError", False),
    }
```

## 天气 MCP 服务器的特殊处理

### 中英文城市名对照

Open-Meteo Geocoding API 对中文城市名支持不稳定（有时返回 0 结果），因此手工维护了 50+ 中国城市的中英文对照表。查询时按顺序尝试：用户输入 → 中文→英文别名 → 英文→中文反向查找。

### 天气码 → 中文天气词

```python
CURRENT_CODES = {
    0: "晴天", 1: "大部晴朗", 2: "局部多云", 3: "多云",
    45: "雾", 48: "雾凇",
    51: "小毛毛雨", 53: "中毛毛雨", 55: "大毛毛雨",
    61: "小雨", 63: "中雨", 65: "大雨",
    95: "雷暴", 96: "雷暴加冰雹", 99: "雷暴加大冰雹",
    # ... 完整列表见 weather_server.py
}
```

### 服务器启动日志

MCP 服务器启动后先输出一行到 stderr（不干扰 stdout 的 JSON-RPC）：
```python
sys.stderr.write("Weather MCP server starting...\n")
sys.stderr.flush()
```

## 测试方法

```bash
# 直接测试 MCP 服务器（不经过客户端）
echo '{"jsonrpc":"2.0","id":1,"method":"initialize","params":...}' \
  | python -X utf8 star/skills/mcp_servers/weather_server.py

# 测试地理编码
curl -s "https://geocoding-api.open-meteo.com/v1/search?name=Shenzhen&count=3"
```
