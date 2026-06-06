# Public Issues

These issues create visible maintenance structure for the `v0.2.0` and `v0.3.0` roadmap.

| Title | Labels | Why It Matters |
| --- | --- | --- |
| Add CI-backed tenant isolation smoke tests | `area: tenant-isolation`, `area: ci`, `priority: release`, `difficulty: intermediate` | Proves tenant isolation remains protected in CI. |
| Harden tenant provisioning command behavior | `area: tenant-isolation`, `priority: release`, `difficulty: intermediate` | Makes the first copied provisioning workflow safer. |
| Document public schema vs tenant schema request flow | `area: docs`, `area: tenant-isolation`, `difficulty: good first issue` | Gives contributors the core django-tenants mental model. |
| Add production deployment guide for Render or Fly.io | `area: docs`, `area: onboarding`, `difficulty: intermediate` | Helps users move beyond local Docker usage. |
| Add Codex PR review workflow prompt documentation | `area: agents`, `area: docs`, `difficulty: good first issue` | Makes optional Codex usage repeatable for maintainers. |
| Add docs-sync verification coverage | `area: agents`, `area: ci`, `area: docs`, `priority: release` | Keeps docs aligned with commands and behavior. |
| Add fixture factories for tenant-aware API tests | `area: tenant-isolation`, `difficulty: intermediate` | Reduces test duplication and improves future coverage. |
| Add security hardening checklist for tenant JWT behavior | `area: auth`, `area: docs`, `priority: release`, `difficulty: intermediate` | Creates a review standard for auth and tenant token safety. |
