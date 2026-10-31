---
agent: agent
description: Scaffold a new Databricks pipeline (canonical structure, modular Python package, tests, job bundle stub)
---

Scaffold a new Databricks pipeline. Apply `standards/project-layout.md`,
`standards/databricks-pipeline.md`, `standards/config.md`, and `standards/testing.md`. This is
the canonical structure — don't ask which layout to use; only check whether this is a new bundle
or a new pipeline inside an existing one.

1. Ask for the **package name** (snake_case), what it syncs/transforms (source → target), and
   the catalog/schema per environment.
2. If `databricks.yml` doesn't exist yet, create it: `bundle.name`, `include: [resources/*.yml,
   resources/*/*.yml]`, an `env` variable, and `dev`/`prod` targets
   (`standards/orchestration.md`).
3. Create `config/__init__.py` and `config/settings.py` if missing — a `Settings` dataclass and
   `ENVIRONMENTS` dict per `standards/config.md`, with `get_settings(env)`. If `config/` already
   exists, extend it rather than creating a second config module.
4. Create `src/<package>/`:
   - `__init__.py`
   - `main.py` — entrypoint: parses `--env`, calls `config.get_settings(env)`, calls the real
     logic, nothing else. **Plain Python — no notebook, no magic command.**
   - one module per responsibility (read source / transform / write), pure functions where
     possible (`standards/databricks-pipeline.md`).
5. Add `main = "<package>.main:main"` under `[project.scripts]` in `pyproject.toml` (create it
   from the `databricks bundle init` Python-template shape if missing).
6. Create `tests/conftest.py` (the `DatabricksSession` fixture + `load_fixture()`, per
   `standards/testing.md`) if missing, plus one `tests/test_<module>.py` per module with at
   least a happy-path test.
7. Create `resources/<name>.job.yml`: a `python_wheel_task` (or `spark_python_task` for a very
   small script) calling the entrypoint, `schedule` with `pause_status: PAUSED` until confirmed,
   `queue: { enabled: true }`. Follow up with `/databricks-job-bundle` to wire targets properly,
   and `/databricks-failure-alert` once the job is real.
8. Create `docs/README.md`: technical choices made, data sources, published outputs, git repo
   address, owner (placeholders where unknown) per `standards/documentation.md`.
9. Run `pytest` and report the files created plus the next steps left for the user.
