---
name: django-tenant-implementation-strategy
description: Use before editing tenant models, domain mapping, middleware, settings, migrations, authentication, or tenant-scoped APIs in this repo.
---

# Django Tenant Implementation Strategy

## Required Review

Before editing, identify:

1. Whether the change touches public schema, tenant schema, or both.
2. Whether migrations run with `migrate_schemas --shared`, `migrate_schemas`, or both.
3. Whether JWT tenant claims can cross tenant boundaries.
4. Which tenant-aware tests must be added or updated.

## Safety Rules

- `TenantMainMiddleware` stays first.
- `auto_drop_schema` stays `False`.
- Raw SQL must be avoided unless it is schema-qualified and tested.
- Tenant-specific models belong in tenant apps.
- Tenant and domain models belong in the public schema.

## Output

Return:

- Scope classification.
- Risk notes.
- Test plan.
- Migration plan.
- Verification commands.
