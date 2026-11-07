#!/usr/bin/env bash
# Report line coverage for hand-written app code and fail under a floor.
#
# Generated and translated code (lib/l10n/**), and generated sources
# (*.g.dart, *.freezed.dart, *.mocks.dart) are stripped before counting, so the
# number reflects the code this repository actually maintains.
set -euo pipefail

LCOV="${1:-coverage/lcov.info}"
THRESHOLD="${COVERAGE_THRESHOLD:-55}"
FILTERED="${LCOV%.info}.app.info"

if [[ ! -f "$LCOV" ]]; then
  echo "coverage: $LCOV not found, run 'flutter test --coverage' first" >&2
  exit 1
fi

rm -f "$FILTERED"

read -r LH LF < <(awk -v out="$FILTERED" '
  /^SF:/ {
    file = substr($0, 4)
    include = (file ~ /^lib\//) &&
      (file !~ /^lib\/l10n\//) &&
      (file !~ /\.g\.dart$/) &&
      (file !~ /\.freezed\.dart$/) &&
      (file !~ /\.mocks\.dart$/)
    if (include) print > out
    next
  }
  { if (include) print > out }
  /^LF:/ { if (include) lf += substr($0, 4) }
  /^LH:/ { if (include) lh += substr($0, 4) }
  END { print lh + 0, lf + 0 }
' "$LCOV")

if [[ "$LF" -eq 0 ]]; then
  echo "coverage: no app lines found in $LCOV" >&2
  exit 1
fi

PCT=$(awk -v lh="$LH" -v lf="$LF" 'BEGIN { printf "%.2f", lh * 100 / lf }')
echo "App-only line coverage: ${PCT}% (${LH}/${LF} lines, floor ${THRESHOLD}%)"

if awk -v pct="$PCT" -v floor="$THRESHOLD" 'BEGIN { exit (pct + 0 >= floor + 0) ? 0 : 1 }'; then
  exit 0
fi

echo "coverage: ${PCT}% is below the ${THRESHOLD}% floor" >&2
exit 1
