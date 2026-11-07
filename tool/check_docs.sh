#!/usr/bin/env bash
# Documentation drift check.
#
# Fails when the docs reference a path that does not exist, a workflow that does
# not exist, or a command and claim that the repository no longer uses. Run from
# the repository root, or let CI call it as `bash tool/check_docs.sh`.
set -euo pipefail

cd "$(dirname "$0")/.."

docs=(
  README.md
  CONTRIBUTING.md
  ARCHITECTURE.md
  SECURITY.md
  ASSETS-LICENSE.md
  TRADEMARKS.md
)

fail=0

report() {
  printf '%s\n' "$1" >&2
  fail=1
}

# Paths that docs describe as generated output and that are absent on a clean clone.
is_generated() {
  case "$1" in
    assets/images/screenshots/*|assets/images/screenshots) return 0 ;;
    *) return 1 ;;
  esac
}

path_exists() {
  local p="$1"
  [ -e "$p" ] && return 0
  is_generated "$p" && return 0
  return 1
}

for doc in "${docs[@]}"; do
  [ -f "$doc" ] || continue

  # Stale commands and claims that have shipped in this repository before.
  while IFS= read -r line; do
    [ -n "$line" ] || continue
    report "$doc:${line%%:*}: stale text: ${line#*:}"
  done < <(grep -nE 'dart run build_runner|release_screenshots\.yml|Google Fonts|SharedPreferences|flutter_quill \^11\.5|~28 test files|commit the new goldens' "$doc" || true)

  # Backticked repository paths must exist.
  while IFS= read -r token; do
    token="${token#\`}"
    token="${token%\`}"
    token="${token%%#*}"
    token="${token%/}"
    case "$token" in
      ''|*' '*|*'*'*|*'{'*|*'<'*|*'$'*|*'..'*) continue ;;
    esac
    case "$token" in
      lib/*|test/*|tool/*|assets/*|integration_test/*|android/*|ios/*|.github/*) ;;
      *) continue ;;
    esac
    path_exists "$token" || report "$doc: missing path: $token"
  done < <(grep -oE '`[^`]+`' "$doc" || true)

  # Workflow and script names must resolve inside .github or tool/.
  while IFS= read -r name; do
    [ -n "$name" ] || continue
    if ! find .github tool -maxdepth 2 -name "$name" -print -quit 2>/dev/null | grep -q .; then
      report "$doc: missing workflow or script: $name"
    fi
  done < <(grep -oE '[A-Za-z0-9_-]+\.(yml|sh)\b' "$doc" | sort -u || true)
done

if [ "$fail" -ne 0 ]; then
  echo "Documentation check failed. Fix the paths or wording above." >&2
  exit 1
fi

echo "Documentation check passed."
