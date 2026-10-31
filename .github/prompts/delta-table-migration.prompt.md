---
agent: agent
description: Evolve a Delta table's schema safely, with mandatory manual review and a rollback plan
---

Evolve a Delta table schema. Apply `standards/databricks-pipeline.md` and
`standards/data-quality.md`. Delta has no built-in schema-migration tooling — every step here is
explicit and manually authored.

1. Confirm the intended schema change and read the table's current state:
   `DESCRIBE TABLE EXTENDED <catalog.schema.table>`, `DESCRIBE HISTORY <table>` (note the
   current version — this is the rollback point).
2. **Search for consumers** of the column being changed/dropped — other pipelines' `src/`
   modules, views, and known downstream (BI) usage.
3. Write the migration as explicit SQL or PySpark, matched to the change:
   - Additive column auto-applied as part of normal pipeline operation (`ALTER TABLE ... ADD
     COLUMNS`) — already covered by the schema-evolution rule, no separate migration needed.
   - Additive column introduced deliberately: `ALTER TABLE ... ADD COLUMN col TYPE`.
   - Nullable → NOT NULL on a populated table: add nullable → backfill → `ALTER TABLE ... ADD
     CONSTRAINT ... CHECK (col IS NOT NULL)`.
   - Rename/drop/breaking type change: `CREATE OR REPLACE TABLE` from a rewritten DataFrame.
4. **Mandatory manual review** before applying anywhere shared: intent matches, backfill is
   batched not a single unbounded `UPDATE`, constraint names explicit and stable, downstream
   consumers updated or informed.
5. Apply on `dev` first, verify with a row-count/null-rate check, then promote to the project's
   other targets.
6. **Rollback plan**: document `RESTORE TABLE <table> TO VERSION AS OF <version from step 1>`
   (Delta time travel) — confirm `delta.deletedFileRetentionDuration` covers that version.
7. Report table, ops applied, consumers checked, and the rollback version. If the change drops
   data, touches PII columns, or is a large backfill, flag it for `/security-review` first.
