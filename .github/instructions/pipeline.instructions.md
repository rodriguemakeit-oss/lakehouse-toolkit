---
applyTo: "**/*.py,**/*.ipynb"
---

# Databricks pipeline — Copilot path-scoped instructions

Apply the canonical standards **`standards/databricks-pipeline.md`**, `standards/project-layout.md`,
`standards/config.md`, and `standards/data-quality.md` (in this repo's `standards/`). **Read
them — don't restate or reinvent them.**

Reminders (full text and rationale live in the standards):

- **No notebooks in the codebase.** No `.ipynb`, no `.py` in "Databricks notebook source"
  format (`# COMMAND ----------`, `# MAGIC ...`). If you're about to edit or create one, stop —
  the target is a plain Python module under `src/<package>/`, run via a `python_wheel_task` /
  `spark_python_task`, never a `notebook_task`.
- **No magic commands** — `%sql`, `%py`, `%md`, `%sh`, `%pip`, `%fs`, `%r`. Run SQL from Python
  with `spark.sql("""...""")`; declare dependencies in `pyproject.toml`.
- **Code is modular**: one responsibility per module, composed from `main.py`; pure functions
  where possible — that's what makes `standards/testing.md`'s unit tests possible.
- **`config/` is the only place** catalogs, schemas, secret names, external locations, volumes,
  and DB connection parameters are declared — import from `config.get_settings(env)`, never
  redeclare inline.
- **Idempotency**: full-rebuild CTAS via `spark.sql()`, `MERGE INTO` on a natural key, or an
  upsert with a no-op guard (`WHERE col IS DISTINCT FROM EXCLUDED.col`) + soft-delete — pick per
  pipeline shape; never a blind `append`.
- **Schema evolution**: additive columns can auto-apply (`ALTER TABLE ... ADD COLUMNS`) as a
  deliberate part of the pipeline's contract; anything else needs the `delta-table-migration`
  skill.
- **Data quality**: validate at the boundary where a consumer starts trusting the data without
  re-checking it; a breach on the final/published layer fails the job.
- **Naming**: snake_case; Unity Catalog objects always fully qualified (`catalog.schema.table`).
- **Comments**: no decorative banners, no comment that restates the code — comment the *why*.
