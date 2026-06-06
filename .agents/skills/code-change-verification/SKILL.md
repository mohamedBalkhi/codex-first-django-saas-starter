---
name: code-change-verification
description: Use before handing off changes to runtime code, tests, Docker, CI, dependencies, setup scripts, or documentation commands.
---

# Code Change Verification

## Workflow

1. Run `docker compose config`.
2. Run `python manage.py check`.
3. Run `pytest`.
4. Run `./scripts/check-docs.sh`.
5. Run `git status --short --ignored`.

## Output

Return:

- Commands run.
- Pass/fail result for each command.
- Any skipped command and the exact reason.
- Remaining risk.
