# Report Distribution

## Key Features

- **Region routing**: reps get only their region data
- **Manager/admin**: company-wide summary
- **Async delivery**: one failure doesn't block others
- **Retry**: 1min → 5min → 30min, then alert admin
- **Email size**: >10MB → convert to download link

## Schedule

- Daily region report: weekdays 8:00 AM (recipient's timezone)
- Weekly company summary: Monday 7:00 AM

## Audit Log

Every delivery records: recipient email, region, role, report type, status (sent/failed/retrying), attempts count, error, timestamp.
