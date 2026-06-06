# AGENTS.md

## Project Identity

This is a Codex-first Django multi-tenant SaaS starter. It uses Django, Django
REST Framework, django-tenants, PostgreSQL schema isolation, Simple JWT, Docker
Compose, and pytest.

## Code Discovery

- Use CodeGraph first for architecture, symbol lookup, callers, callees, and
  impact analysis when available.
- If CodeGraph is not initialized, run `codegraph init -i` from the repository
  root and keep `.codegraph/` ignored.
- Use direct file reads only after CodeGraph when checking non-code text,
  generated files, or exact current edits.

## Repo Map

- `apps/tenants/`: public-schema tenant and domain models.
- `apps/authentication/`: tenant-aware JWT serializer and middleware.
- `apps/api/`: example tenant-scoped API model, serializers, views, URLs, and tests.
- `apps/core/tests/`: shared tenant-aware test helpers.
- `config/settings/`: base, development, and production Django settings.
- `.agents/skills/`: repo-local workflows for agents and maintainers.
- `.github/`: CI, issue templates, PR template, and optional Codex prompts.
- `docs/`: architecture, setup, testing, agent workflows, release, and roadmap docs.

## Mandatory Skill Triggers

- Before tenant model, domain, middleware, auth, migration, or tenant API work:
  use `.agents/skills/django-tenant-implementation-strategy/SKILL.md`.
- Before handing off code changes: use
  `.agents/skills/code-change-verification/SKILL.md`.
- When code, commands, setup, or public behavior changes: use
  `.agents/skills/docs-sync/SKILL.md`.
- Before opening public issues: use
  `.agents/skills/oss-issue-curator/SKILL.md`.

## Verification Commands

Run the narrowest relevant check while developing, then run the full stack before
handoff:

```bash
docker compose config
python manage.py check
pytest
./scripts/check-docs.sh
```

Use `./scripts/verify.sh` for full local verification when Docker and PostgreSQL
are available.

## Tenant Safety Rules

- Keep `django_tenants.middleware.main.TenantMainMiddleware` first in middleware.
- Keep `django_tenants.postgresql_backend` as the database engine.
- Keep tenant and domain models in the public schema.
- Preserve tenant JWT claim validation.
- Do not add raw SQL that bypasses schema isolation unless docs and tests explain it.
- Keep `auto_drop_schema = False`.

## Editing Rules

- Prefer small, reviewable commits.
- Keep runtime behavior changes separate from docs and GitHub automation when possible.
- Do not require OpenAI credentials for normal setup, tests, CI, or contribution.
- Treat Codex GitHub Action workflows as optional maintainer tooling.
