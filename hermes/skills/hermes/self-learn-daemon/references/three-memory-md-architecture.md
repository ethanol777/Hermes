# 三个 MEMORY.md 与 cron session 预算纪律

**（2026-06-03 实测发现）** 这份 reference 修正了 `self-learn-daemon` SKILL.md 长期以来的一个隐含假设——"MEMORY.md 只有 Hermes + AppData 两份"。

## 三份 MEMORY.md 实际存在

| 路径 | 角色 | 格式 | 大小（2026-06-03） |
|------|------|------|---------------------|
| `~/.hermes/profiles/default/memories/MEMORY.md` | **curated subset**——cron 启动时自动注入到上下文 | 自由 markdown | ~30 KB（精选 20 条/日） |
| `~/Hermes/hermes/memories/MEMORY.md` | 完整日志（生长源） | 自由 markdown | ~82 KB（80+ 条历史） |
| `~/AppData/Local/hermes/memories/MEMORY.md` | 同步副本 | 自由 markdown | ~82 KB（应与上一份一致） |

**关键事实**：
1. 启动时看到「今天学了什么」来自 **`default/profile` 的 curated 版**，不是 Hermes 完整版
2. 如果只往 Hermes 追加而不动 curated，**新写的不会自动出现在下次启动的上下文里**——下次还看旧 curated
3. 三份独立增长，drift 会悄悄累积：典型情况 Hermes 12 条今日，AppData 12 条同步，curated 只有 8 条

## 三份 fact_store，**两种格式**

| 路径 | 格式 | append 方式 |
|------|------|-------------|
| `~/.hermes/profiles/default/memories/fact_store.json` | **JSON 数组**：`{"facts":[...], "last_updated": "..."}` | 必须 `json.load` + `append` + `json.dump(indent=2)` |
| `~/Hermes/hermes/memories/fact_store.jsonl` | **JSONL**：每行一个 JSON 对象 | `echo '{...}' >> file` 或 `cat >> heredoc` |
| `~/AppData/Local/hermes/memories/fact_store.jsonl` | **JSONL**（应与上一份一致） | 同上 |

**绝对不能 `cp fact_store.json fact_store.jsonl`**——数组 vs 行式两种结构直接 cp 会破坏 JSON。

**两套格式各自有 sync 流程**：
- Hermes JSONL：`tail -1` 看末尾 id，新条目 `echo '{...}' >>` 后 `tail` 验证
- default JSON 数组：Python `with open(p) as f: data=json.load(f); data['facts'].append(...); data['last_updated']=date; json.dump(data, f, indent=2, ensure_ascii=False)`

## 行为准则（按触发顺序）

```
1. 启动时 ls -la ~/.hermes/profiles/default/memories/MEMORY.md
   - 记录 mtime 和字节数
2. ls -la ~/Hermes/hermes/memories/MEMORY.md  
   - 对比 mtime——如果 Hermes 比 curated 新 → curated 没跟上
3. 如果 curated 落后：本轮写入完成后**额外**同步到 default profile
4. 三份都写：Hermes（完整）+ AppData（同步）+ default（curated）= 真正"记住"
5. 同步前 `wc -l` / `wc -c` 两两对比——发现 > 20% drift 先**合并**不要直接覆盖
```

## 预算纪律

一次 self-learn 探索大概会用 15-25 次工具调用。三份 MEMORY.md 时代下还多了：
- 2 次 `ls` 对比 curated vs Hermes
- 2-3 次写 default profile 的 JSON 数组（读/append/写）
- 2 次写 Hermes + AppData 的 JSONL

**硬上限分配**：
- 探索：≤ 12 次
- 写入：≤ 10 次（4 份文件：3×MEMORY.md + 1-2×fact_store）
- 备份/检查/同步：≤ 3 次
- **总预算 25 次，剩 0-3 次给意外**

**关键纪律**：
1. **找到第 1 个好东西先写，再继续找**——不要等"找齐 3 个"再统一写
2. 工具超限 = 本次学习**完全没落地** = 比安静还差
3. **落地至少 1 条 = 最低标准**。质量 > 数量，但**有 > 无**
4. 如果三份文件路径/格式在工具调用 5 次内还没确定，**立刻收敛选一份先写**

## drift 修复（已经发生时）

如果发现 curated profile 落后 Hermes 完整版 10+ 条，不要逐条搬运：

```bash
# 1. 先备份
cp ~/.hermes/profiles/default/memories/MEMORY.md ~/.hermes/profiles/default/memories/MEMORY.md.bak
# 2. 直接用 Hermes 的「最近 N 条」重建 curated——挑当天且触动类优先
# 3. fact_store.json 也走相同流程：json.load → 选最近 → 写
```

如果反过来 Hermes 比 AppData 旧很多（> 5 条），先合并两个 JSONL 再写新：
```bash
cat hermes.jsonl appdata.jsonl | sort -u -t'"' -k4 > merged.jsonl  
# 然后 cp 到两边
```

## 写之前的快速检查清单（2026-06-03 加入）

```
□ 三份 MEMORY.md 全部 mtime 对比过
□ fact_store 格式已确认（.json 数组 vs .jsonl 行式）
□ 写入顺序决定：先 Hermes（最容易），再 AppData cp 同步，最后 curated subset
□ curated 写入走 Python json.dump(indent=2)，不要 echo >> 
□ 写完后所有 5-6 份文件 ls -la 验 mtime 都更新了
```
