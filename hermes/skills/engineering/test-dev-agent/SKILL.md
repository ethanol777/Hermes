---
name: test-dev-agent
description: AI Agent 辅助测试开发 —— 自动生成测试、根因定位、智能回归、CI分析
---

# Test Dev Agent

测试开发 × AI Agent。结合 Hermes 已有工具链（terminal / cronjob / claude-code / codex / gstack-investigate），把 Agent 融入你的测试工作流。

## 使用场景

### 1. 自动生成单元测试
给一个模块 / 函数，Agent 自动生成 pytest 测试，覆盖正常路径、边界条件、异常场景。

```bash
# 给一个 Python 文件生成测试
# 在 Hermes 里加载本 skill 后说：
"为 src/utils/data_processor.py 生成 pytest 测试，覆盖正常输入、空输入、异常输入"
```

Agent 会：
- 读取源文件，分析函数签名、参数类型、返回值
- 生成 `test_data_processor.py`
- 跑一遍确认测试通过
- 输出覆盖率报告

### 2. CI 失败根因定位
CI 挂了 → Agent 自动查日志、定位失败测试、分析根因。

```bash
# 触发方式：
"CI 跑失败了，日志在 logs/ci-2026-05-18.log，帮我查根因"
```

Agent 会：
- 读 CI 日志，提取失败测试和错误信息
- 查对应的源文件和最近 diff
- 给出根因推断 + 修复建议
- 可选：生成修复代码

### 3. Flaky Test 检测
多次跑同一个测试，识别不稳定用例。

```bash
# 触发方式：
"帮我检查 test_api.py 是不是 flaky，跑 5 轮"
```

Agent 会：
- 用不同的随机种子多次执行指定测试
- 统计成功率
- 标记 flaky 的用例
- 输出稳定性报告

### 4. 智能回归测试
分析 commit diff，只跑受影响模块的测试，不跑全量。

```bash
# 触发方式：
"这次 commit 改了 user_service.py，帮我确定影响范围并跑对应的测试"
```

Agent 会：
- 读 Git diff
- 分析导入关系图（import chain）
- 确定受影响的测试文件
- 只跑这些测试
- 输出对比报告（这次 vs 上次）

### 5. 覆盖率分析与补测
分析当前覆盖率 → 找没覆盖到的分支 → 自动生成补测。

```bash
# 触发方式：
"分析 coverage.xml，找出没有被覆盖的分支，帮我把它们补上"
```

Agent 会：
- 读覆盖率报告（coverage.xml / htmlcov）
- 找到未覆盖的代码行和分支
- 生成补测用例
- 验证补测后覆盖率提升

## 原理说明

Hermes 已有能力直接复用：

| 需求 | 使用工具 |
|------|---------|
| 读源码 | `read_file` / `search_files` |
| 执行测试 | `terminal`（pytest） |
| 查 CI 日志 | `terminal`（grep / cat） |
| 分析 diff | `terminal`（git diff） |
| 生成测试代码 | `write_file` |
| 自动 debug | 加载 `investigate` skill |
| Git 工作流 | `terminal`（git） |
| 定时回归 | `cronjob` |

不需要额外安装——这套 skill 就是给你定义工作流。

## 示例工作流

### 完整流程：给一个模块写测试并验证

```
你：test-dev-agent 为 src/order/payment.py 生成测试
Agent 读 payment.py → 分析函数签名 → 生成 test_payment.py → 跑 pytest → 报覆盖率
你：覆盖率不到 80%，补一下边界条件
Agent 读 coverage 报告 → 找到没覆盖的 if-else → 补充测试用例 → 再跑 → 覆盖率到 90%
```

### 完整流程：CI 挂了查根因

```
你：test-dev-agent 查一下昨天 CI 为什么挂了
Agent 读 CI 日志 → 发现 test_order_refund 失败 → 查最近 commit → 发现价格计算改了精度 → 给出修复建议
你：修复吧
Agent 改源文件 → 跑测试验证 → 确认修复 → 输出 diff
```

## 注意事项

- 保证项目有 `pytest` 和 `coverage`（`pip install pytest coverage pytest-cov`）
- 生成测试后建议人工审查——Agent 可能遗漏业务上下文
- 大型项目（500+ 测试文件）建议指定模块，不要一次跑整个项目
- Flaky 检测每次跑 5-10 轮即可，太花时间
