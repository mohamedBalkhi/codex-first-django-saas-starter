# Support

Use GitHub issues for bugs, documentation gaps, and scoped feature requests.

Before opening an issue:

1. Run `./scripts/bootstrap-env.sh`.
2. Run `docker compose config`.
3. Run `python manage.py check` or `pytest` when relevant.
4. Include the command output in the issue.

Security-sensitive tenant isolation or authentication reports belong in the private security channel described in `SECURITY.md`.
