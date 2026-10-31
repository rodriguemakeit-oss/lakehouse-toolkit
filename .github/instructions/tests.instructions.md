---
applyTo: "tests/**,fixtures/**"
---

# Testing — Copilot path-scoped instructions

Apply the canonical standard **`standards/testing.md`** (in this repo's `standards/`); the
`/pyspark-unit-test` prompt (Copilot Chat) or `pyspark-unit-test` skill (Claude Code)
scaffolds/extends these. **Read it — don't restate or reinvent it.** Unit tests are **required**
on this platform, not optional.

Reminders (full text in the standard):

- Reuse the template's `tests/conftest.py`: `spark` fixture (`DatabricksSession.builder
  .getOrCreate()`) and `load_fixture()` reading from `fixtures/` — don't hand-roll a different
  fixture pattern.
- Every function in `src/<package>/` with real logic gets at least one test — inline
  `spark.createDataFrame(...)` for small cases, a `fixtures/*.json|csv` file for reusable ones.
- Cover the happy path **and** edge cases: empty input, all-null column, duplicate keys, a
  record a data quality rule should reject.
- Name tests by intent: `test_<function>_<condition>_<result>`.
- No dependency on a specific remote table/cluster state — a fixture or inline DataFrame only.
- If the function under test still mixes I/O with logic, that's a `standards/databricks-pipeline.md`
  modularity gap to fix first, not a reason to skip the test.
