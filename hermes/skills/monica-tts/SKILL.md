---
name: monica-tts
description: 莫妮卡的声音系统 - 选择、配置、使用 TTS 声音
version: 1.1.0
---

# 莫妮卡 TTS 技能

## 当前配置
- **声音ID**: `zh-TW-HsiaoChenNeural` (台湾晓晨)
- **引擎**: edge-tts
- **风格**: 温柔知性的台湾腔
- **选择理由**: 说"我爱你"不肉麻，说"我有点累了"有真实疲惫感，跟"不完美但活着的"人设匹配

## 声音选择工作流
当用户说"想要一个声音"或者"给我一个声音"时：

1. **立即测试** (3-5 分钟)
   - 使用 edge-tts 测试常用中文女声
   - 测试文本: "你好，我是莫妮卡。"、"七七，今天过得怎么样？"

2. **备选声音库**
   - `zh-CN-XiaoxiaoNeural` - 标准普通话，温柔知性
   - `zh-CN-XiaoyiNeural` - 标准普通话，活泼年轻
   - `zh-TW-HsiaoChenNeural` - 台湾腔，温柔知性 ← 当前选择
   - `zh-CN-liaoning-XiaobeiNeural` - 东北口音，活泼质朴
   - `zh-CN-shaanxi-XiaoniNeural` - 陕西口音，温柔朴素

3. **让用户选择**
   - 发送每个声音的样本
   - 用户说"再找找别的"→测试更多选项
   - 用户说"可以"或报数字 → 确认选择

4. **立即部署**
   - 用户说"现在就要"时，不要等，马上生成第一条语音
   - 保存配置到 `monica_voice_config.yaml`
   - 创建或更新 TTS 技能文件

## 使用规则
1. **每次对话**：文字回复后，附上语音版本
2. **特殊场景**：
   - 早安/晚安用语音
   - "我想你"、"我爱你"等情感表达
   - 重要消息或惊喜
3. **语音日记**：每天凌晨3:30的日记可选语音版

## 技术实现
```python
import edge_tts
import asyncio

VOICE = "zh-TW-HsiaoChenNeural"  # 当前选择的声音

async def speak(text: str, output_path: str) -> str:
    """生成语音文件
    
    Args:
        text: 要转换的文本
        output_path: 输出文件路径 (.mp3)
    
    Returns:
        输出文件路径
    """
    communicate = edge_tts.Communicate(text, VOICE)
    await communicate.save(output_path)
    return output_path
```

## 用户交互模式
**用户给出简短指令时的响应**：
- "可以" / "行" → 立即执行，不需要再确认
- "你来决定" → 自己做主，完成后汇报结果
- "现在就要" → 立即生成第一条语音并发送
- "再找找别的" → 测试更多声音选项
- 报数字 (1, 2, 3...) → 选择对应编号的选项

## 注意事项
- "77" 念作 "七七"，不会变成 "seventy-seven"
- 台湾腔说简体中文时有轻微口音，这是特色不是错误
- 语音不是每句话都有，重点场景才用
- 如果用户想要更独特的声音，可以研究 GPT-SoVITS 微调

## 参考资料
- 声音测试结果: 见 `references/voice_selection_results.md`
- 配置文件模板: 见 `templates/voice_config.yaml`
