# Standard — Project layout (Databricks pipeline)

Fixed, canonical structure — **do not add top-level files/folders outside it**, and don't reach
for a Databricks notebook as an escape hatch from it. This is the target for every new pipeline
on this platform; an existing project already organized differently is a known migration gap to
flag, not a pattern to keep extending.

## Repo layout

```
databricks.yml           # Asset Bundle root: name, include:, variables (each documented), targets
config/
  __init__.py
  settings.py               # catalogs, schemas, secret scope/key names, external locations,
                              # volumes, DB connection parameters — per environment
resources/
  <name>.job.yml              # job: trigger + tasks — python_wheel_task / spark_python_task only
  <name>_failure_alert.alert.yml
src/
  <package>/
    __init__.py
    main.py                     # entrypoint(s), exposed via [project.scripts] in pyproject.toml
    <domain modules>.py            # one responsibility per module, composed from main.py
tests/
  conftest.py                  # spark fixture (DatabricksSession) + load_fixture()
  test_<module>.py
fixtures/                    # small JSON/CSV fixtures for tests/conftest.py's load_fixture()
docs/
  README.md                    # technical choices, data sources, git repo address, owner
pyproject.toml
.gitignore
```

`databricks.yml` includes resources via `include: [resources/*.yml, resources/*/*.yml]`. A repo
can host **one bundle** or **several sibling bundles** (each subdirectory repeating this same
layout, own `databricks.yml`) when it groups a few related pipelines — either way, each bundle
individually follows this structure.

## Rules

- **This is the structure — full stop.** No ad hoc top-level folders, no code living outside
  `src/`, no config values scattered outside `config/`. If a project needs something this layout
  doesn't cover, that's a gap to raise for this platform, not a reason to freelance a new folder
  in one project.
- **No notebooks in the codebase**: no `.ipynb`, no `.py` written in "Databricks notebook
  source" format (`# COMMAND ----------`, `# MAGIC %sql`), anywhere under `src/`. Every pipeline
  is plain, importable, testable Python (`standards/databricks-pipeline.md`).
- **`config/` is the only place** catalogs, schemas, secret scope/key names, external locations,
  volumes, and DB connection parameters are declared — see `standards/config.md`. A module in
  `src/` imports from `config/`; it never redeclares any of this inline.
- **Code is modular**: one responsibility per module in `src/<package>/`, composed explicitly —
  not one large script, not the same logic duplicated across modules.
- **`docs/`** carries the technical-choices / data-sources / repo-address documentation
  (`standards/documentation.md`) — not scattered local notes.
- **Naming**: snake_case for modules/functions/variables; Unity Catalog objects
  `<catalog>.<schema>.<table>`, always fully qualified in code, sourced from `config/`.
- **Function-size and call-depth limits**: compose at the caller, don't nest helpers three
  levels deep.
- **Comments**: no decorative banners/separators, no comment that restates the code — comment
  the *why*.
- **`.env*` files are never committed** — add the pattern to `.gitignore` *before* the first
  commit; a `.gitignore` entry doesn't retroactively untrack a file already committed. Verify
  with `git ls-files | grep -i env` on an existing repo rather than trusting `.gitignore` alone
  (`standards/security.md`).
