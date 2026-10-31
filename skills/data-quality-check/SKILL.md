---
name: data-quality-check
description: >
  Adds data quality validation (schema enforcement, null/uniqueness/range/referential checks,
  fail-vs-quarantine handling) at a pipeline boundary, per standards/data-quality.md. Use when
  adding or changing a step where a consumer starts trusting the data without re-checking it.
---

# Add data quality checks

Apply `standards/data-quality.md`. Identify which boundary is being changed — the point after
which a consumer relies on the data — and which implementation fits the pipeline's shape.

1. Identify the checks relevant to this boundary: schema enforcement, row-count sanity vs the
   previous run/source, null rate on required columns, uniqueness of business keys, referential
   integrity, value ranges/enums, freshness.
2. Implement each check with the mechanism that fits the pipeline (`standards/data-quality.md`):
   - Table-native / SQL-first pipeline: a Delta `CHECK`/`NOT NULL` constraint for structural
     rules, an explicit assertion query for business-rule/cross-table checks.
   - File-landing pipeline: extend the accept/reject gate — validate, route to `accepted/` or
     `rejected/`, write a structured JSON rejection log with the reason, record the outcome in
     the checkpoint table.
   Not a comment saying it should be checked.
3. Decide **fail vs quarantine** per `standards/data-quality.md`:
   - The final/published layer: a breach **fails the job**.
   - Earlier layers: quarantine (reject file/table + logged reason) rather than silently drop;
     escalate to a hard fail past the agreed reject-rate threshold.
4. Log the quality metrics for the run (counts in/out, reject count, null rates, pass/fail per
   check) so a failure is diagnosable from the run history alone.
5. Report the checks added, their thresholds, and the fail/quarantine policy applied.
