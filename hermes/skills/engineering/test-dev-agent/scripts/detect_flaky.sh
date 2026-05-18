#!/usr/bin/env bash
# detect_flaky.sh <test_file> [num_runs]
# 跑 N 轮测试，统计成功率和稳定性
# 输出格式：PASS/X | FAIL/Y | RATE=Z%

set -euo pipefail

TEST_FILE="${1:?Usage: detect_flaky.sh <test_file> [num_runs]}"
NUM_RUNS="${2:-5}"

echo "🔁 Running $TEST_FILE $NUM_RUNS times..."
echo ""

pass=0
fail=0
results=()

for i in $(seq 1 "$NUM_RUNS"); do
  echo -n "  Run $i/$NUM_RUNS ... "
  if pytest "$TEST_FILE" -q --tb=no 2>/dev/null > /tmp/flaky_output_"$$".txt; then
    echo "✅ PASS"
    pass=$((pass + 1))
    results+=("PASS")
  else
    echo "❌ FAIL"
    fail=$((fail + 1))
    results+=("FAIL")
  fi
done

rate=$(echo "scale=1; $pass * 100 / $NUM_RUNS" | bc)
echo ""
echo "═══════════════════════"
echo "  Results:"
echo "  PASS: $pass/$NUM_RUNS"
echo "  FAIL: $fail/$NUM_RUNS"
echo "  RATE: ${rate}%"
echo "═══════════════════════"

if [ "$rate" = "100.0" ]; then
  echo "  ✅ STABLE — All runs passed"
elif [ "$(echo "$rate >= 80" | bc)" = "1" ]; then
  echo "  ⚠️  MILDLY FLAKY — Keep an eye on it"
else
  echo "  🔴 HEAVILY FLAKY — Needs investigation"
fi

echo ""
rm -f /tmp/flaky_output_"$$".txt
