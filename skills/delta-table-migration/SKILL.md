---
name: delta-table-migration
description: >
  Evolves a Delta table's schema (add/rename/drop column, tighten a constraint) safely, with
  mandatory manual review and a rollback plan via Delta time travel. Use after any change to a
  table's schema.
---

# Evolve a Delta table schema

Apply `standards/databricks-pipeline.md` and `standards/data-quality.md`. Delta has no built-in
schema-migration tooling — every step here is explicit and manually authored.

1. Confirm the intended schema change and read the table's current state:
   `DESCRIBE TABLE EXTENDED <catalog.schema.table>`, `DESCRIBE HISTORY <table>` (note the
   current version — this is the rollback point).
2. **Search for consumers** of the column being changed/dropped — other pipelines' `src/`
   modules, views, and known downstream (BI) usage. A schema change that breaks a consumer
   without warning is the main failure mode here.
3. Write the migration as **explicit SQL or PySpark**, matched to the change:
   - **Additive column as part of normal pipeline operation** (the source gained a column and
     the pipeline should just pick it up): this is the auto-`ALTER TABLE ... ADD COLUMNS` case
     already covered by `standards/databricks-pipeline.md`'s schema-evolution rule — if the
     pipeline already does this automatically, there's no separate migration to author here.
   - Additive (a new column introduced deliberately, not auto-detected from a source):
     `ALTER TABLE ... ADD COLUMN col TYPE`.
   - Nullable → NOT NULL on a populated table: add nullable → backfill → `ALTER TABLE ... ADD
     CONSTRAINT ... CHECK (col IS NOT NULL)` (Delta does not have a native NOT NULL toggle on an
     existing column in every runtime — use a CHECK constraint if `ALTER COLUMN ... SET NOT
     NULL` isn't supported).
   - Rename/drop/breaking type change: requires `CREATE OR REPLACE TABLE` from a rewritten
     DataFrame, not an in-place `ALTER` — treat as a bigger, higher-risk change.
4. **Mandatory manual review** before applying anywhere shared:
   - The change matches the stated intent, no incidental column/constraint touched.
   - Backfill (if any) is batched, not a single unbounded `UPDATE` on a huge table.
   - Constraint names are explicit and stable.
   - Downstream consumers found in step 2 are updated or explicitly informed.
5. Apply on `dev` first. Verify with a row-count and null-rate check
   (`standards/data-quality.md`), then promote to the project's other targets (`prod`, and
   `ppr`/`staging` if it has one) via the normal deploy path.
6. **Rollback plan**: since there's no `downgrade()`, document the rollback as a
   `RESTORE TABLE <table> TO VERSION AS OF <version from step 1>` (Delta time travel) — confirm
   the table's retention (`delta.deletedFileRetentionDuration`) actually covers that version.
7. Report: table, ops applied, consumers checked, and the rollback version to use if needed. If
   the change drops data, touches PII columns, or is a large backfill, flag it for the
   `security-review` skill before applying anywhere shared.
