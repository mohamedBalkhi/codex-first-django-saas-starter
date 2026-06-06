# Releasing

## v0.2.0 Release Checklist

- [ ] `docker compose config` passes.
- [ ] `python manage.py check` passes.
- [ ] `pytest` passes.
- [ ] `./scripts/check-docs.sh` passes.
- [ ] GitHub CI is green.
- [ ] `CHANGELOG.md` describes the release.
- [ ] README and docs describe the Codex-first workflow.
- [ ] At least eight curated public issues exist.
- [ ] GitHub release notes mention that Codex workflows are optional maintainer tooling.

## Versioning

Use small tagged releases. `v0.2.0` is the maintenance-foundation release, not a billing or production SaaS feature release.

## Release Notes

Release notes should summarize user-visible changes, verification evidence, and known gaps.
