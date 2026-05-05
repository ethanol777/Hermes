# 12306 API Quick Reference

## Station Name → Code Lookup

Endpoint: `https://kyfw.12306.cn/otn/resources/js/framework/station_name.js`

The response is a concatenated string with `@` separators. Each entry: `name|code|...`

```python
import urllib.request, json, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

req = urllib.request.Request(
    "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js",
    headers={"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"},
)
data = urllib.request.urlopen(req, context=ctx).read().decode("utf-8")
stations = {}
for p in data.split("@"):
    if p:
        fields = p.split("|")
        if len(fields) >= 5:
            stations[fields[1]] = fields[2]
```

## Train Schedule Query

Endpoint: `https://kyfw.12306.cn/otn/leftTicket/queryZ`

Parameters:
- `leftTicketDTO.train_date` — date in YYYY-MM-DD format
- `leftTicketDTO.from_station` — departure station code
- `leftTicketDTO.to_station` — arrival station code
- `purpose_codes` — `ADULT`

Full URL example:
```
https://kyfw.12306.cn/otn/leftTicket/queryZ?leftTicketDTO.train_date=2026-05-01&leftTicketDTO.from_station=HZH&leftTicketDTO.to_station=HBB&purpose_codes=ADULT
```

## Result Parsing

Response structure: `data.result` is an array of `|`-delimited strings.

Key field positions (0-indexed):

| Index | Value | Example |
|-------|-------|---------|
| 3 | Train number | `Z176` |
| 6 | Departure station | `杭州` |
| 7 | Arrival station | `哈尔滨西` |
| 8 | Departure time | `13:35` |
| 9 | Arrival time | `15:51` |
| 10 | Duration | `26:16` |
| 13 | Soft sleeper price token | `20260501` (date-encoded) |
| 14 | Hard sleeper price token | `3` (opaque) |
| 22 | Hard seat price token | (empty = not available) |

**Prices are encrypted/opaque.** Use standard railway pricing for estimates.

## Train Type Naming

| Prefix | Type | Speed | Best for |
|--------|------|-------|----------|
| G | 高速铁路 | 300-350 km/h | Fast, expensive |
| D | 动车组 | 200-250 km/h | Moderate |
| Z | 直达特快 | 160 km/h | Direct route, fewer stops |
| T | 特快 | 140 km/h | Like Z but more stops |
| K | 快速 | 120 km/h | Cheapest option |

## Standard Pricing Table (Reference)

For a typical 2,400 km route (杭州→哈尔滨):

| Train Type | 硬座 (Hard Seat) | 硬卧 (Hard Sleeper) | 软卧 (Soft Sleeper) |
|------------|------------------|--------------------|--------------------|
| K-train | ¥260-280 | ¥440-510 | ¥700-750 |
| Z-train | ¥275-290 | ¥470-520 | ¥750-790 |

## Error Codes

| Response | Meaning | Fix |
|----------|---------|-----|
| `httpstatus: 401` | Need auth headers | Add Cookie or User-Agent |
| Empty `data.result` | No trains found that day | Try different date or destination station |
| SSL error | Certificate issue | Use `ssl._create_unverified_context()` or set `ctx.check_hostname = False` |

## Alternative: Browser-based approach

When API fails, use browser on:
- **Ctrip Trains**: `https://trains.ctrip.com/trainbooking/search?from=杭州&to=哈尔滨&date=2026-05-01`
- **12306 main page**: `https://www.12306.cn/index/` — fill form fields with station names and click "查询"
