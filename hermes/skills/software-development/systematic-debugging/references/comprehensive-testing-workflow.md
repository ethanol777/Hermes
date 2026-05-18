# 全面测试工作流（测试驱动发现）

`systematic-debugging` 的互补方法——在已知 bug 之外，通过系统性编写全面测试来 **主动发现隐藏问题**。

## 适用场景

- 接手一个已有代码但没有测试覆盖的项目
- 用户要求"全面测试修复"
- 发布/答辩前质量检查
- 核心模块重构前的基线测试

## 工作流

### 第一步：罗列测试范围

按依赖顺序列出所有需要测试的模块：

```
config → identity → emotion → core/* → memory/* → skills → channels → __main__
```

低层（无依赖）的先测，高层的后测。这样如果高层测试失败，你知道问题不在它的依赖里。

### 第二步：为每个模块写独立测试函数

```python
async def test_config():
    from myproject.config import load_config, Config
    cfg = Config()
    assert cfg.llm.provider == "openai"
    # ...

async def test_identity():
    # ...
```

每个测试函数：
- 自包含（创建自己的 fixture，不共享状态）
- 测试正常路径 + 边界条件 + 错误路径
- 使用 `check(name, condition, detail)` 辅助函数统一断言格式

### 第三步：使用一致的 check() 辅助函数

```python
passed = 0
failed = 0

def check(name, condition, detail=""):
    global passed, failed
    if condition:
        passed += 1
        print(f"  ✅ {name}")
    else:
        failed += 1
        print(f"  ❌ {name} — {detail}")
```

好处：
- 所有失败和成功的格式统一
- 全部测完才报最终结果（而不是在第一个 assert 停住）
- 自动统计通过率

### 第四步：按依赖顺序串行执行

```python
async def test_all():
    await test_config()       # 无依赖
    await test_identity()     # 无依赖
    await test_emotion()      # 无依赖
    await test_decision()     # 依赖 emotion 的接口类型
    await test_hot_layer()    # 无依赖
    await test_warm_layer()   # 无依赖（SQLite）
    # ...
```

先跑无依赖的基础模块。基础模块全通过后，集成测试才有意义。

### 第五步：测试非 LLM 路径优先

所有不调用 LLM 的功能应当先测，且被100%覆盖：

- 配置加载（含缺失/异常情况）
- 数据流（记忆读写、技能匹配、路由判断）
- 错误处理（文件缺失、API 异常、空输入）
- 边界条件（超过上限、格式异常）

**不要依赖 LLM 来测试正确性** —— LLM 输出有随机性。只在 LLM 测试中用 mock 或检测不崩溃。

### 第六步：测试真实外部依赖

对于 MCP 服务器、API 客户端等外部依赖，直接测试真实连接：

```python
client = await connect_to_mcp()
tools = client.list_tools()
assert len(tools) > 0  # 真实连接验证

result = await client.call_tool("get_forecast", {"city": "深圳", "days": 1})
assert "error" not in result["text"]  # 真实调用验证
```

但要做好环境不可用的准备（不存在的城市名、超时等）。

### 第七步：跑完全部再修

一轮测试跑完 → 收集所有失败 → 按依赖顺序修 → 再跑一轮确认。

不要修一个测一个——容易陷入"修好了 A 发现 B 又坏了"的循环。

## 输出格式

```
=== 📋 配置系统 ===
  ✅ 默认 LLM provider
  ✅ 缺失配置不崩溃

=== 😊 情绪系统 ===
  ✅ 初始情绪是 calm
  ❌ 难过→sad  — 关键词匹配有误

==================================================
📊 结果: ✅ 45 passed, ❌ 2 failed, 📈 95.7% 通过
==================================================
```

## 发现的问题类型（典型）

从实战中发现的典型 bug 类型：

| 类型 | 典型表现 | 发现方式 |
|------|---------|---------|
| None 崩溃 | `TypeError: unsupported operand` | 测试函数中设置 None 状态 |
| 关键词误匹配 | "好难过" 被识别为开心 | 测试混合情感输入 |
| 环境变量缺失 | 子进程连不上外网 | 测试真实 MCP 连接 |
| 路径编码问题 | 中文在 Windows pipe 乱码 | 测试中文输入/输出 |
| 状态残留 | 第二次调用行为不同 | 按序测试多次调用 |
| 资源泄漏 | close 后仍可操作 | 测试 close 后的行为 |
