---
name: scaffold-databricks-pipeline
description: >
  Scaffolds a new Databricks pipeline: the canonical repo structure (databricks.yml, config/,
  resources/, src/<package>/, tests/, docs/), a modular Python package (no notebooks), and a
  job bundle stub, per standards/project-layout.md and standards/databricks-pipeline.md. Use
  when starting a new data pipeline.
---

# Scaffold a Databricks pipeline

Apply `standards/project-layout.md`, `standards/databricks-pipeline.md`, `standards/config.md`,
and `standards/testing.md`. This is the canonical structure — don't ask which layout to use;
detect only whether this is a new bundle or a new pipeline inside an existing one.

1. Ask for the **package name** (snake_case), what it syncs/transforms (source → target), and
   the catalog/schema per environment.
2. If `databricks.yml` doesn't exist yet, create it: `bundle.name`, `include: [resources/*.yml,
   resources/*/*.yml]`, an `env` variable, and `dev`/`prod` targets
   (`standards/orchestration.md`).
3. Create `config/__init__.py` and `config/settings.py` if they don't exist yet — a
   `Settings` dataclass and `ENVIRONMENTS` dict per `standards/config.md` (catalog, schema,
   external location, state volume, DB connection params if relevant), with a
   `get_settings(env)` function. If `config/` already exists, extend it rather than creating a
   second config module.
4. Create `src/<package>/`:
   - `__init__.py`
   - `main.py` — entrypoint: parses `--env` (and any other CLI arg), calls
     `config.get_settings(env)`, calls the real logic, nothing else. **Plain Python — no
     notebook, no magic command.**
   - one module per responsibility (e.g. a module that reads the source, one that
     transforms, one that writes) — pure functions where possible
     (`standards/databricks-pipeline.md`).
5. Add `main = "<package>.main:main"` under `[project.scripts]` in `pyproject.toml` (create it
   from the `databricks bundle init` Python-template shape if missing — `hatchling` build
   backend, `pytest`/`databricks-connect` dev dependencies).
6. Create `tests/conftest.py` (the `DatabricksSession` `spark` fixture + `load_fixture()`, per
   `standards/testing.md`) if missing, plus one `tests/test_<module>.py` per module created in
   step 4 with at least a happy-path test.
7. Create `resources/<name>.job.yml`: a `python_wheel_task` (or `spark_python_task` for a very
   small script) calling the package's entrypoint, `schedule` with `pause_status: PAUSED` until
   the user confirms a cadence, `queue: { enabled: true }`. Chain into the `databricks-job-bundle`
   skill to wire targets/variables properly, and `databricks-failure-alert` once the job is real.
8. Create `docs/README.md`: technical choices made, data sources, published outputs, git repo
   address, owner (placeholders where unknown) per `standards/documentation.md`.
9. Run `pytest` and report the files created plus the next steps left for the user (real source
   connection details, actual schema/columns, job bundle wiring, failure alert).
