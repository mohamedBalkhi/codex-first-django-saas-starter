# Codex-First Django Multi-Tenant Template Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Ship a verified `v0.2.0`-ready state for the existing Django multi-tenant SaaS starter that makes the repo useful to Django developers and first-class for Codex-assisted open-source maintenance.

**Architecture:** Keep the Django runtime small and stable while adding an agent-maintenance layer around it. Runtime changes focus on onboarding and verification only; agent, GitHub, docs, and public issue work make the repo visibly maintainable.

**Tech Stack:** Django 5, Django REST Framework, `django-tenants`, Simple JWT, PostgreSQL, Docker Compose, pytest, GitHub Actions, repo-local `AGENTS.md`, repo-local agent skills, optional Codex GitHub Action prompts.

---

## File Structure

Create and modify these areas:

- Root: `AGENTS.md`, `README.md`, `CONTRIBUTING.md`, `CHANGELOG.md`, `Makefile`, `docker-compose.yml`, `.env.example`, `.gitignore`.
- Agent skills: `.agents/skills/<skill>/SKILL.md`, plus `.agents/skills/code-change-verification/scripts/verify.sh`.
- GitHub automation: `.github/workflows/ci.yml`, `.github/workflows/codex-maintenance.yml`, `.github/codex/prompts/*.md`.
- GitHub community files: `.github/pull_request_template.md`, `.github/ISSUE_TEMPLATE/*.yml`, `.github/labels.yml`, `SECURITY.md`, `SUPPORT.md`, `CODE_OF_CONDUCT.md`.
- Docs: `docs/architecture.md`, `docs/setup.md`, `docs/testing.md`, `docs/agent-workflows.md`, `docs/releasing.md`, `docs/roadmap.md`, `docs/public-issues.md`.
- Scripts: `scripts/bootstrap-env.sh`, `scripts/check-docs.sh`, `scripts/verify.sh`.

The runtime app files under `apps/` and `config/` should remain stable unless a verification failure proves they need a small fix.

## Task 1: Create Verification And Bootstrap Scripts

**Files:**
- Create: `scripts/bootstrap-env.sh`
- Create: `scripts/check-docs.sh`
- Create: `scripts/verify.sh`
- Modify: `.gitignore`

- [ ] **Step 1: Add executable bootstrap script**

Create `scripts/bootstrap-env.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

if [ -f .env ]; then
  echo ".env already exists"
  exit 0
fi

cp .env.example .env
echo "Created .env from .env.example"
```

- [ ] **Step 2: Add docs consistency checker**

Create `scripts/check-docs.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

required_files=(
  "README.md"
  "CONTRIBUTING.md"
  "CHANGELOG.md"
  "AGENTS.md"
  "docs/architecture.md"
  "docs/setup.md"
  "docs/testing.md"
  "docs/agent-workflows.md"
  "docs/releasing.md"
  "docs/roadmap.md"
  "docs/public-issues.md"
)

for path in "${required_files[@]}"; do
  if [ ! -f "$path" ]; then
    echo "Missing required documentation file: $path"
    exit 1
  fi
done

required_terms=(
  "Codex-first"
  "django-tenants"
  "docker compose"
  "pytest"
  "AGENTS.md"
  "tenant isolation"
)

for term in "${required_terms[@]}"; do
  if ! grep -R --exclude-dir=.git --exclude-dir=.codegraph -F "$term" README.md docs AGENTS.md >/dev/null; then
    echo "Missing required documentation term: $term"
    exit 1
  fi
done

echo "Documentation consistency checks passed"
```

- [ ] **Step 3: Add one-command verification script**

Create `scripts/verify.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

./scripts/bootstrap-env.sh
docker compose config >/dev/null

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

POSTGRES_HOST="${POSTGRES_HOST:-localhost}" python manage.py check
POSTGRES_HOST="${POSTGRES_HOST:-localhost}" pytest
./scripts/check-docs.sh

echo "Local verification passed"
```

- [ ] **Step 4: Mark scripts executable**

Run:

```bash
chmod +x scripts/bootstrap-env.sh scripts/check-docs.sh scripts/verify.sh
```

Expected: command exits `0`.

- [ ] **Step 5: Ignore local environment artifacts**

Append these lines to `.gitignore`, then remove duplicates if any existing line already ignores the same path:

```gitignore
.venv/
.codegraph/
coverage.xml
```

- [ ] **Step 6: Verify check-docs fails before docs exist**

Run:

```bash
./scripts/check-docs.sh
```

Expected: fails with a missing documentation file message before later docs tasks are implemented.

- [ ] **Step 7: Commit**

Run:

```bash
git add .gitignore scripts/bootstrap-env.sh scripts/check-docs.sh scripts/verify.sh
git commit -m "chore: add verification scripts"
```

## Task 2: Fix Docker Compose And Makefile Onboarding

**Files:**
- Modify: `docker-compose.yml`
- Modify: `.env.example`
- Modify: `Makefile`

- [ ] **Step 1: Make Compose validate without `.env`**

In `docker-compose.yml`, replace every simple `env_file` list with optional env-file objects:

```yaml
    env_file:
      - path: .env
        required: false
```

Apply this to the `migrations` and `web` services.

- [ ] **Step 2: Add explicit web service environment defaults**

In `docker-compose.yml`, ensure both `migrations` and `web` define these environment values:

