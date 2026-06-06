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
