# Changelog

All notable changes to Drift Guard will be documented in this file.

The format is based on Keep a Changelog, and this project aims to follow Semantic Versioning.

## [Unreleased]

## [0.1.3] - 2026-05-14

### Fixed

- grep fallback was missing `-F` (`--fixed-strings`), causing literals with regex metacharacters (e.g. `.` in IP addresses) to match incorrectly

### Added

- `EXTENSIONS` array — configurable file types to scan (default: `*.md`, `*.sh`); add `*.yml`, `*.yaml`, `*.conf`, etc. as needed
- `--version` / `-V` flag — prints the embedded `DRIFT_GUARD_VERSION`

### Changed

- `is_allowed_path` now uses relative-path prefix matching instead of substring matching, preventing false allowlist hits on paths that merely contain an allowlist entry as a substring

## [0.1.2] - 2026-05-14

### Fixed

- `REPO_ROOT` in `drift-guard.sh` resolved one level above the repo root due to a stray `/..`; fixed to resolve to the script's own directory
- Typo: `b\x07sh` (BEL control character) replaced with `bash` in usage comments and `--help` output

### Changed

- `CLAUDE.md` and `AGENTS.md` added to `.gitignore` (agent config is local, not repo state)
- README Option A now correctly points to `drift-guard.sh` (root) instead of `scripts/drift-guard.sh` (shim)

## [0.1.1] - 2026-05-11

### Changed

- Add `.gitignore` and remove `.DS_Store` from the repo

## [0.1.0] - 2026-05-11

### Added

- `scripts/drift-guard.sh` canonical-literal drift check
- Docs and integration notes (`driftguard/README.md`)
- MIT license (`LICENSE`)

