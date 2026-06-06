# Setup

## Prerequisites

- Python 3.12.
- Docker with Docker Compose.
- PostgreSQL when running local Python commands outside Docker.

## Docker Quick Start

```bash
./scripts/bootstrap-env.sh
docker compose up --build
```

Create demo tenants:

```bash
docker compose exec web python manage.py setup_demo
```

## Local Python Setup

```bash
make setup
docker compose up -d db
make migrate
make demo
make run
```

## Environment Variables

Docker Compose reads `.env` when present and also provides safe local defaults. For Docker Compose, `POSTGRES_HOST` should be `db`. For local commands against the Compose database, use `POSTGRES_HOST=localhost` and `POSTGRES_PORT=5433`. The host port is controlled by `POSTGRES_HOST_PORT` and defaults to `5433` to avoid collisions with a local PostgreSQL server on `5432`.

## Common Failures

- `docker compose config` fails: run `./scripts/bootstrap-env.sh` and check Docker is installed.
- `pytest` cannot connect to PostgreSQL: run `docker compose up -d db` and use `POSTGRES_PORT=5433`.
- Tenant subdomain does not resolve: use a `.localhost` host such as `school1.localhost`.

## Commands

```bash
./scripts/bootstrap-env.sh
docker compose up --build
make setup
make test
make verify
```
