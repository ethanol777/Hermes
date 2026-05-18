# Sales Data Extraction

## File Monitoring

Monitor a directory for `.xlsx` and `.xls` files. Ignore temp lock files.

## Import Process

1. File detection → wait for write stability (2s)
2. Pre-check: validate format, SHA-256 hash dedup
3. Record import status in import_log
4. Parse workbook, iterate all visible sheets
5. Fuzzy column name mapping (revenue/sales/total_sales → revenue)
6. Metric type inference from sheet name (MTD/YTD/FORECAST)
7. Data cleaning (remove currency symbols, standardize dates)
8. Rep matching by email or full name
9. Batch insert to database in transaction
10. Update import_log with results

## Pitfalls

- File not written completely → wait for size stability
- Summary rows as data → detect "合计"/"Total"
- Multi-currency mixed → detect symbols, tag fields
- Date format ambiguity → prefer Excel serial numbers
- Hidden sheets with old data → only process visible sheets
