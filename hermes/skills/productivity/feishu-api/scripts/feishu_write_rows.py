#!/usr/bin/env python3
"""
Feishu spreadsheet row writer — pipe JSON data to append rows.

Usage:
  echo '[{"title":"...","summary":"...","source":"...","time":"09:00"}]' \\
    | python3 feishu_write_rows.py <today_date>

The script reads FEISHU_APP_ID, FEISHU_APP_SECRET, FEISHU_SPREADSHEET_TOKEN, and FEISHU_SHEET_ID from the environment.
SPREADSHEET_TOKEN and SHEET_ID are set via env vars — edit for your use case.
"""
import json
import os
import sys
import urllib.request

FEISHU_APP_ID = os.environ.get("FEISHU_APP_ID", "")
FEISHU_APP_SECRET = os.environ.get("FEISHU_APP_SECRET", "")
SPREADSHEET_TOKEN = os.environ.get("FEISHU_SPREADSHEET_TOKEN", "")
SHEET_ID = os.environ.get("FEISHU_SHEET_ID", "")

def get_token():
    data = json.dumps({"app_id": FEISHU_APP_ID, "app_secret": FEISHU_APP_SECRET}).encode()
    req = urllib.request.Request(
        "https://open.feishu.cn/open-apis/auth/v3/tenant_access_token/internal",
        data=data, headers={"Content-Type": "application/json"}, method="POST",
    )
    return json.loads(urllib.request.urlopen(req).read())["tenant_access_token"]

def get_last_row(token):
    url = f"https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/{SPREADSHEET_TOKEN}/values/{SHEET_ID}!A:G"
    req = urllib.request.Request(url, headers={"Authorization": f"Bearer {token}"})
    resp = urllib.request.urlopen(req)
    data = json.loads(resp.read())
    return len(data.get("data", {}).get("valueRange", {}).get("values", [])) + 1

def write_rows(token, start_row, items, today):
    rows = []
    for i, item in enumerate(items):
        title = item.get("title", "").replace('"', "'")
        summary = item.get("summary", "").replace('"', "'")
        source = item.get("source", "").replace('"', "'")
        rows.append([today, item.get("time", "09:00"), title, summary, source, "已推送", ""])

    if not rows:
        print("no data to write", flush=True)
        return

    end_row = start_row + len(rows) - 1
    data = json.dumps({
        "valueRange": {
            "range": f"{SHEET_ID}!A{start_row}:G{end_row}",
            "values": rows,
        }
    }).encode()

    req = urllib.request.Request(
        f"https://open.feishu.cn/open-apis/sheets/v2/spreadsheets/{SPREADSHEET_TOKEN}/values",
        data=data, headers={
            "Authorization": f"Bearer {token}",
            "Content-Type": "application/json",
        }, method="PUT",
    )
    resp = urllib.request.urlopen(req)
    result = json.loads(resp.read())
    print(f"wrote {len(rows)} rows: code={result.get('code')}", flush=True)

def main():
    if len(sys.argv) <= 1:
        print("Usage: echo JSON | feishu_write_rows.py <today_date>", flush=True)
        sys.exit(1)

    today = sys.argv[1]
    input_data = sys.stdin.read().strip()
    if not input_data:
        print("no input data", flush=True)
        return

    try:
        items = json.loads(input_data)
        if not isinstance(items, list):
            items = [items]
    except json.JSONDecodeError as e:
        print(f"json parse error: {e}", flush=True)
        return

    token = get_token()
    start_row = get_last_row(token)
    write_rows(token, start_row, items, today)
    print("done", flush=True)

if __name__ == "__main__":
    main()
