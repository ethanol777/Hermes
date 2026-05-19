# Edge-TTS 网络错误处理

## 问题描述
edge-tts 依赖连接 Microsoft Azure 的边缘 TTS 服务。在网络不稳定或连接异常时，会抛出以下错误：

```
aiohttp.client_exceptions.ClientConnectorError: 
Cannot connect to host speech.platform.bing.com:443
[WinError 64] 指定的网络名不再可用
```

## 解决方案

### 方案 1: 重试机制
```python
import asyncio
import edge_tts
from tenacity import retry, stop_after_attempt, wait_exponential

@retry(stop=stop_after_attempt(3), wait=wait_exponential(multiplier=1, min=4, max=10))
async def generate_with_retry(text, voice, output_path):
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(output_path)
    return output_path
```

### 方案 2: 降级回退
当语音生成失败时：
1. 不要阻止任务流程
2. 使用文字版本完成交付
3. 记录失败原因到日志
4. 向用户说明："网络不通，先用文字版本"

### 方案 3: 本地备选方案
若经常遇到网络问题，可考虑：
- **pyttsx3**: 完全本地，但声音质量低
- **Supertonic 3**: 需要下载 ONNX 模型
- **GPT-SoVITS**: 需要训练数据

## 实战中的处理流程

```python
async def speak_with_fallback(text: str, output_path: str) -> Optional[str]:
    try:
        communicate = edge_tts.Communicate(text, VOICE)
        await communicate.save(output_path)
        return output_path
    except Exception as e:
        logger.warning(f"TTS 失败: {e}")
        return None

# 使用
voice_path = await speak_with_fallback(text, output_path)
if voice_path:
    send_voice(voice_path)
else:
    send_text(text)  # 降级到文字
```
