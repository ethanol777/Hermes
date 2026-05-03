# Hacker News Algolia API Reference

The Hacker News Algolia API is the most reliable source for real-time tech/AI news from this WSL environment. No API key required.

## Base URL

```
https://hn.algolia.com/api/v1/
```

## Key Endpoints

### `search_by_date` — Latest stories sorted by date (RECOMMENDED)

```bash
curl -s "https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=30"
```

Returns stories sorted by `created_at` descending. Good for "what's happening right now."

### `search` — Relevance-sorted search

```bash
curl -s "https://hn.algolia.com/api/v1/search?query=AI&tags=story&hitsPerPage=20"
```

Returns stories matching the query, sorted by relevance (points + recency). Good for finding top stories on a specific topic.

### Search with numeric filters

```bash
# Stories with >100 points (not very useful for cron — takes too long for new stories)
curl -s "https://hn.algolia.com/api/v1/search?query=AI&tags=story&hitsPerPage=20&numericFilters=points>100"

# Stories from last 7 days (use Unix timestamp — but `date -d` doesn't work from all shells)
# Instead, just use search_by_date and filter client-side
```

## JSON Response Structure

```json
{
  "hits": [
    {
      "title": "Story Title",
      "url": "https://example.com/article",
      "author": "username",
      "points": 42,
      "objectID": "12345678",
      "created_at": "2026-05-03T01:06:14Z",
      "created_at_i": 1775771174,
      "num_comments": 15
    }
  ],
  "nbHits": 200,
  "page": 0,
  "nbPages": 10
}
```

Fields most useful for cron news pushes:
- `title` — The story title (descriptive enough for one-liner summaries)
- `url` — External article URL, or null for "Ask HN"/"Show HN" text posts
- `created_at` — ISO 8601 timestamp
- `points` — Upvote count (indicator of quality/relevance)
- `objectID` — HN item ID (build fallback URL: `https://news.ycombinator.com/item?id={objectID}`)

## AI News Filtering in Python

HN Algolia's `?query=` parameter is inconsistent — use `tags=story` + client-side keyword matching instead.

### Comprehensive keyword list:

```python
ai_keywords = [
    'ai ', ' ai',           # "AI" as standalone word (avoid "tail", "email", "main")
    'openai',                # OpenAI
    'gpt',                   # GPT-4/5, GPT-4o
    'claude',                # Anthropic Claude
    'anthropic',             # Anthropic company
    'deepseek',              # DeepSeek models
    'llm', 'llms',           # Large Language Models
    'agent', 'agents',       # AI agents
    'autonomous',            # Autonomous vehicles, agents
    'driverless',            # Self-driving cars
    'neural',                # Neural networks
    'machine learning',
    'model',                 # AI models (high noise — use with caution)
    'transformer',
    'gemini',                # Google Gemini
    'mistral',               # Mistral AI
    'copilot',               # GitHub Copilot, MS Copilot
    'chatbot',
    'reasoning',             # Reasoning models
    'fine-tun',              # Fine-tuning
    'diffusion',             # Diffusion models / image gen
    'chatgpt',
    'llama',                 # Meta Llama models
    'rag',                   # Retrieval Augmented Generation
]
```

### Filtering approach:

```python
def is_ai_story(title_lower):
    """Check if a story title is AI-related."""
    return any(kw in title_lower for kw in ai_keywords)
```

### Deduplication:

When running daily pushes, stories often repeat across days or multiple stories cover the same event. Simple dedup:

```python
seen_titles = set()
unique = []
for item in all_items:
    title_norm = item['title'].lower().strip()
    if title_norm not in seen_titles:
        seen_titles.add(title_norm)
        unique.append(item)
```

## Building the Feishu Push JSON

```python
news_items = []
for hit in recent_hits:
    if not is_ai_story(hit['title'].lower()):
        continue
    # Skip low quality
    if hit.get('points', 0) < 2 and len(unique) >= 5:
        continue

    # Build summary from title + domain knowledge
    # HN titles are descriptive, use them to craft a short Chinese summary
    title = hit['title']
    url = hit.get('url') or f"https://news.ycombinator.com/item?id={hit['objectID']}"
    source_domain = url.split('/')[2] if url else 'news.ycombinator.com'

    news_items.append({
        "title": title,
        "summary": f"[生成的中文摘要]",
        "source": url,
        "time": "09:00"  # cron run time
    })
```

## Writing Title-Based Summaries

Since HN only provides titles (no abstracts), write summaries from the title text using your domain knowledge:

| Title Pattern | Summary Strategy |
|---|---|
| "[Company] launches [product]" | 公司名发布产品名，描述其核心能力/意义 |
| "[Model] beats human experts at [task]" | 模型名在某任务上超越人类专家，说明数据/场景 |
| "[New regulation] for autonomous [X]" | 某监管机构针对自动驾驶领域发布新规 |
| "[Tool] — an [X] for [platform]" | 描述新工具的核心功能和目标平台 |
| "Study finds [finding] about AI [domain]" | 研究论文的发现和意义 |

## Example: Full Fetch + Filter + Format Pipeline

```bash
curl -s --connect-timeout 10 "https://hn.algolia.com/api/v1/search_by_date?tags=story&hitsPerPage=30" | python3 -c "
import json, sys

data = json.load(sys.stdin)
hits = data.get('hits', [])

keywords = ['openai', 'gpt', 'claude', 'anthropic', 'deepseek', 'llm', 'ai ', ' ai', 'agent', 'autonomous', 'driverless', 'neural', 'gemini', 'machine learning']

items = []
for h in hits:
    title = h.get('title', '') or ''
    if not any(k in title.lower() for k in keywords):
        continue
    url = h.get('url') or f'https://news.ycombinator.com/item?id={h[\"objectID\"]}'
    items.append({
        'title': title,
        'summary': '摘要来自 HN 标题，需人工润色',
        'source': url,
        'time': '09:00'
    })
    if len(items) >= 5:
        break

print(json.dumps(items, ensure_ascii=False))
" | python3 /home/ethanol/.hermes/scripts/feishu_push_ai_news.py "$(date +%Y-%m-%d)"
```

## Limitations

- **Titles only, no abstracts** — summaries must be synthesized from title + general knowledge
- **Rate limited** — Algolia allows ~10 requests/second; fine for single-agent cron
- **Time zone** — HN uses UTC; adjust for local time if needed
- **No Chinese content** — HN is English-only; for Chinese AI news, try scraping Chinese media sites separately (this is currently not working from WSL browser)
