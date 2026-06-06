# Contributing

Thanks for improving the Codex-first Django multi-tenant SaaS starter.

## Development Setup

```bash
git clone https://github.com/mohamedBalkhi/Django-Multi-Tenant-SaaS-Starter-Template.git
cd Django-Multi-Tenant-SaaS-Starter-Template
./scripts/bootstrap-env.sh
make setup
```

Use Docker Compose for PostgreSQL:

```bash
docker compose up -d db
```

## Verification Before Pull Requests

Run these commands before opening a PR:

```bash
docker compose config
python manage.py check
pytest
./scripts/check-docs.sh
```

Use `./scripts/verify.sh` when Docker and PostgreSQL are available for the full local check.

## Tenant Safety

Use tenant-aware tests for tenant, auth, and API behavior. Preserve these invariants:

- `TenantMainMiddleware` stays first in middleware.
- `django_tenants.postgresql_backend` stays the database engine.
- Tenant and domain models stay in the public schema.
- Tenant-scoped models stay in tenant apps.
- JWT tenant claim validation stays covered.
- `auto_drop_schema = False` stays enabled.

## Agent Workflows

Use repo-local skills in `.agents/skills/` when working with Codex or another coding agent.

- Tenant, auth, migration, settings, or API work: use `django-tenant-implementation-strategy`.
- Code, Docker, CI, setup, or dependency handoff: use `code-change-verification`.
- Public behavior, command, or docs changes: use `docs-sync`.
- Public issue creation: use `oss-issue-curator`.

## Pull Request Expectations

- Keep changes focused.
- Include verification commands and results.
- Update docs when commands, setup, public behavior, or agent workflows change.
- Call out tenant isolation and auth risks explicitly.
