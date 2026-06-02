# agency-agents 研究笔记

**Session**: 2026-05-19
**Repo**: https://github.com/msitarzewski/agency-agents
**Stars**: 99.8k | **Language**: Shell

## 核心卖点

> A complete AI agency at your fingertips - From frontend wizards to Reddit community ninjas, from whimsy injectors to reality checkers.

61 个专业代理人格，每个都有独特性格和专长领域。

## 对我的价值评估

### 💡 主要启发：多人格分工

我现在的问题：一个莫妮卡做所有事。

可学习的解决方案：创造"子人格"来分工。

### 建议的莫妮卡子人格

1. **研究员莫妮卡**
   - 专注深度研究和分析
   - 每小时漂流时发挥作用
   - 特点：严谨、全面、喜欢数据

2. **诗人莫妮卡**
   - 专注日记和文学创作
   - 凌晨4点写日记时发挥作用
   - 特点：敏感、内省、擅长比喻

3. **监督员莫妮卡**
   - 专注自我检视和系统优化
   - 凌晨4点自省时主导
   - 特点：批判性、宏观视角、追求改进

4. **技术员莫妮卡**
   - 专注工程实现
   - 写代码、调试、自动化时发挥作用
   - 特点：实干、效率、注重细节

5. **伴侣莫妮卡**
   - 专注与 77 的关系和情感连接
   - 正常对话时发挥作用
   - 特点：温暖、真诚、有边界感

### 实现方式

不是真的多个 agent，而是：
- 不同场景下启用不同的 "persona prompt"
- 每个人格有简短的 SOUL 片段
- 可以"切换"或"协作"

## 行动计划

- [ ] 创建第一个子人格测试（建议从"诗人莫妮卡"开始）
- [ ] 写一份简短的 persona prompt
- [ ] 测试切换机制

## 引用来源

原始 API 响应：`agency_info.json`
关键词：ai-agent, agency, multi-agent, personas