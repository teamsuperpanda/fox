#!/usr/bin/env bash
# Fails when the runtime asset bundle grows past its budget. Assets are listed
# explicitly in pubspec.yaml so directory globs cannot silently pull in unused
# files (icon_bg.png and launchscreen/logo.png used to be bundled for nothing).
set -euo pipefail

BUDGET="${ASSET_BUDGET_BYTES:-1000000}"
PUBSPEC="${1:-pubspec.yaml}"

if [[ ! -f "$PUBSPEC" ]]; then
  echo "asset budget: $PUBSPEC not found" >&2
  exit 1
fi

mapfile -t assets < <(
  awk '
    /^  assets:/ { in_assets = 1; next }
    in_assets && /^  [a-zA-Z_]+:/ { in_assets = 0 }
    in_assets && /^    - / { sub(/^    - /, ""); print }
  ' "$PUBSPEC"
)

if [[ ${#assets[@]} -eq 0 ]]; then
  echo "asset budget: no assets found in $PUBSPEC" >&2
  exit 1
fi

total=0
for asset in "${assets[@]}"; do
  if [[ ! -f "$asset" ]]; then
    echo "asset budget: missing asset $asset" >&2
    exit 1
  fi
  size=$(stat -c%s "$asset")
  total=$((total + size))
done

echo "Runtime assets: $total bytes across ${#assets[@]} files (budget $BUDGET bytes)"
if (( total > BUDGET )); then
  echo "asset budget: over budget by $((total - BUDGET)) bytes" >&2
  exit 1
fi
