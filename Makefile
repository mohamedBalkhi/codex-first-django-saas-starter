PYTHON ?= python3
VENV ?= .venv
DOCKER_COMPOSE ?= docker compose
PIP := $(VENV)/bin/python -m pip
PIP_FLAGS := --disable-pip-version-check --no-input --progress-bar off --prefer-binary --timeout 300 --retries 5
MANAGE := $(VENV)/bin/python manage.py
PYTEST := $(VENV)/bin/pytest

.PHONY: help bootstrap setup migrate run test test-cov verify check-docs clean docker-up docker-down docker-logs docker-rebuild docker-shell demo shell shell-plus superuser

help:
	@echo "Django Multi-Tenant SaaS - Available Commands"
	@echo "=============================================="
	@echo ""
	@echo "Development (Docker):"
	@echo "  make docker-up       - Start Docker containers (with auto-reload)"
	@echo "  make docker-down     - Stop Docker containers"
	@echo "  make docker-logs     - View logs (follow mode)"
	@echo "  make docker-rebuild  - Rebuild and restart containers"
	@echo "  make docker-shell    - Access Django shell in container"
	@echo ""
	@echo "Local Development:"
	@echo "  make bootstrap       - Create .env from .env.example when missing"
	@echo "  make setup           - Create .venv and install dependencies"
	@echo "  make migrate         - Run database migrations for all tenants"
	@echo "  make run             - Run development server (with watchdog)"
	@echo "  make shell           - Open Django shell"
	@echo "  make shell-plus      - Open enhanced Django shell (shell_plus)"
	@echo ""
	@echo "Testing:"
	@echo "  make test            - Run test suite"
	@echo "  make test-cov        - Run tests with coverage report"
	@echo "  make verify          - Run full local verification"
	@echo "  make check-docs      - Run documentation consistency checks"
	@echo ""
	@echo "Database:"
	@echo "  make demo            - Create demo tenants"
	@echo "  make superuser       - Create superuser for admin"
	@echo ""
	@echo "Maintenance:"
	@echo "  make clean           - Clean Python cache files"

bootstrap:
	./scripts/bootstrap-env.sh

setup: bootstrap
	$(PYTHON) -m venv $(VENV)
	@if command -v uv >/dev/null 2>&1; then \
		UV_HTTP_TIMEOUT=300 uv pip install --python $(VENV)/bin/python -r requirements.txt; \
	else \
		$(PIP) install $(PIP_FLAGS) --upgrade pip; \
		$(PIP) install $(PIP_FLAGS) -r requirements.txt; \
	fi
	@echo "Setup complete. Activate venv: source $(VENV)/bin/activate"

migrate:
	POSTGRES_HOST=localhost $(MANAGE) migrate_schemas

run:
	$(MANAGE) runserver_plus

test:
	POSTGRES_HOST=localhost $(PYTEST)

test-cov:
	POSTGRES_HOST=localhost $(PYTEST) --cov=apps --cov-report=html --cov-report=term

verify:
	./scripts/verify.sh

check-docs:
	./scripts/check-docs.sh

clean:
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete
	find . -type f -name "*.pyo" -delete
	find . -type d -name "*.egg-info" -exec rm -rf {} + 2>/dev/null || true
	find . -type d -name ".pytest_cache" -exec rm -rf {} + 2>/dev/null || true
	rm -rf htmlcov coverage.xml
	@echo "Cleaned."

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

demo:
	$(MANAGE) setup_demo

shell:
	$(MANAGE) shell

shell-plus:
	$(MANAGE) shell_plus

superuser:
	$(MANAGE) createsuperuser --schema=public
