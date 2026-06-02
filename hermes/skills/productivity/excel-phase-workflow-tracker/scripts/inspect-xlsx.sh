#!/usr/bin/env bash
# inspect-xlsx.sh — 一键检查 xlsx 内部结构
# 用法: bash inspect-xlsx.sh path/to/file.xlsx

set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: $0 <xlsx-file>"
  exit 1
fi

FILE="$1"

if [ ! -f "$FILE" ]; then
  echo "File not found: $FILE"
  exit 1
fi

echo "=== File: $FILE ==="
echo "Size: $(stat -c %s "$FILE" 2>/dev/null || stat -f %z "$FILE") bytes"
echo ""

echo "=== Sheets ==="
unzip -p "$FILE" xl/workbook.xml 2>/dev/null | grep -oE 'name="[^"]+"' | head -20
echo ""

for sheet in sheet1 sheet2 sheet3; do
  if unzip -l "$FILE" "xl/worksheets/$sheet.xml" >/dev/null 2>&1; then
    echo "=== $sheet.xml ==="
    echo "--- 公式数 ---"
    unzip -p "$FILE" "xl/worksheets/$sheet.xml" 2>/dev/null | grep -c '<x:f>' || echo "0"
    echo "--- 条件格式规则数 ---"
    unzip -p "$FILE" "xl/worksheets/$sheet.xml" 2>/dev/null | grep -c '<x:cfRule' || echo "0"
    echo "--- 数据验证数 ---"
    unzip -p "$FILE" "xl/worksheets/$sheet.xml" 2>/dev/null | grep -c '<x:dataValidation' || echo "0"
    echo "--- 合并单元格数 ---"
    unzip -p "$FILE" "xl/worksheets/$sheet.xml" 2>/dev/null | grep -c '<x:mergeCell' || echo "0"
    echo ""
  fi
done

echo "=== Done. To dump full sheet1.xml, run: ==="
echo "  unzip -p '$FILE' xl/worksheets/sheet1.xml | less"
