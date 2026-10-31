---
agent: agent
description: Add data quality validation at a pipeline boundary (fail vs quarantine)
---

Add data quality checks. Apply `standards/data-quality.md`. Identify which boundary is being
changed — the point after which a consumer relies on the data — and which implementation fits.

1. Identify the checks relevant to this boundary: schema enforcement, row-count sanity, null
   rate on required columns, uniqueness of business keys, referential integrity, value
   ranges/enums, freshness.
2. Implement each check with the mechanism that fits the pipeline:
   - Table-native: a Delta `CHECK`/`NOT NULL` constraint for structural rules, an explicit
     assertion query (via `spark.sql()`) for business-rule/cross-table checks.
   - File-landing: extend the accept/reject gate — validate, route to `accepted/`/`rejected/`,
     write a structured JSON rejection log with the reason, record the outcome in the
     checkpoint table.
3. Decide fail vs quarantine: the final/published layer fails the job on a breach; earlier
   layers quarantine with a logged reason and escalate past an agreed reject-rate threshold.
4. Log quality metrics for the run (counts in/out, reject count, null rates, pass/fail) so a
   failure is diagnosable from the run history alone.
5. Add a test for the new check with `/pyspark-unit-test` if one doesn't exist yet.
6. Report the checks added, their thresholds, and the fail/quarantine policy applied.
