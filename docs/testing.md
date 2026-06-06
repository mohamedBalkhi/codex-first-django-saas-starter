# Testing

## What The Tests Cover

The current pytest suite covers tenant-aware JWT token issuance, token refresh, profile responses, and CRUD behavior for the example tenant-scoped `Item` API.

## Tenant-Aware Test Base

Use `apps.core.tests.TenantAPITestCase` for tenant-aware API tests. It provides a fresh tenant schema and DRF API client so tests run through the same tenant routing assumptions as application requests.

## Running Tests Locally

Start PostgreSQL:

```bash
docker compose up -d db
```

Run tests:

```bash
POSTGRES_HOST=localhost pytest
```

## Running Tests In CI

GitHub Actions starts a PostgreSQL service, installs dependencies, validates Docker Compose, runs Django checks, migrates schemas, runs pytest, and checks docs.

## Coverage Expectations

Tenant, auth, and API changes need tenant-aware tests. Coverage should include tenant isolation behavior, JWT tenant claim behavior, public-schema boundaries, and user-visible API responses.
