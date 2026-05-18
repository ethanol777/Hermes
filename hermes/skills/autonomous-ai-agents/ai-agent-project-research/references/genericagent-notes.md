# GenericAgent 研究笔记

**Session**: 2026-05-19
**Repo**: https://github.com/lsdefine/GenericAgent
**Stars**: 11.7k | **Language**: Python

## 核心卖点

> Self-evolving agent: grows skill tree from 3.3K-line seed, achieving full system control with 6x less token consumption

关键词：self-evolving, skill-tree, memory-system

## 对我的价值评估

### ✨ 最有价值的三个模式

1. **技能树结构**
   - 平铺 skill 列表 → 树状结构（根-枝-叶）
   - 我现在的 skills 是平的，没有层级
   - 可行改进：`skills/` 目录按领域分支

2. **自我进化循环**
   - 不是简单收集信息，而是"反馈→分析→改进→回测"
   - 我现在的学习是漂流式的，缺少回测
   - 可行改进：添加 skill evolution log

3. **Token 压缩**
   - 把经验固化为紧凑的"基因"
   - 我的 MEMORY.md 太敧文，需要更精练
   - 可行改进：定期压缩旧记忆

## 行动计划

- [ ] 研究 GenericAgent 的 reflect/ 目录实现
- [ ] 设计技能树结构草图
- [ ] 在下次凌晨4点自省时实验

## 引用来源

原始 API 响应：`genericagent_info.json`
关键词：ai-agent, self-evolving, skill-tree, memory-system, autonomous-agent