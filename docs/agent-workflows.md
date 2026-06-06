# Agent Workflows

## Root Instructions

`AGENTS.md` is the durable instruction surface for Codex and other coding agents. It defines the project map, verification commands, tenant safety rules, and mandatory repo-local skill triggers.

## Repo-Local Skills

Skills live in `.agents/skills/`:

- `django-tenant-implementation-strategy`
- `code-change-verification`
- `docs-sync`
- `test-coverage-improver`
- `pr-draft-summary`
- `oss-issue-curator`

## CodeGraph

Use CodeGraph first for code discovery, architecture questions, symbol lookup, callers, callees, and impact analysis. If it is not initialized, run:

```bash
codegraph init -i
```

Keep `.codegraph/` ignored.

## Optional Codex GitHub Action Prompts

Prompt files live under `.github/codex/prompts/`. They are optional maintainer tooling and do not run unless a maintainer enables an OpenAI-backed workflow. Normal Django contributors do not need OpenAI credentials.

## Playwright And Computer Use

Playwright and Computer Use are optional tools for browser or desktop validation. They are not required for ordinary Django backend contributions.

## Handoff Evidence

Before handoff, report:

- Commands run.
- Pass/fail result.
- Tenant safety impact.
- Docs updated or intentionally unchanged.
- Remaining risk.
