#!/usr/bin/env bash
# Compatibility shim. Prefer running `./drift-guard.sh` from repo root.
exec bash "$(cd "$(dirname "$0")/.." && pwd)/drift-guard.sh" "$@"