```yaml
      - DJANGO_SETTINGS_MODULE=config.settings.development
      - DJANGO_SECRET_KEY=${DJANGO_SECRET_KEY:-django-insecure-local-development-key}
      - DJANGO_DEBUG=${DJANGO_DEBUG:-True}
      - DJANGO_ALLOWED_HOSTS=${DJANGO_ALLOWED_HOSTS:-localhost,127.0.0.1,.localhost}
      - POSTGRES_DB=${POSTGRES_DB:-multitenant_db}
      - POSTGRES_USER=${POSTGRES_USER:-postgres}
      - POSTGRES_PASSWORD=${POSTGRES_PASSWORD:-postgres}
      - POSTGRES_HOST=db
      - POSTGRES_PORT=5432
```

Keep `PYTHONUNBUFFERED=1` and `WERKZEUG_DEBUG_PIN=off` on `web`.

- [ ] **Step 3: Make `.env.example` shell-safe**

Replace the `POSTGRES_DB` line in `.env.example` with:

```dotenv
POSTGRES_DB=multitenant_db
```

Add this comment above the database block:

```dotenv
# For Docker Compose, POSTGRES_HOST should stay "db".
# For local Python commands against a host PostgreSQL instance, use POSTGRES_HOST=localhost.
```

- [ ] **Step 4: Replace Makefile with portable command variables**

Update the top of `Makefile` to define:

```make
PYTHON ?= python3
VENV ?= .venv
DOCKER_COMPOSE ?= docker compose
PIP := $(VENV)/bin/python -m pip
MANAGE := $(VENV)/bin/python manage.py
PYTEST := $(VENV)/bin/pytest

.PHONY: help bootstrap setup migrate run test test-cov verify check-docs clean docker-up docker-down docker-logs docker-rebuild docker-shell demo shell shell-plus superuser
```

Then make these target behaviors true:

```make
bootstrap:
	./scripts/bootstrap-env.sh

setup: bootstrap
	$(PYTHON) -m venv $(VENV)
	$(PIP) install --upgrade pip
	$(PIP) install -r requirements.txt

verify:
	./scripts/verify.sh

check-docs:
	./scripts/check-docs.sh

test:
	POSTGRES_HOST=localhost $(PYTEST)

docker-up:
	$(DOCKER_COMPOSE) up --build

docker-down:
	$(DOCKER_COMPOSE) down

docker-logs:
	$(DOCKER_COMPOSE) logs -f web

docker-rebuild:
	$(DOCKER_COMPOSE) down
	$(DOCKER_COMPOSE) build --no-cache
	$(DOCKER_COMPOSE) up

docker-shell:
	$(DOCKER_COMPOSE) exec web python manage.py shell_plus
```

Preserve the existing user-facing help categories, but update printed commands to mention `.venv` and `docker compose`.

- [ ] **Step 5: Verify Compose now validates without `.env`**

Run:

```bash
rm -f .env
docker compose config >/dev/null
```

Expected: command exits `0`.

- [ ] **Step 6: Verify bootstrap recreates `.env`**

Run:

```bash
./scripts/bootstrap-env.sh
test -f .env
```

Expected: command exits `0` and prints `Created .env from .env.example`.

- [ ] **Step 7: Commit**

Run:

```bash
git add Makefile docker-compose.yml .env.example
git commit -m "chore: improve local onboarding"
```

## Task 3: Add Root Agent Instructions

**Files:**
- Create: `AGENTS.md`

- [ ] **Step 1: Create root AGENTS.md**

Create `AGENTS.md`:

```markdown
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
```

- [ ] **Step 2: Verify instruction terms exist**

Run:

```bash
grep -F "Codex-first Django multi-tenant SaaS starter" AGENTS.md
grep -F "TenantMainMiddleware" AGENTS.md
```

Expected: both commands print matching lines.

- [ ] **Step 3: Commit**

Run:

```bash
git add AGENTS.md
git commit -m "docs: add root agent instructions"
```

## Task 4: Add Repo-Local Agent Skills

**Files:**
- Create: `.agents/skills/django-tenant-implementation-strategy/SKILL.md`
- Create: `.agents/skills/code-change-verification/SKILL.md`
- Create: `.agents/skills/docs-sync/SKILL.md`
- Create: `.agents/skills/test-coverage-improver/SKILL.md`
- Create: `.agents/skills/pr-draft-summary/SKILL.md`
- Create: `.agents/skills/oss-issue-curator/SKILL.md`
- Create: `.agents/skills/code-change-verification/scripts/verify.sh`

- [ ] **Step 1: Create tenant strategy skill**

Create `.agents/skills/django-tenant-implementation-strategy/SKILL.md`:

```markdown
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
```

- [ ] **Step 2: Create code verification skill**

Create `.agents/skills/code-change-verification/SKILL.md`:

```markdown
---
name: code-change-verification
description: Use before handing off changes to runtime code, tests, Docker, CI, dependencies, setup scripts, or documentation commands.
---

# Code Change Verification

## Workflow

1. Run `docker compose config`.
2. Run `python manage.py check`.
3. Run `pytest`.
4. Run `./scripts/check-docs.sh`.
5. Run `git status --short --ignored`.

## Output

Return:

- Commands run.
- Pass/fail result for each command.
- Any skipped command and the exact reason.
- Remaining risk.
```

