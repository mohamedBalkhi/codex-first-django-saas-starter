# Codex-First Django Multi-Tenant SaaS Starter

This is a Codex-first Django multi-tenant SaaS starter for building schema-isolated B2B applications with PostgreSQL, django-tenants, Django REST Framework, and agent-ready maintenance workflows.

## What This Is

This repository is a practical Django starter for teams that need one application to serve many customers with separate PostgreSQL schemas. It also includes repo-local instructions, skills, scripts, and GitHub workflows so humans and coding agents can maintain it with less rediscovery.

## Why It Exists

Most starter templates focus only on first-run setup. This one also treats maintenance as a first-class feature: tenant safety rules, verification commands, issue templates, docs checks, optional Codex prompts, and clear contributor workflows are included from the first clone.

## Features

- PostgreSQL schema isolation with `django-tenants`.
- Public-schema tenant and domain models.
- Tenant-scoped Django REST Framework example API.
- Tenant-aware Simple JWT token claims and validation.
- Docker Compose development environment.
- pytest coverage for auth, profile, and item APIs.
- Root `AGENTS.md` instructions for agentic coding tools.
- Repo-local skills for tenant strategy, verification, docs sync, issue curation, test coverage, and PR summaries.
- GitHub CI, issue templates, PR template, labels manifest, and optional Codex maintenance prompts.

## Quick Start With Docker

```bash
./scripts/bootstrap-env.sh
docker compose up --build
```

Then create demo tenants in another terminal:

```bash
docker compose exec web python manage.py setup_demo
```

Useful URLs after the server starts:

- Public admin: `http://localhost:8000/admin/`
- Tenant API example: `http://school1.localhost:8000/api/`

## Local Development

```bash
make setup
docker compose up -d db
make migrate
make demo
make run
```

For local Python commands, use `POSTGRES_HOST=localhost`. For Docker Compose, keep `POSTGRES_HOST=db`.
Docker Compose exposes PostgreSQL on host port `5433` by default to avoid collisions with a local PostgreSQL server on `5432`.

## Architecture At A Glance

- `apps/tenants/`: tenant and domain models in the public schema.
- `apps/authentication/`: tenant-aware JWT serializer and middleware.
- `apps/api/`: example tenant-scoped API.
- `apps/core/tests/`: reusable tenant-aware API test base.
- `config/settings/`: base, development, and production settings.
- `.agents/skills/`: repo-local agent workflows.

Read the full architecture guide in [docs/architecture.md](docs/architecture.md).

## Agent-Ready Maintenance

Start with [AGENTS.md](AGENTS.md). It defines the project map, safety rules, verification commands, and mandatory repo-local skill triggers.

The agent workflow guide is in [docs/agent-workflows.md](docs/agent-workflows.md). Codex prompts live under `.github/codex/prompts/` and are optional maintainer tooling. Normal contributors do not need OpenAI credentials.

## Testing And Verification

Run the core checks:

```bash
docker compose config
python manage.py check
pytest
./scripts/check-docs.sh
```

For full local verification:

```bash
./scripts/verify.sh
```

Read [docs/testing.md](docs/testing.md) for the tenant-aware testing model.

## Roadmap

The `v0.2.0` focus is the Codex-first maintenance foundation: instructions, skills, CI, docs, setup reliability, and curated public issues. See [docs/roadmap.md](docs/roadmap.md).

## Contributing

Read [CONTRIBUTING.md](CONTRIBUTING.md). Pull requests should include verification evidence and tenant safety notes when relevant.

## License

MIT. See [LICENSE](LICENSE).
