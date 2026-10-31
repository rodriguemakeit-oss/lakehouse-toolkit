<!--
  Native GitHub Copilot repo-wide custom instructions (VS Code, JetBrains, Visual Studio,
  github.com — auto-loaded, no configuration needed). This file is meant to be VENDORED into a
  project repo by scripts/install.sh, alongside .github/instructions/, .github/prompts/, and
  standards/ — GitHub Copilot cannot read files from a separate sibling repo, everything it
  references has to physically exist in the repo being worked on. See CONTRIBUTING.md.
-->
<!-- lakehouse-toolkit:vendored:start — scripts/install.sh only replaces this block on re-sync -->

# Copilot instructions — Databricks pipeline project

This project follows the **lakehouse-toolkit** standards, vendored into this repo under
`standards/`. Rules live only there — this file and `.github/instructions/*.instructions.md`
point to them, they don't restate them. Open and read the relevant standard before writing code,
then align with this project's own real conventions.

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

## Where to look for detail

| Area | Standard | Path-scoped detail |
|---|---|---|
| Pipeline code | `standards/databricks-pipeline.md` | `.github/instructions/pipeline.instructions.md` |
| Codebase layout | `standards/project-layout.md` | — |
| Configuration | `standards/config.md` | `.github/instructions/config.instructions.md` |
| Orchestration (DAB) | `standards/orchestration.md` | `.github/instructions/orchestration.instructions.md` |
| Failure alerting | `standards/alerting.md` | `.github/instructions/alerting.instructions.md` |
| Testing | `standards/testing.md` | `.github/instructions/tests.instructions.md` |
| Security | `standards/security.md` | — |
| Documentation | `standards/documentation.md` | `.github/instructions/documentation.instructions.md` |
| Commits | `standards/commits.md` | — |

## Reusable procedures

Available as Copilot Chat prompt files (`.github/prompts/`, invoke with `/<name>`):
`/scaffold-databricks-pipeline`, `/databricks-job-bundle`, `/databricks-failure-alert`,
`/delta-table-migration`, `/data-quality-check`, `/pyspark-unit-test`, `/security-review`.

## Keeping this current

This file, `.github/instructions/`, `.github/prompts/`, and `standards/` are a **vendored copy**
of `lakehouse-toolkit`, not a live link — re-run that repo's `scripts/install.sh` against this
project to pick up updates. Don't hand-edit the vendored files here to add project-specific
rules; add project-specific notes below this line instead, so a re-sync doesn't clobber them.

<!-- lakehouse-toolkit:vendored:end -->

## Project-specific notes

<!-- Add anything specific to this project below. install.sh never touches this section. -->
