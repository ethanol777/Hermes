# AI Agent 项目测试模式

## 测试架构

每个模块写独立测试，按依赖顺序执行：

```python
async def test_all():
    await test_config()       # 无依赖
    await test_identity()     # 依赖 config
    await test_emotion()      # 独立
    await test_decision()     # 依赖 skill manager
    await test_output_router() # 独立
    await test_hot_layer()    # 独立
    await test_warm_layer()   # 独立（用临时 SQLite）
    await test_cold_layer()   # 独立（用临时目录）
    await test_memory_system() # 集成测试
    await test_llm_client()   # 独立
    await test_skill_manager()# 独立
    await test_mcp_client()   # 需要真实 MCP 服务器
    await test_cli_channel()  # 无依赖
    await test_weather_server_direct() # 真实 API 调用
```

## 测试模式要点

### 配置测试
```python
# 验证默认值
cfg = Config()
assert cfg.llm.provider == "openai"

# 验证实际配置加载
cfg = load_config("config.yaml")
assert cfg.mcp.servers[0]["name"] == "weather"

# 验证缺失配置不崩溃
cfg = load_config("/nonexistent/path")
assert cfg.llm.provider == "openai"
```

### 温层测试（SQLite）
```python
# 使用临时数据库
import tempfile, os
tmp_db = tempfile.NamedTemporaryFile(suffix='.db', delete=False)
tmp_db.close()
os.unlink(tmp_db.name)  # 让 SQLite 创建新文件

warm = WarmLayer(db_path=tmp_db.name)
mid = await warm.add_memory("测试记忆", category="fact")
assert warm.count() == 1
warm.close()
os.unlink(tmp_db.name)
```

### 冷层测试（临时目录）
```python
import tempfile, shutil
tmp_dir = tempfile.mkdtemp()
cold = ColdLayer(archive_dir=tmp_dir)
diary = await cold.generate_diary("2026-05-18", [], "", [])
path = await cold.save_diary(diary)
assert Path(path).exists()
shutil.rmtree(tmp_dir)
```

### MCP 测试（真实连接）
```python
mcp = MCPManager()
config = load_config("config.yaml")
await mcp.connect_all(config.mcp.servers)
client = mcp.get_client("weather")
result = await client.call_tool("get_forecast", {"city": "深圳", "days": 1})
assert "error" not in result["text"].lower()
await mcp.disconnect_all()
```

### 测试计数与报告
```python
passed = 0
failed = 0
def check(name, condition, detail=""):
    if condition:
        passed += 1
        print(f"  ✅ {name}")
    else:
        failed += 1
        print(f"  ❌ {name} — {detail}")
```

## 最佳实践

1. **模块注入代替 mock 框架** — 通过构造函数参数注入依赖（如 `set_llm_client`）
2. **真实连接测试要有时效性** — 配置系统、MCP 连接、天气 API 等用真实环境
3. **边缘情况覆盖** — 空输入、缺失配置、不存在的实体、编码异常
4. **不影响生产数据** — 温层用临时 SQLite，冷层用临时目录
5. **不依赖特定时间** — 用 `datetime.now()` 时注意比较精度
6. **失败信息详细** — check 函数要输出具体值而非只有"失败"
