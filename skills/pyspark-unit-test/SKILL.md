---
name: pyspark-unit-test
description: >
  Scaffolds or extends pytest unit tests for a src/<package>/ module using the template's
  DatabricksSession fixture and fixtures/ loader, per standards/testing.md. Use after writing
  or changing a pipeline module — unit tests are required, not optional, on this platform.
---

# Write unit tests for a pipeline module

Apply `standards/testing.md`. Tests target plain Python functions in `src/<package>/` — if the
function being tested still has I/O or notebook-style logic mixed in, flag it and suggest
splitting it first (`standards/databricks-pipeline.md`'s modular-code rule).

1. Confirm `tests/conftest.py` exists with the template's `spark` fixture
   (`DatabricksSession.builder.getOrCreate()`) and `load_fixture()` helper; create it from the
   `databricks bundle init` Python-template shape if missing — don't hand-roll a different
   fixture pattern.
2. For each function under test, decide the input source:
   - Small, ad hoc shape → build the DataFrame inline with `spark.createDataFrame(...)` and an
     explicit schema.
   - A realistic, reusable sample → add a JSON/CSV file under `fixtures/` and load it via
     `load_fixture("<name>.json")`.
3. Create/extend `tests/test_<module>.py`: one test per behavior, named
   `test_<function>_<condition>_<result>`. Assert on the output DataFrame's rows/schema, not
   just that it ran without raising.
4. Cover the happy path **and** edge cases: empty input, all-null column, duplicate keys, and
   any record a data quality rule should reject (`standards/data-quality.md`).
5. Run `pytest`, fix until green, and report the tests added and what's still uncovered (e.g. a
   function that still mixes I/O with logic and needs splitting before it's testable).