- [ ] **Step 3: Add verification skill helper**

Create `.agents/skills/code-change-verification/scripts/verify.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../../.." && pwd)"
cd "$ROOT_DIR"

./scripts/verify.sh
```

Run:

```bash
chmod +x .agents/skills/code-change-verification/scripts/verify.sh
```

- [ ] **Step 4: Create docs sync skill**

Create `.agents/skills/docs-sync/SKILL.md`:

```markdown
---
name: docs-sync
description: Use when code, commands, setup, tests, public behavior, GitHub automation, or agent workflows change.
---

# Docs Sync

## Checks

Review these files for stale commands and behavior:

- `README.md`
- `CONTRIBUTING.md`
- `docs/setup.md`
- `docs/testing.md`
- `docs/architecture.md`
- `docs/agent-workflows.md`
- `docs/releasing.md`
- `docs/roadmap.md`

## Output

Return:

- Docs requiring updates.
- Docs already current.
- Exact commands or claims that changed.
- Suggested edits.

Do not invent unverified commands.
```

- [ ] **Step 5: Create remaining skills**

Create `.agents/skills/test-coverage-improver/SKILL.md`:

```markdown
---
name: test-coverage-improver
description: Use before adding behavior or preparing a release to identify high-value Django, tenant, auth, and API tests.
---

# Test Coverage Improver

## Review Targets

- Tenant schema isolation.
- JWT tenant claim validation.
- Public schema and tenant URL routing.
- Tenant provisioning commands.
- API authentication behavior.

## Output

Return:

- Current test command.
- Missing behavior.
- Recommended test names.
- Risk if skipped.
```

Create `.agents/skills/pr-draft-summary/SKILL.md`:

```markdown
---
name: pr-draft-summary
description: Use before publishing or handing off a substantial branch.
---

# PR Draft Summary

## Output Format

Return:

- PR title.
- Summary.
- Files changed by category.
- Verification commands and results.
- Risk and rollback notes.
- Follow-up issues.
```

Create `.agents/skills/oss-issue-curator/SKILL.md`:

```markdown
---
name: oss-issue-curator
description: Use before creating public GitHub issues for this repository.
---

# OSS Issue Curator

## Issue Quality Bar

Each issue must include:

- Problem.
- Why it matters.
- Acceptance criteria.
- Suggested labels.
- Contributor difficulty.
- Maintainer notes when needed.

Avoid issues that only say "improve docs" or "make better".
```

- [ ] **Step 6: Verify all skill files are discoverable**

Run:

```bash
find .agents/skills -name SKILL.md | sort
```

Expected: prints six `SKILL.md` paths.

- [ ] **Step 7: Commit**

Run:

```bash
git add .agents
git commit -m "docs: add repo-local agent skills"
```

## Task 5: Add GitHub CI, Templates, Labels, And Optional Codex Prompts

**Files:**
- Create: `.github/workflows/ci.yml`
- Create: `.github/workflows/codex-maintenance.yml`
- Create: `.github/codex/prompts/pr-review.md`
- Create: `.github/codex/prompts/docs-sync.md`
- Create: `.github/codex/prompts/release-readiness.md`
- Create: `.github/codex/prompts/issue-triage.md`
- Create: `.github/pull_request_template.md`
- Create: `.github/ISSUE_TEMPLATE/bug_report.yml`
- Create: `.github/ISSUE_TEMPLATE/feature_request.yml`
- Create: `.github/ISSUE_TEMPLATE/docs.yml`
- Create: `.github/ISSUE_TEMPLATE/maintenance.yml`
- Create: `.github/ISSUE_TEMPLATE/config.yml`
- Create: `.github/labels.yml`
- Create: `SECURITY.md`
- Create: `SUPPORT.md`
- Create: `CODE_OF_CONDUCT.md`

- [ ] **Step 1: Add CI workflow**

Create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:17-alpine
        env:
          POSTGRES_DB: multitenant_db
          POSTGRES_USER: postgres
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd "pg_isready -U postgres"
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5
    env:
      DJANGO_SETTINGS_MODULE: config.settings.development
      DJANGO_SECRET_KEY: django-insecure-ci-key
      DJANGO_DEBUG: "True"
      DJANGO_ALLOWED_HOSTS: localhost,127.0.0.1,.localhost
      POSTGRES_DB: multitenant_db
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
      POSTGRES_HOST: localhost
      POSTGRES_PORT: "5432"
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - name: Install dependencies
        run: |
          python -m pip install --upgrade pip
          python -m pip install -r requirements.txt
      - name: Validate Docker Compose
        run: docker compose config >/dev/null
      - name: Run Django checks
        run: python manage.py check
      - name: Run migrations
        run: |
          python manage.py migrate_schemas --shared
          python manage.py migrate_schemas
      - name: Run tests
        run: pytest --cov=apps --cov-report=term-missing --cov-report=xml
      - name: Check docs
        run: ./scripts/check-docs.sh
```

- [ ] **Step 2: Add optional manual Codex workflow**

Create `.github/workflows/codex-maintenance.yml`:

```yaml
name: Codex Maintenance

on:
  workflow_dispatch:
    inputs:
      mode:
        description: Maintenance prompt to run
        required: true
        type: choice
        options:
          - pr-review
          - docs-sync
          - release-readiness
          - issue-triage

