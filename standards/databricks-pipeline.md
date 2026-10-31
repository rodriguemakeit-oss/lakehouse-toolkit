# Standard — Databricks pipeline architecture

One canonical shape: a **plain, modular Python package** under `src/<package>/`
(`standards/project-layout.md`), deployed as a wheel and run via a `python_wheel_task` (or a
`spark_python_task` for a single-file script) — **never a Databricks notebook**. This is the
target for every new pipeline; an existing notebook-based pipeline is a known migration gap, not
a pattern to extend.

## No notebooks, no magic commands

- **No `.ipynb`, no `.py` in "Databricks notebook source" format** (`# COMMAND ----------`,
  `# MAGIC ...`) anywhere in the codebase. A pipeline is importable, testable Python — a
  notebook cell is neither.
- **No magic commands** — `%sql`, `%py`, `%md`, `%sh`, `%pip`, `%fs`, `%r`, none of them. Run
  SQL from Python with `spark.sql("""...""")`; declare a dependency in `pyproject.toml`, never
  `%pip install` at runtime.
- Interactive exploration during development happens in a personal, **never-committed** scratch
  notebook — it doesn't become the pipeline's source of truth, and whatever logic it proves out
  gets ported into `src/<package>/` before the pipeline is considered done.

## Code shape

- One responsibility per module (`standards/project-layout.md`): e.g. a module that reads a
  source, one that transforms, one that writes/publishes — composed explicitly from `main.py`,
  not one large script.
- Functions are the unit of logic: prefer `def transform(df: DataFrame) -> DataFrame` style (a
  thin class only when state genuinely needs to be threaded through several calls) — testable in
  isolation (`standards/testing.md`).
- Parameters (env, and anything per-run) are resolved **once** in `main.py` from
  `config.get_settings(env)` (`standards/config.md`) plus explicit CLI arguments/job parameters
  — never re-read ad hoc deeper in the call stack.

## Idempotency

All three are legitimate; the pipeline's own shape decides which one applies:

- **Full rebuild**: recompute the target from its sources every run
  (`spark.sql("CREATE OR REPLACE TABLE ... AS SELECT ...")` from Python, or a DataFrame
  `overwrite`) — correct for a bounded-source, scheduled full-refresh table.
- **`MERGE INTO`** on the target's natural key — for incremental Delta-to-Delta syncs (schema
  evolves by explicit `ALTER TABLE ... ADD COLUMNS` when the source gains a column — see below).
- **Upsert with a no-op guard** — for Delta-to-external-DB syncs, `INSERT ... ON CONFLICT (key)
  DO UPDATE SET col = EXCLUDED.col ... WHERE col IS DISTINCT FROM EXCLUDED.col`; dedupe the
  batch by conflict key before sending. Pair with a **soft-delete** convention (`is_deleted` /
  `deleted_at`) rather than a hard `DELETE`.

Never a blind `append` for anything re-runnable.

## Incremental reads — two proven patterns

- **Delta Change Data Feed**: `spark.read.format("delta").option("readChangeFeed", "true")
  .option("startingVersion", n).option("endingVersion", m)`, filtered on `_change_type`. State =
  last version successfully processed per table, persisted under the UC Volume path from
  `config.settings.state_volume`. Detect a CDF gap (`DELTA_MISSING_CHANGE_DATA`) and **fall back
  to a full snapshot read** — log the fallback, don't silently swallow it.
- **Watermark**: last `(event_timestamp, primary_key)` persisted in a dedicated small Delta
  table. Next batch: `WHERE event_time > last_ts OR (event_time = last_ts AND pk > last_pk)`.

## Schema evolution

Additive columns can be applied automatically (`ALTER TABLE ... ADD COLUMNS`) as a deliberate,
code-reviewed part of the pipeline's own contract. Anything else (rename, drop, retype,
tightening a constraint) goes through the `delta-table-migration` skill.

## Gold/published dimension tables with a surrogate key

When a dimension needs a stable surrogate key across runs: compute new keys only for business
keys not already present (`MAX(existing_key) + ROW_NUMBER()` over the genuinely new ones), then
`UNION ALL` with the existing dimension so prior keys never change on a rebuild.

## Style

- A small structured logger — `log(event: str, **kwargs)` printing a UTC ISO timestamp + event +
  `key=repr(value)` — beats bare `print()` for anything beyond a one-off debug line.
- snake_case for files/functions/variables/columns; Unity Catalog objects always fully
  qualified, sourced from `config/`.
- Respect function-size/call-depth limits; compose small steps rather than one large function.
- Comment the *why* (a business rule, a dedup/watermark choice), never the *what* — no
  decorative banners.
- No hardcoded catalog/schema/table names, paths, or credentials — everything comes from
  `config/` (`standards/config.md`) and `standards/security.md`.
