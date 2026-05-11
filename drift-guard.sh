#!/usr/bin/env bash
# Drift guard — fails if canonical-only literals appear outside allowed files.
#
# Usage:
#   bsh ./drift-guard.sh            # check (default)
#   bsh ./drift-guard.sh --check    # check
#   bsh ./drift-guard.sh --list     # print config
#   bsh ./drift-guard.sh --help     # help

set -euo pipefail

LITERALS=(
  # Use reserved examples so this repo doesn't leak real environment details.
  # Replace these with your own canonical literals in the project where you use this.
  "192.0.2.10"          # TEST-NET-1 example IP
  "198.51.100.11"       # TEST-NET-2 example IP
  "203.0.113.12"        # TEST-NET-3 example IP
  "router.example.net"  # example host
  "ns1.example.com"     # example DNS
  "ns2.example.com"     # example DNS
  "19132"               # example port (pick something repo-specific)
  "42424"               # example port (pick something repo-specific)
  "/srv/backup"         # example path
)

ALLOWLIST=(
  # Canonical sources (adjust to your repo)
  "system/"
  # Audit/reference — historical docs, not edited for current facts
  "audit/"
  # Runbooks — literals required in commands
  "runbooks/"
  # Drift guard docs/examples
  "drift/"
  # This script
  "scripts/drift-guard.sh"
  "drift-guard.sh"
)

IGNORE_DIRS=(
  ".git"
  "node_modules"
  "dist"
  "build"
  "vendor"
  ".venv"
)

REPO_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VIOLATIONS=0

print_help() {
  cat <<'EOF'
Drift Guard

Checks that canonical-only literals only appear in allowlisted files/folders.

Usage:
  bsh ./drift-guard.sh [--check|--list|--help]

Exit codes:
  0  no drift detected
  1  violations found
  2  usage/config error
EOF
}

print_config() {
  echo "REPO_ROOT=$REPO_ROOT"
  echo ""
  echo "LITERALS:"
  for literal in "${LITERALS[@]}"; do
    echo "  - $literal"
  done
  echo ""
  echo "ALLOWLIST:"
  for allow in "${ALLOWLIST[@]}"; do
    echo "  - $allow"
  done
  echo ""
  echo "IGNORE_DIRS:"
  for dir in "${IGNORE_DIRS[@]}"; do
    echo "  - $dir"
  done
}

has_cmd() { command -v "$1" >/dev/null 2>&1; }

list_matches() {
  local literal="$1"
  if has_cmd rg; then
    local -a rg_args
    rg_args=(
      --no-heading
      --line-number
      --fixed-strings
      --glob "*.md"
      --glob "*.sh"
    )
    for dir in "${IGNORE_DIRS[@]}"; do
      rg_args+=( --glob "!${dir}/**" )
    done
    rg "${rg_args[@]}" "$literal" "$REPO_ROOT" 2>/dev/null || true
  else
    local -a grep_args
    grep_args=(
      -rn
      --include="*.md"
      --include="*.sh"
    )
    for dir in "${IGNORE_DIRS[@]}"; do
      grep_args+=( --exclude-dir="$dir" )
    done
    grep "${grep_args[@]}" "$literal" "$REPO_ROOT" 2>/dev/null || true
  fi
}

is_allowed_path() {
  local file="$1"
  local allow
  for allow in "${ALLOWLIST[@]}"; do
    if [[ "$file" == *"$allow"* ]]; then
      return 0
    fi
  done
  return 1
}

do_check() {
  local literal match file
  for literal in "${LITERALS[@]}"; do
    while IFS= read -r match; do
      [[ -n "$match" ]] || continue
      file="${match%%:*}"
      if ! is_allowed_path "$file"; then
        echo "DRIFT: '$literal' found in $match"
        VIOLATIONS=$((VIOLATIONS + 1))
      fi
    done < <(list_matches "$literal")
  done
}

MODE="check"
case "${1:-}" in
  ""|--check) MODE="check" ;;
  --list) MODE="list" ;;
  --help|-h) MODE="help" ;;
  *)
    echo "Unknown option: $1" >&2
    echo "" >&2
    print_help >&2
    exit 2
    ;;
esac

case "$MODE" in
  help) print_help; exit 0 ;;
  list) print_config; exit 0 ;;
  check) do_check ;;
esac

if [[ $VIOLATIONS -eq 0 ]]; then
  echo "OK — no drift detected"
else
  echo ""
  echo "$VIOLATIONS violation(s) found"
  exit 1
fi
