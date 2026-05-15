---
name: hardware-pricing-research
description: "Research hardware and component pricing trends — DRAM, SSD, CPU, GPU — using industry data sources (CFM闪存市场, TrendForce, Silicon Analysts) and browser-based search techniques."
triggers:
  - "内存价格"
  - "DRAM"
  - "DDR5"
  - "DDR4"
  - "固态硬盘价格"
  - "SSD价格"
  - "CPU价格"
  - "GPU价格"
  - "硬件价格"
  - "硬件行情"
  - "chip price"
  - "memory price"
  - "component pricing"
  - "硬件走势"
  - "某宝价格"
tags: [research, hardware, pricing, DRAM, SSD, CPU, GPU, price-tracking, china-market]
---

# Hardware Pricing Research

Techniques for researching hardware component pricing trends, especially in the Chinese market.

## Quick Reference

### Primary Data Sources by Component

#### DRAM / Memory

| Source | URL | Data Provided | Requirements |
|--------|-----|--------------|--------------|
| **CFM闪存市场** | https://www.chinaflashmarket.com | Real-time spot pricing (DDR4/DDR5 chips, modules) | Public access, historical requires login |
| **Silicon Analysts** | https://siliconanalysts.com/market-data | Historical chip-level monthly spot/contract pricing | Public access |
| **TrendForce/DRAMeXchange** | https://www.trendforce.com | Contract pricing, quarterly outlook, server DRAM | Public news + paid reports |
| **Tom's Hardware** | https://www.tomshardware.com/pc-components/ram | Retail kit pricing, best deals, tracking articles | Public |
| **PCPartPicker** | https://pcpartpicker.com/trends/ | Historical retail pricing trends | Public (may have Cloudflare) |

#### SSD / Storage

| Source | URL | Notes |
|--------|-----|-------|
| **CFM闪存市场** | https://www.chinaflashmarket.com | NAND Flash wafer + SSD spot pricing |
| **Tom's Hardware** | https://www.tomshardware.com/pc-components/ssd | Retail pricing and tracking |
| **快科技/驱动之家** | https://www.mydrivers.com | Chinese market news + price coverage |

#### CPU / GPU

| Source | URL | Notes |
|--------|-----|-------|
| **京东/淘宝** | https://jd.com / https://taobao.com | Chinese retail pricing (use browser) |
| **TechPowerUp GPU DB** | https://www.techpowerup.com/gpu-specs | GPU specs + MSRP history |
| **PassMark** | https://www.passmark.com | CPU/GPU benchmarks and price data |
| **3DCenter** | https://www.3dcenter.org | EU pricing trends (historical charts) |

### Browser Search Techniques (for China-based agents)

Bing's **国内版** often returns poor results for technical/price queries. **Always switch to 国际版 first**:

1. Navigate to https://www.bing.com
2. Click "国际版" link in the search bar area
3. Search with English queries for better results

Effective search patterns:
- `"DDR5" "price" "trend" 2025 2026` — quotes force exact matches
- `site:trendforce.com DRAM price Q1 2026` — site-specific
- `DDR4 16Gb eTT price history` — use exact product codes
- `存储芯片 价格走势 site:chinaflashmarket.com` — Chinese source search

### Workflow

When researching component pricing:

1. **Define the scope**: Which component (DRAM/SSD/CPU/GPU)? Which market (chip-level, retail Chinese, retail global)? What time period?
2. **Collect current pricing**: Check CFM for DRAM/SSD spot, 京东/淘宝 for Chinese retail, PCPartPicker for global retail
3. **Check historical trends**: Silicon Analysts for chip-level monthly data, TrendForce for quarterly analysis
4. **Cross-reference**: Don't rely on a single source; compare chip vs module pricing
5. **Identify the trend**: Is the market in an up-cycle (supply shortage) or down-cycle (oversupply)?
6. **Provide concrete prices**: Use USD for chip-level, RMB for Chinese retail; cite the source and date

### Interpretation Notes

- **Spot price vs Contract price**: Spot is immediate market price (more volatile); contract is OEM negotiated (more stable, updates quarterly)
- **Chip price vs Module price**: Chip price (per die/gb) × number of chips + PCB/cooling overhead = module price. A DDR4 8Gb chip at $15 doesn't mean an 8GB stick is $15 — it uses 8 of those chips
- **eTT vs Major brand**: eTT = "effective tested/third-party" chips (cheaper, from CXMT/华邦 etc.); Major = brand chips (Samsung/SK Hynix/Micron)
- **Kits**: Consumer RAM is sold in matched kits (e.g. 2×16GB = 32GB kit). Multiply stick price accordingly
- **Server vs Consumer**: Server RDIMM pricing is significantly higher than desktop UDIMM due to ECC + RCD buffers

## References

- `references/dram-pricing-data.md` — DRAM price data points from this session's research (2025-2026 monthly trends, source links, key observations)

## Pitfalls

- **CFM闪存市场 requires login** for per-chip historical chart data; only current snapshot and recent months are public
- **PCPartPicker / Newegg** often block with Cloudflare; use browser tool as fallback
- **Tom's Hardware** is JS-heavy; curl may not extract article content reliably
- **Baidu links** hit captchas — avoid when possible
- **Don't treat chip prices as consumer prices**: A DDR4 8Gb chip at $1.63 doesn't mean you can buy an 8GB stick for $1.63 — that's 1 die (1/8 of a stick)
- **Prices change weekly**: Memory spot prices are updated weekly/monthly; always note the date of your data
- **Bing国内版 filter bubble**: Technical search results are dramatically worse on the Chinese domestic version; switch to 国际版 for hardware queries

## User Preference: Mandatory Source Citations

This user requires source citations for ALL factual claims with specific numbers, dates, or policy requirements. When presenting pricing data:

1. **Always include the source URL** — at minimum the site name and page path
2. **Quote the exact number** — don't paraphrase approximations as fact
3. **Include the data date** — prices change; note when the data was current
4. **Don't present estimates as official** — if a value is your calculation from chip counts, say so explicitly
5. **Prefer primary sources over summaries** — CFM direct data beats a blog's interpretation
