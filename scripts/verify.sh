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
python -m pip install --disable-pip-version-check --no-input --progress-bar off --prefer-binary --timeout 300 --retries 5 --upgrade pip
python -m pip install --disable-pip-version-check --no-input --progress-bar off --prefer-binary --timeout 300 --retries 5 -r requirements.txt

POSTGRES_HOST="${POSTGRES_HOST:-localhost}" python manage.py check
POSTGRES_HOST="${POSTGRES_HOST:-localhost}" pytest
./scripts/check-docs.sh

echo "Local verification passed"
