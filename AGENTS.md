# AGENTS.md

These are repo-specific instructions for AI coding agents.

## Operating mode

- Follow the "Mode lock" rules in `CLAUDE.md`.
- Default to answering questions without follow-up questions (unless blocked).
- Default to minimal responses (no long plans unless asked).

## Canonical facts / drift prevention

This repo uses `./drift-guard.sh` to prevent canonical-only literals (IPs, domains, ports, paths) from being duplicated across docs.

- Canonical literals should live only in the allowlisted files/folders configured in `drift-guard.sh`.
- If you need to reference a canonical value elsewhere, link to the canonical doc instead of copying it.
- Before finalizing doc changes, run: `bash ./drift-guard.sh`.

## Output discipline

- Prefer short bullets.
- Avoid verbose reasoning.
- When making changes: state what changed + how to verify (commands).
