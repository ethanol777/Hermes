# Data Consolidation & Dashboard

## Dashboard Views

- **Region Summary**: Revenue, quota, attainment %, rep count, pipeline
- **Top Performers**: Top N reps by revenue
- **Pipeline Snapshot**: Total pipeline value and count
- **Trend Data**: Monthly revenue last N months
- **Anomalies**: Attainment >200% or <20% flagged, missing quota = "待设定"

## Data Freshness

- current: <2h since last update
- delayed: 2-8h
- stale: >8h

## Key Calculations

- Attainment % = revenue / quota * 100 (handle zero quota → None)
- Data quality score: 100 - null_records*5 - duplicates*10
- Anomaly: attainment >200% or <20% → auto-flag
