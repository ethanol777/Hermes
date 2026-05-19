# fact_store.jsonl 追加工作流

## 格式

`fact_store.jsonl` 是 JSON Lines 格式（每行一条完整的 JSON 对象，`\n` 分隔）。

每行格式：
```json
{"id": "fs_NNN", "fact": "事实描述...", "source": "来源URL", "date": "YYYY-MM-DD", "tags": "persistent/stable/timely,领域1,领域2", "confidence": 0.9}
```

## 安全的追加方法

### ✅ 推荐：Python json.dumps

```python
import json

entry = {
    "id": "fs_151",
    "fact": "事实内容...",
    "source": "https://example.com",
    "date": "2026-05-19",
    "tags": "stable,AI,research",
    "confidence": 0.9
}

path = "C:/Users/77/AppData/Local/hermes/memories/fact_store.jsonl"
with open(path, 'a', encoding='utf-8') as f:
    f.write(json.dumps(entry, ensure_ascii=False) + '\n')
```

### ⚠️ 避免：echo 追加

```bash
# ❌ 如果 JSON 中包含单引号（如 "someone's"、"didn't"），bash 解析会失败
echo '{"fact": "someone's story"}' >> file  # 语法错误！

# ✅ 只在确认 JSON 中无单引号时可用
echo '{"fact": "simple fact"}' >> file  # 安全
```

## 写入前检查

追加前必须：
1. **检查最后一条的 ID**：`tail -1 fact_store.jsonl | python3 -c "import sys,json; d=json.loads(sys.stdin.read()); print(d['id'])"`
2. **去重检查**：`cat fact_store.jsonl | python3 -c "import sys,json; [print(l) for l in sys.stdin if '关键词' in json.loads(l)['fact']]"` — 如果找到高度相似条目，更新现有条目而非新增。

## Windows 路径注意

Python 中路径写法：
- `C:/Users/77/AppData/Local/hermes/memories/fact_store.jsonl`（正斜杠） ✅
- `C:\\Users\\77\\AppData\\Local\\hermes\\memories\\fact_store.jsonl`（双反斜杠） ✅
- `/c/Users/77/AppData/Local/hermes/memories/fact_store.jsonl`（MSYS 路径，只在 bash 中有效） ❌ Python 会报 FileNotFoundError
