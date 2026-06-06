#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

./scripts/bootstrap-env.sh
docker compose config >/dev/null

start_db() {
  local attempt
  for attempt in 1 2 3; do
    if docker compose up -d db; then
      return 0
    fi

    echo "Database container failed to start on attempt ${attempt}; retrying..." >&2
    docker compose down --remove-orphans >/dev/null 2>&1 || true
    sleep $((attempt * 10))
  done

  echo "Database container failed to start after 3 attempts" >&2
  return 1
}

start_db

if [ ! -d ".venv" ]; then
  python3 -m venv .venv
fi

source .venv/bin/activate
if command -v uv >/dev/null 2>&1; then
  UV_HTTP_TIMEOUT=300 uv pip install --python .venv/bin/python -r requirements.txt
else
  python -m pip install --disable-pip-version-check --no-input --progress-bar off --prefer-binary --timeout 300 --retries 5 --upgrade pip
  python -m pip install --disable-pip-version-check --no-input --progress-bar off --prefer-binary --timeout 300 --retries 5 -r requirements.txt
fi

POSTGRES_HOST="${POSTGRES_HOST:-localhost}" POSTGRES_PORT="${POSTGRES_HOST_PORT:-5433}" python manage.py check
POSTGRES_HOST="${POSTGRES_HOST:-localhost}" POSTGRES_PORT="${POSTGRES_HOST_PORT:-5433}" python manage.py migrate_schemas --shared
POSTGRES_HOST="${POSTGRES_HOST:-localhost}" POSTGRES_PORT="${POSTGRES_HOST_PORT:-5433}" python manage.py migrate_schemas
POSTGRES_HOST="${POSTGRES_HOST:-localhost}" POSTGRES_PORT="${POSTGRES_HOST_PORT:-5433}" pytest
./scripts/check-docs.sh

echo "Local verification passed"
