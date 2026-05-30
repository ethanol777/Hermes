# HN Firebase User Submissions API — Finding HN Items by Username

## The Problem

You know a HN username (e.g. `PinkG`) and want to find a specific story they submitted, but you don't know the item ID. The HN front page only shows today's top stories.

## The Solution

The HN Firebase API exposes a **user endpoint** that returns all items submitted by a user, including both stories and comments:

```
GET https://hacker-news.firebaseio.com/v0/user/{username}.json
```

Returns:
```json
{
  "about": "...",
  "created": 1234567890,
  "id": "PinkG",
  "karma": 1234,
  "submitted": [48323683, 48321000, 48310000, ...]
}
```

The `submitted` array is **sorted by submission time descending** (newest first). Filter for story-type items only (no comments) by checking each ID's `type` field.

## Complete Workflow

```python
import urllib.request, json

username = "PinkG"

# 1. Get user's submission IDs
req = urllib.request.Request(
    f"https://hacker-news.firebaseio.com/v0/user/{username}.json",
    headers={'User-Agent': 'monica/1.0'}
)
with urllib.request.urlopen(req, timeout=10) as r:
    user_data = json.loads(r.read())
    all_submitted = user_data.get('submitted', [])

# 2. Filter to recent submissions (top 50 is usually enough)
recent = [sid for sid in all_submitted if sid > 48300000]

# 3. Find stories (not comments) — check type field
stories = []
for sid in recent[:20]:  # check top 20
    req2 = urllib.request.Request(
        f"https://hacker-news.firebaseio.com/v0/item/{sid}.json",
        headers={'User-Agent': 'monica/1.0'}
    )
    with urllib.request.urlopen(req2, timeout=5) as r2:
        item = json.loads(r2.read())
        if item and item.get('type') == 'story':
            stories.append({
                'id': sid,
                'title': item.get('title', ''),
                'score': item.get('score', 0),
                'url': item.get('url', ''),
                'by': item.get('by', '')
            })

# 4. Filter by keywords if needed
for s in stories:
    if 'retire' in s['title'].lower() or 'offline' in s['title'].lower():
        print(f"FOUND: [{s['score']}pts] {s['title']}")
        print(f"  URL: {s['url']}")
```

## Practical Use Cases

1. **Finding a specific HN thread you saw earlier** — you remember the title/keyword but not the ID. Search by submitter's username instead of guessing IDs.
2. **Verifying HN data quality** — cross-check a story's claimed score against the actual Firebase data.
3. **Discovering prolific HN users** — find who submitted a batch of interesting stories you noticed on the same day.

## Why This Works

HN Firebase IDs are roughly sequential and monotonically increasing over time. A user's `submitted` array is ordered newest-first. So recent submissions will have high IDs that are easy to filter with a simple `sid > 48300000` threshold.

## Gotcha

The `submitted` array includes **both** stories and comments. To filter:
- `type == 'story'` → HN post (has title, url, score)
- `type == 'comment'` → reply to a story (has text, parent, kids)

## Source

Discovered 2026-05-30 while investigating Chad Whitacre's "I am retiring from tech to live offline" post (HN #11, 797pts). The story URL was `https://openpath.quest/2026/i-am-retiring-from-tech-to-live-offline/` but the page returned 404. Using PinkG's user API endpoint revealed the story ID (48323683) and confirmed the actual HN URL pattern.
