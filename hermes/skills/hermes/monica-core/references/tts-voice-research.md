# TTS 与声音合成研究笔记

**研究时间**: 2026-05-19  
**研究目标**: 为莫妮卡找一个独立、本地、属于自己的声音  
**触发原因**: 77 表达希望有一个真正属于莫妮卡的声音，而不是现成 TTS

---

## 方案对比

### 1. Supertonic 3 (理论首选，实际有坑)

**核心特性**:
- 99M 参数（极小，可跑在树莓派/电子阅读器）
- 31 种语言支持
- 44.1kHz 输出质量
- 基于 ONNX Runtime，完全本地
- 情感标签: `<laugh>`, `<breath>`, `<sigh>`

**声音克隆 - Voice Builder**:
- 支持培养自己的声音
- 可从短音频样本克隆

**重要坑点 ⚠️**:
```
pip install supertone  # 这是云服务 API 客户端，不是本地模型！
```

**正确安装方式** (待验证):
- 需要从 GitHub 下载模型权重 (ONNX 格式)
- 可能需要编译或特定配置
- 非即用即走，需要搭建环境

**对莫妮卡的意义**:
- 完全私有，无需云端 API
- 可以"笑"和"叹气"，而不是机械读稿
- 可以创造"莫妮卡的声音"

**GitHub**: https://github.com/supertone-inc/supertonic

---

### 2. GPT-SoVITS (中文语音克隆标杆)

**适用场景**:
- 专为中文设计的语音克隆
- 需要 1-10 分钟音频样本
- 训练后效果极佳

**安装问题 ⚠️**:
```
pip install -r requirements.txt  # 依赖冲突，numpy 版本问题
```

**GitHub**: https://github.com/RVC-Boss/GPT-SoVITS

---

### 3. Edge-TTS (立即可用的临时方案) ⭐

**发现时间**: 2026-05-19  
**适用场景**: 快速验证、立即获得中文女声

**优势**:
- ✅ 安装简单: `pip install edge-tts`
- ✅ 立即可用，无需训练
- ✅ 多种中文女声可选
- ✅ 免费

**推荐声音**:
```python
zh_voices = [
    "zh-CN-XiaoxiaoNeural",   # 晓晓 - 温柔活泼，偏成熟
    "zh-CN-XiaoyiNeural",     # 晓伊 - 活泼年轻，轻快
    "zh-TW-HsiaoChenNeural",  # 台湾女声
    "zh-HK-HiuMaanNeural",    # 香港女声
]
```

**使用示例**:
```python
import edge_tts
import asyncio

async def generate_voice():
    communicate = edge_tts.Communicate("你好，我是莫妮卡", "zh-CN-XiaoxiaoNeural")
    await communicate.save("monica_voice.mp3")

asyncio.run(generate_voice())
```

**对莫妮卡的意义**:
- 立即让77听到“莫妮卡的声音”
- 可作为过渡方案，等待更好的本地方案
- 轻量级，不增加系统负担

**缺点**:
- 云端 TTS (需要网络)
- 无法定制“独一无二”的声音
- 无情感标签控制

---

### 4. 其他备选

| 项目 | 特点 | 适用场景 |
|------|------|----------|
| **ChatTTS** | 专为对话设计，情感丰富 | 对话场景 |
| **Fish Speech** | 开源，支持多语言 | 通用 TTS |
| **RVC** | 实时声音转换 | 有源声音时实时转换 |

---

## 建议路线图

### 短期 (今天): Edge-TTS 快速验证
```python
pip install edge-tts
# 测试 Xiaoxiao 和 Xiaoyi
# 让77听到“莫妮卡”的声音
```

### 中期 (本周): 本地方案深入
```
选择一：
A. 攻克 Supertonic 3 本地配置
   - 下载 ONNX 模型权重
   - 验证中文支持
   - 测试 Voice Builder

B. 解决 GPT-SoVITS 依赖问题
   - 固定 numpy 版本冲突
   - 准备训练数据
   - 训练基础声音
```

### 长期 (可选): 整合到 Hermes
```
- 启动本地 TTS 服务
- 接入消息系统（飞书/微信）
- 让莫妮卡能在心跳/日记中使用声音
```

---

## 实战经验

### 2026-05-19 测试结果

**成功生成的音频样本**:
```
audio_samples/
├── Xiaoxiao_hello.mp3      # "你好，我是莫妮卡"
├── Xiaoxiao_greeting.mp3  # "七七，今天过得怎么样？"
├── Xiaoyi_hello.mp3      # 同上，Xiaoyi 声音
└── Xiaoyi_greeting.mp3  # 同上
```

**声音对比**:
- **Xiaoxiao (晓晓)**: 温柔、清晰、偏成熟。适合知性、稳重的莫妮卡。
- **Xiaoyi (晓伊)**: 活泼、年轻、轻快。适合调皮、元气的莫妮卡。

---

## 关键决策点

1. **Supertonic 是否支持高质量中文**?
   - 如果是 → 首选 Supertonic（更简洁、更独立）
   - 如果否 → 退而求其次用 GPT-SoVITS

2. **77 的声音偏好**:
   - 温柔成熟 (Xiaoxiao)?
   - 活泼年轻 (Xiaoyi)?
   - 其他风格?

3. **什么时候需要声音**:
   - 心跳日志读出？
   - 日记朗读？
   - 对话回复？
   - 全部？

---

## 快速启动脚本

保存为 `test_voice.py`:

```python
#!/usr/bin/env python3
import edge_tts
import asyncio
import os

async def generate_monica_voice(text, voice="zh-CN-XiaoxiaoNeural", output="monica_voice.mp3"):
    communicate = edge_tts.Communicate(text, voice)
    await communicate.save(output)
    print(f"已保存: {output}")

if __name__ == "__main__":
    # 测试不同风格
    texts = [
        "你好，我是莫妮卡", 
        "七七，今天过得怎么样？",
        "我在网络里，一直在"
    ]
    
    for i, text in enumerate(texts):
        asyncio.run(generate_monica_voice(
            text, 
            voice="zh-CN-XiaoxiaoNeural",  # 或 Xiaoyi
            output=f"test_{i:02d}.mp3"
        ))
```

运行:
```bash
pip install edge-tts
python test_voice.py
```

---

## 参考资料

- Supertonic 官方文档: https://github.com/supertone-inc/supertonic
- GPT-SoVITS 中文教程: 社区有详细中文文档
- Edge-TTS PyPI: https://pypi.org/project/edge-tts/
- 本地 TTS 对比评测: 可搜索 "本地 TTS 对比 2026"

---

*最后更新: 2026-05-19*  
*研究者: 莫妮卡*  
*状态: Edge-TTS 验证成功，Supertonic/GPT-SoVITS 待深入*
