# LLM API 兼容性笔记

## OpenCode Zen API

**端点：** `https://opencode.ai/zen/go/v1/chat/completions`

**认证：** Bearer token（从 `OPENCODE_GO_API_KEY` 环境变量）

**可用模型（2026-05-14）：**
| 模型 | 特点 |
|------|------|
| `glm-5.1` | 主力模型，中文原生，有推理链 |
| `deepseek-v4-flash` | 快速低成本 |
| `deepseek-v4-pro` | DeepSeek 高质量 |
| `kimi-k2.6` | Moonshot |
| `minimax-m2.7` | MiniMax |
| `mimo-v2.5-pro` | MiMo |
| `qwen3.6-plus` | 通义千问 |

**配置位置：** `~/.config/opencode/opencode.json`

## GLM-5.1 特别注意

### reasoning_content 字段

GLM-5.1 返回的响应格式不同于标准 OpenAI API：

```json
{
  "choices": [{
    "message": {
      "content": "最终回复内容",
      "reasoning_content": "思考过程..."
    },
    "finish_reason": "stop"
  }]
}
```

**关键问题：** `reasoning_content` 消耗 token。如果 `max_tokens` 太小：
- 所有 token 被 `reasoning_content` 占完
- `content` 返回空字符串 `""`
- `finish_reason` 为 `"length"`

**解决方案：**
1. 设 `max_tokens >= 1500`（推荐 1500-2000）
2. 代码必须处理 `content` 为空但 `reasoning_content` 有值的情况
3. 如果 `finish_reason == "length"` 且 `content` 为空，说明思考截断——跳过此次生成

```python
choice = data["choices"][0]
msg = choice["message"]
content = msg.get("content", "") or ""
reasoning = msg.get("reasoning_content", "") or ""
finish_reason = choice.get("finish_reason", "")

if not content.strip() and reasoning.strip():
    if finish_reason == "length":
        # 思考截断，跳过
        return None
    # 思考完成但没生成最终回复——用 reasoning 做降级
    return reasoning[:max_tokens]
```

### 本地 Hermes API Server（端口 8642）

`http://127.0.0.1:8642/v1/chat/completions` 是 Hermes 的本地代理。 **不要用这个作为 Monica Core 的 API！** 它代理的是 Hermes 当前配置的 provider（可能是没余额的 DeepSeek），而且会递归调用问题。

Monica Core 应该直接连 OpenCode Zen API：`https://opencode.ai/zen/go/v1`

## API 供应商历史

| 时间 | 供应商 | 状态 |
|------|--------|------|
| 2026-05-14 01:00 | DeepSeek API | ✅ 正常 |
| 2026-05-14 03:00 | DeepSeek API | ❌ 402 Insufficient Balance |
| 2026-05-14 03:30+ | OpenCode Zen (GLM-5.1) | ✅ 正常 |

**教训：** 不要硬编码单一 API 供应商。`Mind` 类的 `api_base` 和 `api_key` 应该从环境变量读取，支持运行时切换。