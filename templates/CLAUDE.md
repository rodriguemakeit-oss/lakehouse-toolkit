<!-- lakehouse-toolkit:vendored:start — scripts/install.sh only replaces this block on re-sync -->

# CLAUDE.md — Databricks pipeline project

This project follows the **lakehouse-toolkit** standards, vendored into this repo under
`standards/`, with skills available locally under `.claude/skills/`. Rules live only in
`standards/` — read the relevant one before writing code, then align with this project's own
real conventions.

## Non-negotiables

- **Fixed codebase structure** (`standards/project-layout.md`): `databricks.yml`, `config/`,
  `resources/`, `src/<package>/`, `tests/`, `fixtures/`, `docs/`. Nothing lives outside it.
- **No notebooks, no magic commands** (`standards/databricks-pipeline.md`): no `.ipynb`, no
  notebook-source `.py`, no `%sql`/`%py`/`%md`/`%sh`/`%pip`. Plain, modular, testable Python.
- **`config/` is the only place** catalogs, schemas, secret names, external locations, volumes,
  and DB connection parameters are declared (`standards/config.md`).
- **Unit tests are required** (`standards/testing.md`) — every pipeline ships with tests, using
  the template's `DatabricksSession`/`load_fixture` setup in `tests/conftest.py`.
- **Resources are exclusively code** (`standards/orchestration.md`): jobs/tasks/alerts live only
  in `resources/*.yml` — never created by hand in the workspace UI or via ad hoc API calls.
- **Security** (`standards/security.md`): no hardcoded secrets; `.env*` never committed; service-
  principal `run_as` in `prod`; least-privilege Unity Catalog grants; PII tagged and masked.
- **Commits**: Conventional-ish (`standards/commits.md`) — match this project's existing style.

## Skills

Available under `.claude/skills/` — Claude picks the right one from its description, or ask by
name: `scaffold-databricks-pipeline`, `databricks-job-bundle`, `databricks-failure-alert`,
`delta-table-migration`, `data-quality-check`, `pyspark-unit-test`, `security-review`.

## Keeping this current

This file and `.claude/skills/` are a **vendored copy** of `lakehouse-toolkit`, not a live link
— re-run that repo's `scripts/install.sh` against this project to pick up updates. Don't
hand-edit them to add project-specific rules; add project-specific notes below instead, so a
re-sync doesn't clobber them.

<!-- lakehouse-toolkit:vendored:end -->

## Project-specific notes

<!-- Add anything specific to this project below. install.sh never touches this section. -->
