# Codex-First Django Multi-Tenant Starter Design

Date: 2026-06-06
Repo: `mohamedBalkhi/Django-Multi-Tenant-SaaS-Starter-Template`
Target release: `v0.2.0`

## Purpose

Turn the existing Django multi-tenant SaaS starter into a credible open-source
project that is useful on its own and distinct because it is designed for Codex
and other agentic coding workflows from the first clone.

The project should remain a concrete Django starter, not become an abstract
agent-workflow repository. The agent layer is the differentiator: it should make
the repo easier for humans and coding agents to understand, extend, test, review,
and maintain.

## Evidence Behind This Direction

The current repo already has useful foundations: Django, Django REST Framework,
`django-tenants`, JWT authentication, Docker, tests, MIT license, README,
contributing guide, topics, one fork, and recent traffic. Keeping the repo
preserves the existing public signal.

The OpenAI Codex for Open Source program says maintainers of active public
projects can apply, and that review considers repository usage, ecosystem
importance, and evidence of active maintenance:

- https://developers.openai.com/community/codex-for-oss
- https://openai.com/form/codex-for-oss/
- https://developers.openai.com/codex/codex-for-oss-terms

OpenAI's published OSS maintenance pattern for Codex uses repository-local
`AGENTS.md`, repo-local skills, optional scripts/references, and Codex GitHub
Action workflows for repeatable maintenance:

- https://developers.openai.com/blog/skills-agents-sdk
- https://developers.openai.com/codex/skills
- https://developers.openai.com/codex/github-action

Django and django-tenants docs support the current technical foundation:
tenant middleware first, PostgreSQL backend, tenant/domain models, and
tenant-aware testing.

## Success Criteria

The `v0.2.0` repo state is successful when all of these are true:

1. The repo clearly positions itself as a Codex-first Django multi-tenant SaaS
   starter in README, metadata, docs, and release notes.
2. A root `AGENTS.md` gives agents durable, concise project instructions:
   project map, commands, verification rules, security rules, compatibility
   rules, and mandatory repo-local skill triggers.
3. `.agents/skills/` contains narrow, repo-specific workflows with clear
   triggers, outputs, and optional helper scripts/references.
4. `.github/` contains CI, issue templates, PR template, labels documentation,
   and optional Codex GitHub Action prompts that can be enabled with an API key.
5. Setup friction is reduced: Docker Compose validates without manual hidden
   setup, Makefile uses portable commands, and local setup paths are documented.
6. Test and verification commands are explicit and reproducible locally and in
   CI.
7. Docs explain the architecture, tenant lifecycle, auth flow, testing model,
   extension path, release process, and agent workflow model.
8. At least eight high-quality public GitHub issues exist, each with a useful
   title, problem statement, acceptance criteria, labels, and beginner or
   roadmap value where appropriate.
9. Verification evidence proves `docker compose config`, Django checks, tests,
   CodeGraph indexing, docs consistency checks, and git status all meet the
   project bar.

## Non-Goals

- Do not start a new repository unless the maintainer explicitly approves it.
- Do not turn this into a generic agent workflow catalog detached from Django.
- Do not add a large frontend product surface for `v0.2.0`.
- Do not add billing, Stripe, team invitations, or production SaaS modules
  before the starter's maintenance and onboarding foundation is solid.
- Do not require Codex-specific paid services for ordinary users to use the
  Django starter.
- Do not claim OpenAI program eligibility, selection, or funding is guaranteed.

## Strategic Shape

The repo should be both:

1. A practical Django multi-tenant starter.
2. A reference implementation of how to make a Django repo agent-ready.

This combination is stronger than either option alone. A Django-only starter is
useful but not distinctive. A generic agent-workflow repo is interesting but
harder to justify as critical OSS. A concrete Django starter with reusable
maintenance workflows gives the project a specific ecosystem audience and a
clear reason to use Codex.

## Architecture

The runtime architecture stays deliberately small:

- `apps.tenants`: public-schema tenant and domain models plus admin.
- `apps.authentication`: tenant-aware JWT serializer and tenant-token validation.
- `apps.api`: example tenant-scoped model, serializers, views, URLs, and tests.
- `apps.core.tests`: shared tenant-aware test base.
- `config.settings`: split base, development, and production settings.
- `docker-compose.yml` and `Dockerfile`: local Postgres plus Django runtime.

The new agent-maintenance architecture is layered around the runtime:

- `AGENTS.md`: small mandatory instruction layer loaded by agents.
- `.agents/skills/<skill>/SKILL.md`: progressive-disclosure workflows for
  repeatable work.
- `.agents/skills/<skill>/scripts/`: optional deterministic helper commands.
- `.agents/skills/<skill>/references/`: longer project references kept out of
  default context.
- `.github/workflows/`: CI plus optional Codex workflows.
- `.github/codex/prompts/`: prompt files for Codex GitHub Action workflows.
- `docs/`: human-readable architecture, setup, maintenance, and release docs.

## Proposed Repo-Local Skills

### `django-tenant-implementation-strategy`

Trigger before editing tenant models, domain mapping, middleware, settings,
auth, migrations, or tenant-scoped APIs.

Output:

- Compatibility boundary.
- Required tests.
- Tenant isolation risks.
- Migration and schema safety notes.

### `code-change-verification`

Trigger when runtime code, tests, dependencies, Docker, CI, or setup behavior
changes.

Output:

- Exact commands run.
- Pass/fail results.
- Follow-up failures.
- Minimum handoff evidence.

Expected command stack:

- `python manage.py check`
- `pytest`
- `docker compose config`
- project-specific smoke command once implemented

### `docs-sync`

Trigger when code, commands, public behavior, setup, or workflow files change.

Output:

- Docs that are stale.
- Docs that need no change.
- Suggested updates.
- No direct generated-doc edits unless the user approves.

### `test-coverage-improver`

Trigger when adding behavior or preparing a release.

Output:

- Current coverage summary.
- Highest-risk untested behavior.
- Suggested test issues or implementation tasks.

### `pr-draft-summary`

Trigger before handing off a substantial branch.

Output:

- Branch name suggestion.
- PR title.
- PR body.
- Verification evidence.
- Risk and rollback notes.

### `oss-issue-curator`

Trigger when creating or reviewing public issues.

Output:

- Issue title.
- Problem statement.
- Acceptance criteria.
- Labels.
- Contributor difficulty.
- Maintainer notes.

## GitHub Automation

### Required CI

Add a normal CI workflow that does not require paid services:

- Check out code.
- Set up Python 3.12.
- Start PostgreSQL service.
- Install dependencies.
- Run Django checks.
- Run migrations.
- Run tests with coverage.
- Validate Docker Compose configuration.

This workflow is the public proof that the starter works.

### Optional Codex Workflows

Add prompt files and disabled or documented workflows for maintainers who add
`OPENAI_API_KEY`:

- Pull request review.
- Release readiness review.
- Docs sync review.
- Issue triage suggestion.

These workflows should be optional because ordinary contributors should not need
OpenAI credentials to contribute.

## Documentation Design

The documentation should have a clear reading path:

1. `README.md`: positioning, features, quick start, architecture summary,
   verification badge, and links.
2. `docs/architecture.md`: tenant request flow, schema isolation, auth token
   flow, public vs tenant URLs, and extension points.
3. `docs/setup.md`: Docker setup, local setup, common failures, and commands.
4. `docs/testing.md`: tenant-aware testing pattern, pytest config, CI behavior,
   coverage expectations.
5. `docs/agent-workflows.md`: how `AGENTS.md`, skills, CodeGraph, Playwright,
   Computer Use, and optional Codex Action fit together.
6. `docs/releasing.md`: versioning, changelog, release checks, GitHub release
   steps.
7. `docs/roadmap.md`: public roadmap and issue map.

Docs should be accurate rather than long. Every command in docs should be either
verified or marked as a maintainer-only optional workflow.

## Onboarding Friction To Fix

The current repo has several friction points that `v0.2.0` should address:

- `docker compose config` fails until `.env` exists.
- Makefile uses `docker-compose` instead of the modern `docker compose` form.
- Makefile hardcodes `python3.12`.
- Test commands assume a local Postgres setup without making that dependency
  obvious.
- `.github/` automation is missing.
- `CONTRIBUTING.md` references older repo names and aspirational docs.
- README is strong but should become the front door for both Django users and
  agent-assisted maintainers.

## Public Issues

Open at least eight issues after the repo has labels/templates in place. The
initial issue set should create visible maintenance structure:

1. Add CI-backed tenant isolation smoke tests.
2. Add tenant provisioning API or management command hardening.
3. Document public schema vs tenant schema request flow.
4. Add production deployment guide for a common target.
5. Add Codex PR review workflow prompt and maintainer setup docs.
6. Add docs-sync skill and verification script.
7. Add fixture factories for tenant-aware API tests.
8. Add release readiness checklist for `v0.2.0`.
9. Add security hardening checklist for tenant JWT behavior.
10. Add example frontend integration guide.

Only eight are required, but having ten candidates lets the maintainer choose
the strongest public set.

## Error Handling And Safety

Tenant and auth changes are high risk. Implementation should preserve:

- `TenantMainMiddleware` as the first middleware.
- PostgreSQL schema backend for tenant isolation.
- Tenant/domain models in the public schema.
- JWT tenant claim validation.
- No raw SQL that bypasses schema isolation without documented reason.
- `auto_drop_schema = False` for safety.

If verification reveals a tenant isolation or auth bug, pause feature work and
fix that before continuing public-polish work.

## Verification Plan

The final implementation must provide command output evidence for:

- `git status --short --ignored`
- `codegraph status` for this project
- `docker compose config`
- `python manage.py check`
- `pytest`
- CI workflow syntax and local YAML sanity checks where possible
- docs link/path consistency checks
- GitHub issue creation results

If local Docker or PostgreSQL is unavailable, the implementation may still
progress, but final completion cannot be claimed until the missing verification
is run or equivalent CI evidence is available.

## Implementation Phases

### Phase 1: Agent and OSS foundation

- Add `AGENTS.md`.
- Add repo-local skills and references.
- Add GitHub issue/PR/security/community templates.
- Add labels documentation.
- Add roadmap and release notes skeleton.

### Phase 2: Onboarding and verification

- Fix `.env` and Docker Compose onboarding.
- Make Makefile commands portable.
- Add CI.
- Add verification scripts if they reduce command drift.
- Run and repair checks.

### Phase 3: Documentation and release readiness

- Rewrite README.
- Add architecture, setup, testing, agent workflow, release, and roadmap docs.
- Add changelog or release notes for `v0.2.0`.
- Run docs-sync checks.

### Phase 4: Public maintenance signal

- Create labels if missing.
- Open at least eight curated issues.
- Prepare PR or release summary.
- Verify the repository state.

## Review Gate

This spec must be reviewed before writing the implementation plan. The next
artifact after approval is a detailed implementation plan, not code.