jobs:
  instructions:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Show prompt location
        run: |
          echo "This workflow documents the manual entrypoint for maintainers who enable the OpenAI Codex GitHub Action."
          echo "Prompt mode: ${{ inputs.mode }}"
          echo "Prompt files live in .github/codex/prompts/"
          echo "Do not add OPENAI_API_KEY unless you intentionally enable Codex automation."
```

This workflow is intentionally safe and manual. If OpenAI's Codex Action is enabled later, replace the `instructions` job with the official action invocation.

- [ ] **Step 3: Add Codex prompt files**

Create `.github/codex/prompts/pr-review.md`:

```markdown
# Codex PR Review Prompt

Review this pull request for tenant isolation, authentication safety, setup friction, docs drift, and test coverage. Prioritize concrete bugs and missing verification. Do not request Codex-only behavior for normal contributors.
```

Create `.github/codex/prompts/docs-sync.md`:

```markdown
# Codex Docs Sync Prompt

Compare changed code, commands, Docker files, CI, scripts, and agent skills against README and docs. Report stale commands, missing links, and claims that are not verified by scripts or tests.
```

Create `.github/codex/prompts/release-readiness.md`:

```markdown
# Codex Release Readiness Prompt

Assess whether the branch is ready for a `v0.2.0` release. Check CI, local verification commands, docs completeness, GitHub templates, public issue quality, and changelog accuracy.
```

Create `.github/codex/prompts/issue-triage.md`:

```markdown
# Codex Issue Triage Prompt

Classify new issues by area, difficulty, maintainer priority, and whether the issue needs reproduction. Suggest labels and ask for missing details when acceptance criteria are unclear.
```

- [ ] **Step 4: Add PR template**

Create `.github/pull_request_template.md`:

```markdown
## Summary

## Verification

- [ ] `docker compose config`
- [ ] `python manage.py check`
- [ ] `pytest`
- [ ] `./scripts/check-docs.sh`

## Tenant Safety

- [ ] Tenant middleware order unchanged or intentionally reviewed.
- [ ] JWT tenant claim behavior unchanged or tested.
- [ ] Public-schema and tenant-schema behavior documented.

## Docs

- [ ] README/docs updated or not needed.
- [ ] Agent workflows updated or not needed.
```

- [ ] **Step 5: Add issue templates**

Create `.github/ISSUE_TEMPLATE/bug_report.yml`:

```yaml
name: Bug report
description: Report a reproducible problem in the starter.
title: "bug: "
labels: ["status: needs triage"]
body:
  - type: textarea
    id: summary
    attributes:
      label: Summary
      description: What broke?
    validations:
      required: true
  - type: textarea
    id: reproduce
    attributes:
      label: Reproduction
      description: Commands, tenant/domain used, and observed result.
    validations:
      required: true
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance criteria
      description: What must be true for this issue to be closed?
    validations:
      required: true
```

Create `.github/ISSUE_TEMPLATE/feature_request.yml`:

```yaml
name: Feature request
description: Propose a scoped improvement to the starter.
title: "feat: "
labels: ["status: needs triage"]
body:
  - type: textarea
    id: problem
    attributes:
      label: Problem
      description: What concrete problem should this solve?
    validations:
      required: true
  - type: textarea
    id: approach
    attributes:
      label: Suggested approach
      description: Describe the smallest useful implementation.
    validations:
      required: true
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance criteria
      description: List observable outcomes and verification commands.
    validations:
      required: true
```

Create `.github/ISSUE_TEMPLATE/docs.yml`:

```yaml
name: Documentation issue
description: Report stale, missing, or confusing documentation.
title: "docs: "
labels: ["status: needs triage", "area: docs"]
body:
  - type: textarea
    id: location
    attributes:
      label: Location
      description: Link or path to the affected documentation.
    validations:
      required: true
  - type: textarea
    id: problem
    attributes:
      label: Problem
      description: What is stale, missing, or confusing?
    validations:
      required: true
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance criteria
      description: What docs change would close this issue?
    validations:
      required: true
```

Create `.github/ISSUE_TEMPLATE/maintenance.yml`:

```yaml
name: Maintenance task
description: Track CI, release, dependency, testing, or agent-workflow work.
title: "chore: "
labels: ["status: needs triage"]
body:
  - type: textarea
    id: task
    attributes:
      label: Task
      description: What maintenance work is needed?
    validations:
      required: true
  - type: textarea
    id: risk
    attributes:
      label: Risk
      description: What breaks if this is skipped?
    validations:
      required: true
  - type: textarea
    id: acceptance-criteria
    attributes:
      label: Acceptance criteria
      description: What commands or evidence prove completion?
    validations:
      required: true
```

Create `.github/ISSUE_TEMPLATE/config.yml`:

```yaml
blank_issues_enabled: false
contact_links:
  - name: Security reports
    url: https://github.com/mohamedBalkhi
    about: Report tenant isolation or authentication vulnerabilities privately through the maintainer profile until GitHub private vulnerability reporting is enabled.
```

- [ ] **Step 6: Add labels manifest**

Create `.github/labels.yml`:

```yaml
- name: "area: agents"
  color: "5319e7"
  description: "Codex, AGENTS.md, repo-local skills, and automation workflows"
- name: "area: tenant-isolation"
  color: "0052cc"
  description: "django-tenants, schemas, domains, and tenant safety"
