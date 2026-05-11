# Drift Guard

`drift-guard.sh` is a lightweight “doc hygiene” check: it fails when **canonical-only literals**
(IPs, hostnames, ports, paths, etc.) appear outside a small set of allowed source-of-truth files.

This is useful when humans and AI assistants are editing a repo and you want to prevent “fact drift”
from copy/paste across many docs.

## What it does

- Searches the repo for each string in `LITERALS`.
- Only considers matches in `*.md` and `*.sh`.
- If a match is found outside `ALLOWLIST`, it prints a `DRIFT:` line and exits `1`.
- If no violations are found, it prints `OK — no drift detected` and exits `0`.

## Quick start (drop-in)

1) Copy the script into your repo:

- Put it at `drift-guard.sh` (recommended) or `scripts/drift-guard.sh`
- Make it executable:
  - `chmod +x scripts/drift-guard.sh`

2) Edit `drift-guard.sh`:

- Replace the placeholder example literals in `LITERALS=(...)` with your real canonical facts
  (IPs, hostnames, ports, paths, etc.). The script in this repo uses safe examples like TEST-NET IPs
  (`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`) and `example.com` domains so it doesn’t
  leak personal details.
- Update `ALLOWLIST=(...)` to match your canonical doc locations (e.g. `system/`, `runbooks/`, etc.)

3) Run it:

- `bash ./drift-guard.sh`

## Install (how others should consume this repo)

Pick one pattern and document it in your project:

### Option A: Vendor the script (recommended for most teams)

Copy `scripts/drift-guard.sh` into your repo (same path), then customize `LITERALS` and `ALLOWLIST`.
This avoids submodule overhead and keeps the config close to the docs it protects.

### Option B: Git submodule (pins a known version)

Add as a submodule, then call it from CI:

```bash
git submodule add <REPO_URL> tools/driftguard
bash tools/driftguard/scripts/drift-guard.sh
```

### Option C: Fetch a tagged release asset

If you publish GitHub Releases, consumers can download a known version and drop it into
`scripts/drift-guard.sh`.

## CLI options

- `bash ./drift-guard.sh` / `bash ./drift-guard.sh --check` — run the check
- `bash ./drift-guard.sh --list` — print current `LITERALS`, `ALLOWLIST`, and ignored dirs
- `bash ./drift-guard.sh --help` — usage and exit codes

## Performance / tooling

- Uses `rg` (ripgrep) when available for speed, otherwise falls back to `grep`.
- Skips common directories by default (`.git`, `node_modules`, `dist`, `build`, `vendor`, `.venv`).

## Typical repo layout

A simple layout that works well with AI:

- `system/` — canonical “source of truth” docs (allowed to contain literals)
- `runbooks/` — operational commands (often allowed to contain literals)
- `audit/` — historical snapshots (allowed to contain literals, but not treated as current)
- `guides/` / `notes/` — everything else (should link to `system/` instead of duplicating literals)

Configure this by allowlisting only `system/` (and optionally `runbooks/`, `audit/`) and leaving
the rest un-allowlisted so drift gets caught early.

## Example scenario (why this is useful)

You maintain home-lab / ops docs where a few values are “truth” (router IP, NAS path, DNS servers,
service ports). An AI assistant helps you write new runbooks and troubleshooting guides. Over time,
the AI (or humans) copy/pastes those literals into multiple guides, then you later change the router
IP or migrate storage and update only one doc. Now different pages disagree, and the next on-call
action follows the wrong value.

Drift Guard prevents that by enforcing a single-source rule:

- Canonical literals may only appear in your allowlisted “source of truth” docs (e.g. `system/`)
- Everywhere else must link/reference those docs instead of duplicating the literal

## Who this is for

This is most useful when:

- You have lots of docs/runbooks in-repo
- A small set of canonical values change over time (IPs, domains, ports, paths)
- Multiple humans/AI assistants contribute and copy/paste is common
- Stale values would cause real operational mistakes

You may not need this if your docs are small/static, or you already centralize values via templates/variables.


## Integrate with AGENTS.md / CLAUDE.md

Add a short “guardrail” section so any AI agent knows the rule and how to check it.

Paste this into your repo’s `AGENTS.md` or `CLAUDE.md`:

```
## Drift guard (canonical facts)

This repo uses `scripts/drift-guard.sh` to prevent canonical-only literals (IPs, domains, ports,
paths) from being duplicated across docs.

- Canonical literals live only in the allowlisted files/folders configured in `scripts/drift-guard.sh`
- If you need to reference a canonical value elsewhere, link to the canonical doc instead of copying it
- Before finalizing doc changes, run: `bash ./drift-guard.sh`
```

## CI / pre-commit

Any workflow runner can use the exit code.

- Pre-commit: call `bash ./drift-guard.sh` from `.git/hooks/pre-commit`
- CI: add a step that runs `bash ./drift-guard.sh`
- Makefile: add a `drift-guard` target that runs `bash ./drift-guard.sh`

### GitHub Actions example

This repo includes a ready-to-copy workflow at `.github/workflows/drift-guard.yml`:

```yaml
name: drift-guard
on: [pull_request, push]
jobs:
  drift-guard:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash ./drift-guard.sh
```

## Customization notes

- `LITERALS`: keep these tight and specific (exact strings). Treat them as “single-source facts”.
- `ALLOWLIST`: prefer allowing a few canonical files/folders over many scattered docs.
- File matching is substring-based (a match is allowed if the file path contains an allowlist entry).

## Versioning / releases

This repo includes a plain `VERSION` file for humans and scripts, and uses git tags for releases.

- Bump `VERSION`
- Add an entry to `CHANGELOG.md`
- Tag a release (example): `git tag v0.1.0 && git push --tags`

## License

MIT — provided “as is”, without warranty or liability. See `LICENSE`.
