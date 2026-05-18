---
name: china-travel-search
description: "Research cheapest transportation (train, flight, bus) between Chinese domestic cities — 12306 API, travel site browser research, and price comparison."
triggers:
  - "杭州到"
  - "到哈尔滨"
  - "最省钱"
  - "火车票"
  - "机票"
  - "去哪"
  - "怎么去"
  - "交通方案"
  - "travel china"
  - "chinese domestic travel"
  - "12306"
tags: [travel, china, transportation, 12306, train, flight, price-comparison, productivity]
---

# China Domestic Travel Search Skill

Techniques for finding the cheapest way to travel between Chinese domestic cities.

## Quick Reference

### 1. Train Schedule via 12306 API (most reliable)

Use 12306 station_name API to get codes, then query the ticket API directly.

```python
import urllib.request, json, ssl
ctx = ssl.create_default_context()
ctx.check_hostname = False
ctx.verify_mode = ssl.CERT_NONE

# Step 1: Get station name → code mapping
req = urllib.request.Request(
    "https://kyfw.12306.cn/otn/resources/js/framework/station_name.js",
    headers={"User-Agent": "Mozilla/5.0"},
)
data = urllib.request.urlopen(req, context=ctx).read().decode("utf-8")
stations = {}
for p in data.split("@"):
    if p:
        fields = p.split("|")
        if len(fields) >= 5:
            stations[fields[1]] = fields[2]  # name -> code
# e.g. stations["杭州"] = "HZH", stations["哈尔滨西"] = "VAB"
```

Common station codes:
| Station | Code |
|---------|------|
| 杭州 | HZH |
| 杭州东 | HGH |
| 上海 | SHH |
| 北京 | BJP |
| 北京南 | VNP |
| 哈尔滨 | HBB |
| 哈尔滨西 | VAB |
| 哈尔滨东 | VBB |

```python
# Step 2: Query train schedule
url = f"https://kyfw.12306.cn/otn/leftTicket/queryZ?leftTicketDTO.train_date=2026-05-01&leftTicketDTO.from_station=HZH&leftTicketDTO.to_station=HBB&purpose_codes=ADULT"
req = urllib.request.Request(url, headers={
    "User-Agent": "Mozilla/5.0",
    "Cookie": "_uab_collina=12345; JSESSIONID=test",
})
resp = urllib.request.urlopen(req, context=ctx)
data = json.loads(resp.read().decode("utf-8"))

# Step 3: Parse results
for item in data["data"]["result"]:
    fields = item.split("|")
    if len(fields) >= 26:
        train_no = fields[3]       # e.g. Z176
        from_st = fields[6]        # station name
        to_st = fields[7]          # station name
        depart = fields[8]         # departure time
        arrive = fields[9]        # arrival time
        duration = fields[10]     # travel duration
```

### 2. Travel Site Browser Research

Fall back to browser for sites with visible price data:

| Site | URL pattern | Notes |
|------|-------------|-------|
| **Ctrip Trains** | `https://trains.ctrip.com/trainbooking/search?from={city}&to={city}&date=YYYY-MM-DD` | Shows schedule but prices require login |
| **Ctrip Flights** | `https://flights.ctrip.com/` | Search form; prices visible after search |
| **Qunar Flights** | `https://flight.qunar.com/` | Often shows prices without login |
| **12306 Web** | `https://www.12306.cn/` | Official site, query form on homepage |

### 3. Price Estimates (reference ranges)

For a route like 杭州→哈尔滨 (~2,400km):

| Mode | Price Range | Duration | Notes |
|------|------------|----------|-------|
| K-train 硬座 | ¥260-280 | 35-36h | Cheapest but uncomfortable |
| K-train 硬卧 | ¥440-510 | 35-36h | Best value, can sleep |
| Z-train 硬座 | ¥275-290 | 26h | 10h faster than K-train, same price tier |
| Z-train 硬卧 | ¥470-520 | 26h | Best time-value balance |
| Flight (advance) | ¥400-800 | ~3h | Book early for lowest price |
| Flight (full) | ¥1000-1500 | ~3h | Walk-up price |
| High-speed (via Beijing) | ¥1000-1200 | 10-12h | Expensive, need transfer |

### Pitfalls

- **12306 prices are encrypted** — fields 13-24 contain encrypted values. Use standard railway pricing tables for estimates.
- **五一/国庆 peak** — prices surge, tickets sell out fast. Recommend booking days in advance.
- **Ctrip/Travel sites** often require login or display captchas. The 12306 API is more reliable for raw schedule data.
- **12306 API** sometimes returns `httpstatus: 401` or empty results. Retry with different user-agent or add a cookie.
- **Travel site browser automation** can hit captchas. Prefer API approaches when possible.
- **Flights from HGH (杭州萧山) to HRB (哈尔滨太平)** — check multiple OTAs for price differences.
- **High-speed rail** from 杭州 to 哈尔滨 has no direct line; must transfer at 北京南 or 沈阳.

## References

- `references/12306-api-quickref.md` — Full 12306 API reference with station codes, query formats, and result parsing.
