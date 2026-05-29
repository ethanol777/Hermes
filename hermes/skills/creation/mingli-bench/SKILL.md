---
name: mingli-bench
description: >
  中国传统命理评测基准（MingLi-Bench）。用于评测 LLM 在八字和紫微斗数命理题目上的准确率。
  题目来源于全球算命师大赛 2022-2025 年度赛题，共 160 道选择题。
  Use when: 评测某个模型在命理推理上的能力，或对比不同模型的命理水平。
triggers:
  - "MingLi-Bench"
  - "命理评测"
  - "八字评测"
  - "紫微评测"
  - "fortune telling benchmark"
  - "bazi benchmark"
---

# MingLi-Bench — 命理评测基准

基于 `DestinyLinker/MingLi-Bench` 仓库。

## 简介

- **用途**：评测 LLM 在八字/紫微斗数命理题上的准确率
- **题目来源**：全球算命师大赛（hkjfma.org）2022-2025 年度赛题
- **题量**：160 道选择题
- **分类**：事业、健康、婚姻、子女、财运等十二大类

## 安装

```bash
git clone --depth=1 https://github.com/DestinyLinker/MingLi-Bench
cd MingLi-Bench
pip install -r requirements.txt
cp .env.example .env
# 填写 .env（支持 OpenRouter/OpenAI/Claude/Gemini/DeepSeek/豆包）
```

## 快速使用

```bash
# 自检
python -m mingli_bench.cli --list-models
python -m mingli_bench.cli --stats

# 推荐用法（CoT + 注入命盘）
python -m mingli_bench.cli \
    --model openai/gpt-4o \
    --year 2025 --cot --astro
```

## 推荐参数

| 参数 | 说明 |
|------|------|
| `--cot` | 思维链，推理过程更完整 |
| `--astro` | 注入预排命盘，测推理而非排盘 |
| `--year` | 按年份筛选（2022/2023/2024/2025） |
| `--categories` | 按类别筛选（事业/婚姻/健康等） |
| `--max-workers` | 并发数，默认5，调高可加速 |

## 输出

每次运行在 `logs/` 下生成：
- `<model>_results.json` — 逐题打分
- `<model>_summary.txt` — 核心指标
- `<model>_responses/` — 原始响应

## 评测我的能力

当77想知道自己（或某个模型）在命理上的"段位"时，可以用这个工具跑一组题看看准确率。
