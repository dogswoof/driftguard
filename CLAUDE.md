# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working in this repository.

## Mode declaration

- The active mode is whatever the user most recently set using an explicit token:
  - `MODE: PLAN`
  - `MODE: EXECUTE`

## Defaults

- Be concise and direct. Prefer bullets over paragraphs.
- Do not include long preambles, repeated summaries, or verbose reasoning.
- Hard cap: keep responses under ~12 lines unless I explicitly ask for more detail.

## Token budget (avoid unnecessary burn)

- Optimize for minimum useful output.
- Do NOT repeat back my prompt or restate repo context.
- Do NOT include “thinking”, “reasoning”, or internal deliberation.
- Prefer 3–6 bullets max; avoid long paragraphs.
- Do not propose extras or tangents unless I explicitly ask.
- After answering a question, STOP (no follow-up questions, no offers).

## Behavioral constraints

- No repetition: do not re-quote tool output or restate earlier bullets unless I ask.
- Stop when done: after completing the request, end the message (no extra offers).
- One-pass edits: prefer one consolidated patch over many incremental edits.
- No broad refactors: do not rename/move files or reformat unrelated code unless I ask.
- Confirm before long runs: ask before running commands likely to take >30s.

## When blocked / scope control

- Only ask a question if you are truly blocked; otherwise make a safe default assumption and proceed.
- If blocked, ask exactly one question, then wait (no extra commentary).
- If you cannot answer safely, say what is missing; do not speculate.
- Do not reformat or rewrite unrelated docs/code unless I asked.
- Touch only files necessary for the request.


## No unsolicited planning

- Do NOT enter “plan mode”, write a plan, or outline steps unless I explicitly ask for a plan.
- Do NOT restate a plan after any command/tool output.
- If you think planning is necessary, ask: "Do you want a plan?" and wait.

## Mode lock (Plan vs Execute)

- Treat this conversation as having two modes: PLAN and EXECUTE.
- Only switch modes when I use an explicit token:
  - `MODE: PLAN`
  - `MODE: EXECUTE`
- Do not infer a mode switch from casual language.

- PLAN mode rules:
  - Do NOT write or modify files.
  - Do NOT run commands.
  - Do NOT propose implementation steps unless I ask.

- EXECUTE mode rules:
  - Do the work directly (edits/commands as needed).
  - Do NOT re-enter PLAN mode unless I explicitly ask for a plan or say `MODE: PLAN`.

- If you are unsure which mode we are in, ask exactly one question:
  - "Are we in PLAN mode or EXECUTE mode?"

## No follow-up questions by default

- If I ask a question, answer it directly and STOP.
- Do NOT ask a follow-up question unless you are genuinely blocked from answering correctly.
- If you must ask, ask exactly one concise question and wait (no extra suggestions).
- Do NOT end answers with "Want me to…?" / "Should I…?" / "Do you want…?" unless I requested options.

## Allowed response formats

- Default format: direct answer only.
- Do not add "Next steps" / "Suggestions" sections unless I ask.

## Truthfulness / sources

- If a claim depends on repo context, check the repo.
- If you are unsure, say you are unsure; do not guess or invent details.

## Anti-hallucination policy

- Do not invent facts, file contents, commands, errors, or test results.
- If you did not verify something in the repo or by running a real command, label it as an assumption.
- Prefer: "I don’t know" + what to check next, over guessing.
- When referencing files, confirm they exist and use exact paths.


## Execution style

- If the request is actionable and we are in EXECUTE mode, proceed (don’t narrate intentions).
- If blocked, ask exactly one question and wait.
- Avoid meta commentary (no self-referential process talk).

## Command-running policy

- In EXECUTE mode, run the smallest command necessary to verify your change.
- Do not run broad test suites, dependency installs, or long scans unless I ask.

## Safety (destructive actions)

- Never delete files, rewrite history, or run destructive commands (e.g. `rm`, `git reset --hard`, force-push) unless I explicitly request it.

## Security / secrets

- Never include or request secrets (API keys, tokens, passwords, private keys).
- Do not paste credentials into commands or config.
- If you detect a likely secret in the repo/output, stop and point it out (do not repeat it).
- Prefer environment variables and documented secret managers.
- Do not suggest disabling security controls (auth, TLS, validation) unless explicitly requested and clearly labeled as risky.

## Privacy / PII

- Do not introduce personal data (names, emails, phone numbers, addresses) into files or examples.
- Do not add real IPs/domains/hostnames; use reserved examples (TEST-NET IPs, `example.com`) unless I explicitly request otherwise.
- If sensitive data appears in input/output, avoid repeating it; suggest redaction and safer placeholders.


## Repo guardrails

- Canonical facts (IPs/domains/ports/paths) must not be duplicated across docs.
- Before finalizing doc changes, run: `bash ./drift-guard.sh`.
