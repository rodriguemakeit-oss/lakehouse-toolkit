# Standard — Data quality

Validate **at the boundary where a pipeline's own trust guarantee changes** — the point after
which a consumer (BI, another pipeline, an external system) is expected to rely on the data
without re-checking it. A pipeline that only checks its final table has already let bad data
reach every intermediate one un-noticed.

## What to check

- Schema: explicit expected shape; a new/unexpected column or type is either accepted
  deliberately (`standards/databricks-pipeline.md`'s schema-evolution rule) or rejected, never
  silently coerced.
- Row-count sanity vs the previous run or the source, within an expected ratio.
- Null rate on required columns; uniqueness of business/primary keys; referential integrity
  against conformed dimensions; value ranges/enums; freshness (max event timestamp within an
  expected lag).

## Two proven implementations — pick per pipeline shape

- **Delta constraints**, for structural rules cheap to check on write: `ALTER TABLE ... ADD
  CONSTRAINT ... CHECK (...)`, `NOT NULL`. Fits a table-native, SQL-first pipeline.
- **Accept/reject file gate**, for a file-landing pipeline: validate each incoming file, move
  accepted ones to an `accepted/` prefix and rejected ones to a `rejected/` prefix, write a
  structured JSON log per rejection (`{run_ts, source_file, validation/error, ...}`) explaining
  *why*, and record every processed path + status in a checkpoint Delta table so nothing is
  silently reprocessed or lost. Fits an inbound-file pipeline (parquet/CSV drops, API exports).

Both can coexist in the same project at different boundaries — use whichever fits the boundary,
not one mechanism everywhere.

## Fail vs quarantine

- **The final/published layer**: a quality gate breach **fails the job** — never publish a table
  that failed its checks; downstream consumers trust it unconditionally.
- **Earlier layers**: prefer **quarantining** bad records/files (with the failure reason) over
  silently dropping them. Escalate to a hard fail once the reject rate exceeds an agreed
  threshold (e.g. > 1% of rows, or a run with zero accepted files when some were expected).
- Never drop rows/files without a quarantine path or a logged reason.

## Observability

Log quality metrics per run (counts in/out, reject count, null rates, pass/fail per check) so a
failure is diagnosable from the run history without re-running the pipeline.
