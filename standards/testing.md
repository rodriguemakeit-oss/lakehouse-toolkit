# Standard — Testing

Unit tests are required on every pipeline — new pipelines ship with tests from the start.

## Setup — reuse what `databricks bundle init` already scaffolds

`tests/conftest.py` (from the default template, keep it as-is unless there's a specific reason
to change it) provides:

- a `spark` fixture — `DatabricksSession.builder.getOrCreate()`, with a fallback to serverless
  compute when nothing else is configured;
- a `load_fixture(filename)` helper reading a JSON/CSV from `fixtures/` into a DataFrame.

`pyproject.toml`'s `pytest` / `databricks-connect` dev dependencies are what these tests run on
— they're already present in the default template; keep them, they're not unused boilerplate.

## What to test

- Every function in `src/<package>/` that does real logic (a transform, a validation, a key
  computation) gets at least one test — build small input DataFrames inline or via
  `load_fixture`, assert the output.
- Cover the happy path **and** edge cases: empty input, all-null column, duplicate keys, a
  record a data quality rule should reject (`standards/data-quality.md`).
- Functions that only orchestrate (resolve config, call the real logic, write the result) don't
  need heavy testing themselves — test the logic they call instead. This is what
  `standards/databricks-pipeline.md`'s modular-code rule is for: it's what makes the real logic
  testable in isolation, independent of a live cluster/job run.

## Rules

- Name tests by intent: `test_<function>_<condition>_<result>`.
- No dependency on a specific remote table/cluster state for a unit test — a fixture or an
  inline DataFrame only.
- Run `pytest` before every commit that touches `src/`.
