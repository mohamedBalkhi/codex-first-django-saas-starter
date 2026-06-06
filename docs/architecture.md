# Architecture

## Runtime Components

- `apps.tenants`: public-schema tenant and domain models.
- `apps.authentication`: tenant-aware JWT serializer and middleware.
- `apps.api`: example tenant-scoped REST API.
- `apps.core.tests`: shared tenant-aware API test base.
- `config.settings`: Django settings split for base, development, and production.

## Public Schema Flow

Requests for unmapped domains use the public schema because `SHOW_PUBLIC_IF_NO_TENANT_FOUND = True`. The public schema owns tenant and domain records, Django admin, and shared application configuration.

## Tenant Schema Flow

`django_tenants.middleware.main.TenantMainMiddleware` resolves the incoming host to a `Domain`, selects the related tenant schema, and then lets Django continue through the normal middleware and URL stack. Tenant-scoped API models such as `apps.api.models.Item` are stored inside the selected tenant schema.

## JWT Tenant Claim Flow

`TenantTokenObtainPairSerializer` adds the current `connection.schema_name` to issued access tokens. `TenantJWTValidationMiddleware` compares the token tenant claim with the active schema for Bearer-token requests and rejects cross-tenant token use.

## Testing Architecture

`apps.core.tests.TenantAPITestCase` combines `django-tenants` test isolation with DRF's API client. Tenant, auth, and API changes should use this base or an equivalent tenant-aware fixture.

## Extension Points

- Add tenant-specific models to tenant apps.
- Add public shared models to shared apps.
- Add provisioning behavior through management commands before exposing a public API.
- Add frontend integration through documented API routes rather than changing tenant resolution.

## Safety Invariants

- Keep `django_tenants.middleware.main.TenantMainMiddleware` first in middleware.
- Keep `django_tenants.postgresql_backend` as the database engine.
- Keep tenant and domain models in the public schema.
- Preserve tenant JWT claim validation.
- Do not add raw SQL that bypasses schema isolation unless docs and tests explain it.
- Keep `auto_drop_schema = False`.