- name: "area: auth"
  color: "d73a4a"
  description: "JWT, permissions, and authentication behavior"
- name: "area: docs"
  color: "0075ca"
  description: "README, setup, architecture, testing, and release docs"
- name: "area: ci"
  color: "0e8a16"
  description: "GitHub Actions, verification scripts, and test automation"
- name: "area: onboarding"
  color: "fbca04"
  description: "First clone, Docker, setup, and developer experience"
- name: "difficulty: good first issue"
  color: "7057ff"
  description: "Small scoped contribution suitable for first-time contributors"
- name: "difficulty: intermediate"
  color: "c5def5"
  description: "Requires project context but has clear acceptance criteria"
- name: "priority: release"
  color: "b60205"
  description: "Needed for the next release"
- name: "status: needs triage"
  color: "ededed"
  description: "Needs maintainer review before implementation"
```

- [ ] **Step 7: Add community files**

Create `SECURITY.md`:

```markdown
# Security Policy

## Supported Versions

The `main` branch and the latest tagged release are supported for security reports.

## Reporting A Vulnerability

Do not open a public issue for vulnerabilities that expose tenant isolation, JWT authentication, schema routing, credentials, or deployment secrets.

Until GitHub private vulnerability reporting is enabled for this repository, contact the maintainer through the private contact channel listed on the GitHub profile: https://github.com/mohamedBalkhi

Please include:

- Affected component.
- Reproduction steps.
- Expected impact.
- Whether tenant data can cross schema boundaries.
```

Create `SUPPORT.md`:

```markdown
# Support

Use GitHub issues for bugs, documentation gaps, and scoped feature requests.

Before opening an issue:

1. Run `./scripts/bootstrap-env.sh`.
2. Run `docker compose config`.
3. Run `python manage.py check` or `pytest` when relevant.
4. Include the command output in the issue.

Security-sensitive tenant isolation or authentication reports belong in the private security channel described in `SECURITY.md`.
```

Create `CODE_OF_CONDUCT.md`:

```markdown
# Code Of Conduct

Contributors are expected to be direct, respectful, and specific.

Acceptable behavior:

- Discuss code, tests, docs, and tradeoffs with evidence.
- Assume good intent while asking for concrete reproduction steps.
- Keep feedback tied to the repository and the issue or pull request.

Unacceptable behavior:

- Harassment, threats, or personal attacks.
- Publishing private security details before a fix is available.
- Repeated off-topic comments that block maintainers or contributors.

Maintainers may edit, hide, or remove comments and issues that violate this policy.
```

- [ ] **Step 8: Verify workflow YAML parses through Docker Compose-independent checks**

Run:

```bash
python - <<'PY'
from pathlib import Path
for path in Path('.github/workflows').glob('*.yml'):
    text = path.read_text()
    assert 'name:' in text, path
    assert 'on:' in text, path
print('workflow text checks passed')
PY
```

Expected: prints `workflow text checks passed`.

- [ ] **Step 9: Commit**

Run:

```bash
git add .github SECURITY.md SUPPORT.md CODE_OF_CONDUCT.md
git commit -m "chore: add github maintenance foundation"
```

## Task 6: Rewrite Documentation For The Codex-First Positioning

**Files:**
- Modify: `README.md`
- Modify: `CONTRIBUTING.md`
- Create: `CHANGELOG.md`
- Create: `docs/architecture.md`
- Create: `docs/setup.md`
- Create: `docs/testing.md`
- Create: `docs/agent-workflows.md`
- Create: `docs/releasing.md`
- Create: `docs/roadmap.md`
- Create: `docs/public-issues.md`

- [ ] **Step 1: Rewrite README around the new identity**

Update `README.md` to include these sections in order:

```markdown
# Codex-First Django Multi-Tenant SaaS Starter

## What This Is

## Why It Exists

## Features

## Quick Start With Docker

## Local Development

## Architecture At A Glance

## Agent-Ready Maintenance

## Testing And Verification

## Roadmap

## Contributing

## License
```

The first paragraph must contain this sentence:

```markdown
This is a Codex-first Django multi-tenant SaaS starter for building schema-isolated B2B applications with PostgreSQL, django-tenants, Django REST Framework, and agent-ready maintenance workflows.
```

- [ ] **Step 2: Update CONTRIBUTING**

Replace old repository names with the current repository name and add these contribution rules:

```markdown
- Run `./scripts/bootstrap-env.sh` before local verification.
- Run `docker compose config`, `python manage.py check`, `pytest`, and `./scripts/check-docs.sh` before opening a PR.
- Use tenant-aware tests for tenant, auth, and API behavior.
- Use repo-local skills in `.agents/skills/` when working with Codex or another coding agent.
```

- [ ] **Step 3: Add architecture doc**

Create `docs/architecture.md` with sections:

```markdown
# Architecture

## Runtime Components

## Public Schema Flow

## Tenant Schema Flow

## JWT Tenant Claim Flow

## Testing Architecture

## Extension Points

## Safety Invariants
```

The safety invariants section must list the six tenant safety rules from `AGENTS.md`.

- [ ] **Step 4: Add setup doc**

Create `docs/setup.md` with sections:

```markdown
# Setup

## Prerequisites

## Docker Quick Start

## Local Python Setup

## Environment Variables

## Common Failures

