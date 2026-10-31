---
agent: agent
description: Unity Catalog governance, access control, and observability (system tables, grants, masking)
---

Apply the guidance in `.claude/skills/databricks-unity-catalog/SKILL.md` and its `references/`
folder (same content also at `.assistant/skills/databricks-unity-catalog/` for Genie Code) —
read them before proceeding, don't restate from memory.

Use this for GRANT/REVOKE, the privilege model and ownership, row-level security and column
masks, external locations and storage credentials, catalog/schema/table/volume definitions,
"who can read this table"-type questions, or querying system tables (audit, lineage, billing —
including the `system.lakeflow` tables `standards/alerting.md`'s alerts query).
