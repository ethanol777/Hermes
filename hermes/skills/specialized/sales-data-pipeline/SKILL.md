---
name: sales-data-pipeline
description: Automated sales data pipeline — extract metrics from Excel files, consolidate into real-time dashboards, and distribute reports to sales reps by region.
version: 1.0.0
author: Hermes Agent (consolidated)
license: MIT
metadata:
  hermes:
    tags: [sales, data-pipeline, excel, reporting, dashboard, distribution]
---

# Sales Data Pipeline

A three-stage automated sales data pipeline: **Extract** → **Consolidate** → **Distribute**.

## Architecture

See `references/` for detailed code and workflows for each stage.

## 1. Sales Data Extraction Agent

Monitors directories for `.xlsx`/`.xls` files → parses sheets → fuzzy-matches column names → extracts metrics → persists to database.

Key features: File watcher, fuzzy column mapping, metric type detection, idempotent import via SHA-256 content hash.

## 2. Data Consolidation Agent

Aggregates extracted metrics into dashboard views:
- Region summary (revenue, quota, attainment %, pipeline value)
- Top performers ranking
- Trend data (monthly revenue)
- Anomaly detection (>200% or <20% attainment auto-flagged)
- Data freshness tracking (current/delayed/stale)

## 3. Report Distribution Agent

Routes region-specific reports to the right recipients:
- Reps get only their region's data
- Managers get company-wide summaries
- Retry: 1min → 5min → 30min
- Audit log for every delivery
- 10MB email size limit with download-link fallback

## See Also

- `references/extraction.md` — Sales data extraction with fuzzy column matching
- `references/consolidation.md` — Dashboard consolidation and anomaly detection
- `references/distribution.md` — Report distribution engine and audit logging
