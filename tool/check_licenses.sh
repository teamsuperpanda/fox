#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2026 Team Super Panda Limited
# SPDX-License-Identifier: MIT
#
# SPDX attribution check.
#
# Every first-party Dart and shell file must start with the project's SPDX
# header. Generated localizations and JSON ARB files are exempt. Brand assets
# stay proprietary and must never claim MIT.
set -euo pipefail

cd "$(dirname "$0")/.."

fail=0

while IFS= read -r file; do
  case "$file" in
    lib/l10n/app_localizations*.dart) continue ;;
  esac
  if ! head -5 "$file" | grep -q 'SPDX-License-Identifier: MIT'; then
    echo "$file: missing 'SPDX-License-Identifier: MIT' in the first five lines" >&2
    fail=1
  fi
  if ! head -5 "$file" | grep -q 'SPDX-FileCopyrightText: 2026 Team Super Panda Limited'; then
    echo "$file: missing the SPDX copyright line" >&2
    fail=1
  fi
done < <(git ls-files 'lib/**/*.dart' 'test/**/*.dart' 'integration_test/**/*.dart' 'tool/*.sh')

if ! head -1 LICENSE | grep -q '^MIT License$'; then
  echo "LICENSE: the code licence must be the MIT License" >&2
  fail=1
fi

if [ ! -f ASSETS-LICENSE.md ] || ! grep -q 'proprietary' ASSETS-LICENSE.md || ! grep -q 'MIT' ASSETS-LICENSE.md; then
  echo "ASSETS-LICENSE.md: must state that brand assets are proprietary and not MIT" >&2
  fail=1
fi

# Brand assets are binary and must not carry an MIT SPDX header.
if git grep -l -- 'SPDX-License-Identifier: MIT' -- 'assets/**' >/dev/null 2>&1; then
  echo "assets/: brand assets must not be marked MIT" >&2
  fail=1
fi

if [ "$fail" -ne 0 ]; then
  echo "Licence check failed. Add the SPDX header to new source files." >&2
  exit 1
fi

echo "Licence check passed."