## Commands
```

Include exact commands:

```bash
./scripts/bootstrap-env.sh
docker compose up --build
make setup
make test
make verify
```

- [ ] **Step 5: Add testing doc**

Create `docs/testing.md` with sections:

```markdown
# Testing

## What The Tests Cover

## Tenant-Aware Test Base

## Running Tests Locally

## Running Tests In CI

## Coverage Expectations
```

Name `apps.core.tests.TenantAPITestCase` and explain that tenant, auth, and API changes need tenant-aware tests.

- [ ] **Step 6: Add agent workflow doc**

Create `docs/agent-workflows.md` with sections:

```markdown
# Agent Workflows

## Root Instructions

## Repo-Local Skills

## CodeGraph

## Optional Codex GitHub Action Prompts

## Playwright And Computer Use

## Handoff Evidence
```

State that Playwright and Computer Use are optional tools and not required for ordinary Django backend contributions.

- [ ] **Step 7: Add release and roadmap docs**

Create `docs/releasing.md` with a `v0.2.0` release checklist covering CI, local verification, changelog, docs, issues, and GitHub release notes.

Create `docs/roadmap.md` with three sections:

```markdown
# Roadmap

## v0.2.0: Codex-First Maintenance Foundation

## v0.3.0: Stronger Tenant Provisioning

## Future Ideas
```

- [ ] **Step 8: Add public issue tracking doc**

Create `docs/public-issues.md` listing the eight issue titles from Task 9, their labels, and why each one matters.

- [ ] **Step 9: Add changelog**

Create `CHANGELOG.md`:

```markdown
# Changelog

## v0.2.0 - Unreleased

- Repositioned the project as a Codex-first Django multi-tenant SaaS starter.
- Added repo-local agent instructions and skills.
- Added GitHub CI, templates, labels, and optional Codex maintenance prompts.
- Improved Docker Compose and local setup verification.
- Added architecture, setup, testing, agent workflow, release, roadmap, and public issue docs.

## v0.1.0

- Initial Django multi-tenant SaaS starter with PostgreSQL schema isolation, JWT authentication, Docker, and example tenant-scoped API.
```

- [ ] **Step 10: Verify docs consistency now passes**

Run:

```bash
./scripts/check-docs.sh
```

Expected: prints `Documentation consistency checks passed`.

- [ ] **Step 11: Commit**

Run:

```bash
git add README.md CONTRIBUTING.md CHANGELOG.md docs
git commit -m "docs: document codex-first starter workflow"
```

## Task 7: Add Release-Ready Runtime Verification

**Files:**
- Modify: `pytest.ini`
- Modify: `requirements.txt`
- Test existing: `apps/api/tests/test_items.py`, `apps/api/tests/test_profile.py`, `apps/authentication/tests/test_auth.py`

- [ ] **Step 1: Keep test configuration explicit**

Update `pytest.ini` so `addopts` includes XML coverage for CI:

```ini
    --cov-report=xml
```

- [ ] **Step 2: Run Docker Compose validation**

Run:

```bash
docker compose config >/dev/null
```

Expected: exits `0`.

- [ ] **Step 3: Run Django check**

Run:

```bash
source .venv/bin/activate
POSTGRES_HOST=localhost python manage.py check
```

Expected: exits `0` with no Django system check issues.

- [ ] **Step 4: Run tests**

Run:

```bash
source .venv/bin/activate
POSTGRES_HOST=localhost pytest
```

Expected: exits `0`. If this fails because PostgreSQL is not running, start the database:

```bash
docker compose up -d db
```

Then rerun the same `pytest` command.

- [ ] **Step 5: Fix only proven failures**

If Step 3 or Step 4 fails, make the smallest runtime or configuration change that directly addresses the failure. Preserve tenant middleware order, tenant/domain public schema placement, JWT tenant claim validation, and `auto_drop_schema = False`.

- [ ] **Step 6: Commit if runtime or test config changed**

If files changed, run:

```bash
git add pytest.ini requirements.txt apps config
git commit -m "test: verify release readiness"
```

If no files changed, do not create an empty commit.

## Task 8: Prepare GitHub Labels And Public Issues

**Files:**
- Use: `.github/labels.yml`
- Use: `docs/public-issues.md`

- [ ] **Step 1: Confirm GitHub auth and repository**

Run:

```bash
gh auth status
gh repo view mohamedBalkhi/Django-Multi-Tenant-SaaS-Starter-Template --json nameWithOwner,url
```

Expected: authenticated as `mohamedBalkhi`, repo URL prints.

- [ ] **Step 2: Create labels**

Run these commands. If a label already exists, update it with the same color and description.

```bash
gh label create "area: agents" --color "5319e7" --description "Codex, AGENTS.md, repo-local skills, and automation workflows" || gh label edit "area: agents" --color "5319e7" --description "Codex, AGENTS.md, repo-local skills, and automation workflows"
gh label create "area: tenant-isolation" --color "0052cc" --description "django-tenants, schemas, domains, and tenant safety" || gh label edit "area: tenant-isolation" --color "0052cc" --description "django-tenants, schemas, domains, and tenant safety"
gh label create "area: auth" --color "d73a4a" --description "JWT, permissions, and authentication behavior" || gh label edit "area: auth" --color "d73a4a" --description "JWT, permissions, and authentication behavior"
gh label create "area: docs" --color "0075ca" --description "README, setup, architecture, testing, and release docs" || gh label edit "area: docs" --color "0075ca" --description "README, setup, architecture, testing, and release docs"
gh label create "area: ci" --color "0e8a16" --description "GitHub Actions, verification scripts, and test automation" || gh label edit "area: ci" --color "0e8a16" --description "GitHub Actions, verification scripts, and test automation"
gh label create "area: onboarding" --color "fbca04" --description "First clone, Docker, setup, and developer experience" || gh label edit "area: onboarding" --color "fbca04" --description "First clone, Docker, setup, and developer experience"
gh label create "difficulty: good first issue" --color "7057ff" --description "Small scoped contribution suitable for first-time contributors" || gh label edit "difficulty: good first issue" --color "7057ff" --description "Small scoped contribution suitable for first-time contributors"
gh label create "difficulty: intermediate" --color "c5def5" --description "Requires project context but has clear acceptance criteria" || gh label edit "difficulty: intermediate" --color "c5def5" --description "Requires project context but has clear acceptance criteria"
gh label create "priority: release" --color "b60205" --description "Needed for the next release" || gh label edit "priority: release" --color "b60205" --description "Needed for the next release"
gh label create "status: needs triage" --color "ededed" --description "Needs maintainer review before implementation" || gh label edit "status: needs triage" --color "ededed" --description "Needs maintainer review before implementation"
```

- [ ] **Step 3: Create eight public issues**

Run these commands:

```bash
gh issue create \
  --title "Add CI-backed tenant isolation smoke tests" \
  --label "area: tenant-isolation" \
  --label "area: ci" \
  --label "priority: release" \
  --label "difficulty: intermediate" \
  --body "$(cat <<'EOF'
