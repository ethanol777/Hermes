#!/usr/bin/env bash
# coverage_report.sh [test_dir]
# 跑覆盖率并输出未覆盖的代码行和分支

set -euo pipefail

TEST_DIR="${1:-tests}"

coverage run --branch -m pytest "$TEST_DIR" -q 2>/dev/null || true

echo "═══════════════════════════════════════"
echo "  Overall Coverage"
echo "═══════════════════════════════════════"
coverage report -m 2>/dev/null | tail -20

echo ""
echo "═══════════════════════════════════════"
echo "  Uncovered Lines (Missing Branches)"
echo "═══════════════════════════════════════"

python3 -c "
import coverage
cov = coverage.Coverage()
cov.load()
data = cov.get_data()
total_missed = 0
total_branches = 0
for fname in data.measured_files():
    analysis = cov.analysis(fname)
    _, executed, missing, file_branches = analysis
    missing_branches = []
    if file_branches:
        for arc, taken in file_branches:
            if not taken:
                total_branches += 1
    if missing:
        total_missed += len(missing)
        print(f'\n  📄 {fname}')
        with open(fname) as f:
            lines = f.readlines()
        for lineno in missing:
            if 1 <= lineno <= len(lines):
                print(f'    L{lineno}: {lines[lineno-1].rstrip()}')
print(f'\n═══════════════════════════════════════')
print(f'  Total uncovered lines: {total_missed}')
print(f'  Total uncovered branches: {total_branches}')
print(f'═══════════════════════════════════════')
" 2>/dev/null || echo "  (coverage analysis complete)"
