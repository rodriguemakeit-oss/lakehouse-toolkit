---
agent: agent
description: Scaffold or extend the required pytest unit tests for a pipeline module
---

Write unit tests for a pipeline module. Apply `standards/testing.md`. Tests target plain Python
functions in `src/<package>/` — if the function still mixes I/O with logic, flag it and suggest
splitting it first.

1. Confirm `tests/conftest.py` exists with the template's `spark` fixture
   (`DatabricksSession.builder.getOrCreate()`) and `load_fixture()` helper; create it from the
   `databricks bundle init` Python-template shape if missing.
2. For each function under test: build a small DataFrame inline with
   `spark.createDataFrame(...)` for an ad hoc case, or add a JSON/CSV under `fixtures/` and load
   it via `load_fixture("<name>.json")` for a realistic reusable one.
3. Create/extend `tests/test_<module>.py`: one test per behavior, named
   `test_<function>_<condition>_<result>`. Assert on the output DataFrame's rows/schema, not
   just that it ran.
4. Cover the happy path **and** edge cases: empty input, all-null column, duplicate keys, a
   record a data quality rule should reject.
5. Run `pytest`, fix until green, and report the tests added and what's still uncovered.