## Problem

The current test suite covers tenant-aware API behavior, but the CI plan needs a focused smoke test that proves data created in one tenant schema is not visible from another tenant schema.

## Why it matters

Tenant isolation is the core safety claim of this starter. A visible CI-backed smoke test gives contributors and users confidence that future changes do not weaken schema isolation.

## Acceptance criteria

- [ ] A tenant isolation smoke test creates data in two tenant schemas and proves cross-tenant reads are blocked.
- [ ] The test runs in GitHub Actions.
- [ ] The relevant verification command is documented.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Harden tenant provisioning command behavior" \
  --label "area: tenant-isolation" \
  --label "priority: release" \
  --label "difficulty: intermediate" \
  --body "$(cat <<'EOF'
## Problem

The starter includes demo tenant provisioning, but maintainers need clearer behavior for duplicate schema names, duplicate domains, invalid schema names, and missing initial users.

## Why it matters

Tenant provisioning is the first risky operation many users will copy. Clear validation and tests reduce the chance of broken schemas or confusing onboarding failures.

## Acceptance criteria

- [ ] Provisioning behavior for duplicate schema names and domains is defined.
- [ ] Invalid schema names fail with a useful error.
- [ ] The command behavior is covered by tests or documented as a future API task.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Document public schema vs tenant schema request flow" \
  --label "area: docs" \
  --label "area: tenant-isolation" \
  --label "difficulty: good first issue" \
  --body "$(cat <<'EOF'
## Problem

The project needs a concise explanation of how localhost, tenant subdomains, public schema routes, tenant routes, and `TenantMainMiddleware` interact during a request.

## Why it matters

New contributors need this mental model before editing URLs, middleware, auth, or tenant-scoped APIs. Clear docs make Codex and human reviews more accurate.

## Acceptance criteria

- [ ] The docs explain public schema request handling.
- [ ] The docs explain tenant schema request handling.
- [ ] The docs name the files that define URL routing and middleware.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Add production deployment guide for Render or Fly.io" \
  --label "area: docs" \
  --label "area: onboarding" \
  --label "difficulty: intermediate" \
  --body "$(cat <<'EOF'
## Problem

The starter explains local Docker usage, but it does not yet show how to deploy the schema-based Postgres setup to a common hosting platform.

## Why it matters

Deployment guidance makes the template more useful to real SaaS builders and helps distinguish development-only settings from production requirements.

## Acceptance criteria

- [ ] The guide chooses Render or Fly.io and states why.
- [ ] The guide covers environment variables, Postgres, migrations, static files, and allowed hosts.
- [ ] The guide calls out tenant domain setup.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Add Codex PR review workflow prompt documentation" \
  --label "area: agents" \
  --label "area: docs" \
  --label "difficulty: good first issue" \
  --body "$(cat <<'EOF'
## Problem

The repo includes optional Codex maintenance prompts, but maintainers need clear docs for when to run the PR review prompt and what evidence it should produce.

## Why it matters

The project is Codex-first only if agent workflows are repeatable and understandable. Prompt documentation keeps the workflow useful without requiring Codex for normal contributors.

## Acceptance criteria

- [ ] Docs explain the PR review prompt purpose.
- [ ] Docs explain required inputs and expected output.
- [ ] Docs state that OpenAI credentials are optional maintainer tooling.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Add docs-sync verification coverage" \
  --label "area: agents" \
  --label "area: ci" \
  --label "area: docs" \
  --label "priority: release" \
  --body "$(cat <<'EOF'
## Problem

The docs-sync skill needs deterministic verification coverage so stale docs and missing required docs are caught before release.

## Why it matters

Agent-ready maintenance depends on docs that track commands and behavior. A lightweight docs check makes drift visible in CI and local verification.

## Acceptance criteria

- [ ] `./scripts/check-docs.sh` validates required docs and key project terms.
- [ ] CI runs the docs check.
- [ ] The docs explain how to run the check locally.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Add fixture factories for tenant-aware API tests" \
  --label "area: tenant-isolation" \
  --label "difficulty: intermediate" \
  --body "$(cat <<'EOF'
## Problem

The tests create users and tenant data directly in several places. Factory helpers would make future tenant-aware API tests easier to write and review.

## Why it matters

Cleaner test setup reduces copy-paste errors and helps contributors add coverage for tenant isolation, auth, and API behavior.

## Acceptance criteria

- [ ] Factory helpers are added for tenant users and example API items.
- [ ] Existing API tests use the helpers where it reduces duplication.
- [ ] Tenant schema behavior remains explicit in tests.
- [ ] The issue can be closed by one focused PR.
EOF
)"

gh issue create \
  --title "Add security hardening checklist for tenant JWT behavior" \
  --label "area: auth" \
  --label "area: docs" \
  --label "priority: release" \
  --label "difficulty: intermediate" \
  --body "$(cat <<'EOF'
## Problem

The tenant-aware JWT behavior is central to the starter, but the repo needs a security checklist for token claims, tenant mismatch behavior, token refresh, and public-schema boundaries.

## Why it matters

JWT and tenant isolation mistakes can become data isolation bugs. A checklist gives maintainers and contributors a shared review standard.

## Acceptance criteria

- [ ] The checklist covers tenant claim creation and validation.
- [ ] The checklist covers cross-tenant token misuse.
- [ ] The checklist covers token refresh and public-schema behavior.
- [ ] The issue can be closed by one focused PR.
EOF
)"
```

- [ ] **Step 4: Verify issues exist**

Run:

```bash
gh issue list --limit 20 --json number,title,labels --jq '.[] | {number,title,labels:[.labels[].name]}'
```

Expected: the eight issue titles appear.

## Task 9: Update Repository Metadata And Prepare Release Notes

**Files:**
- Modify: `CHANGELOG.md`
- Use: GitHub repository metadata

- [ ] **Step 1: Update GitHub description and topics**

Run:

```bash
gh repo edit mohamedBalkhi/Django-Multi-Tenant-SaaS-Starter-Template \
  --description "Codex-first Django multi-tenant SaaS starter with PostgreSQL schema isolation, DRF, JWT, Docker, CI, and repo-local agent workflows." \
  --add-topic codex \
  --add-topic agentic-workflows \
  --add-topic django \
  --add-topic django-tenants \
  --add-topic multi-tenant \
  --add-topic saas-template \
  --add-topic postgresql \
  --add-topic django-rest-framework
```

Expected: command exits `0`.

- [ ] **Step 2: Draft release notes**

Ensure `CHANGELOG.md` contains exactly one `### Release Notes Draft` section with this content under `## v0.2.0 - Unreleased`:

```markdown
### Release Notes Draft

`v0.2.0` makes the starter Codex-first while keeping normal Django usage free of Codex requirements. It adds repository-level agent instructions, repo-local skills, CI, GitHub templates, optional Codex maintenance prompts, clearer setup docs, and release verification scripts.
```

- [ ] **Step 3: Commit if changelog changed**

Run:

```bash
git add CHANGELOG.md
git commit -m "docs: prepare v0.2.0 release notes"
```

If `CHANGELOG.md` did not change, skip the commit.

## Task 10: Final Verification And Handoff

**Files:**
- All changed files.
- External evidence: GitHub issue list and repository metadata.

- [ ] **Step 1: Run CodeGraph status**

Run:

```bash
codegraph status
```

Expected: reports indexed files, nodes, and edges for the current repo. If CodeGraph reports pending sync, wait one second and rerun.

- [ ] **Step 2: Run full local verification**

Run:

```bash
./scripts/verify.sh
```

Expected: exits `0` and prints `Local verification passed`.

- [ ] **Step 3: Verify git status**

Run:

```bash
git status --short --ignored
```

Expected: no tracked changes. Ignored entries such as `.codegraph/`, `.env`, `.venv/`, or coverage artifacts are acceptable.

- [ ] **Step 4: Verify GitHub issues**

Run:

```bash
gh issue list --limit 20 --json number,title --jq '.[] | select(.title | test("tenant|Codex|docs-sync|fixture|security|deployment|schema|CI"))'
```

Expected: at least eight matching issue objects.

- [ ] **Step 5: Prepare PR summary**

Use `.agents/skills/pr-draft-summary/SKILL.md` and produce:

```markdown
## Summary

- Repositioned the repo as a Codex-first Django multi-tenant SaaS starter.
- Added repo-local agent instructions and skills.
- Added CI, GitHub templates, labels, optional Codex prompts, and public issues.
- Improved Docker/local setup and verification.
- Added docs for architecture, setup, testing, agent workflows, release, and roadmap.

## Verification

- `codegraph status`
- `docker compose config`
- `python manage.py check`
- `pytest`
- `./scripts/check-docs.sh`
- `git status --short --ignored`
- `gh issue list`
```

- [ ] **Step 6: Final commit if needed**

If Step 2 or Step 5 produced file changes, commit them:

```bash
git add .
git commit -m "chore: finalize v0.2.0 readiness"
```

If no files changed, do not create an empty commit.
