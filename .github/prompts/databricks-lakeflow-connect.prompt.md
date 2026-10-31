---
agent: agent
description: Managed ingestion pipelines into Databricks via Lakeflow Connect (SaaS apps, databases)
---

Apply the guidance in `.claude/skills/databricks-lakeflow-connect/SKILL.md` and its
`references/` folder (same content also at `.assistant/skills/databricks-lakeflow-connect/` for
Genie Code) — read them before proceeding, don't restate from memory.

Use this when ingesting from SaaS apps (Salesforce, Workday Reports, ServiceNow, Google
Analytics 4, HubSpot, Confluence) or databases (SQL Server, PostgreSQL/MySQL CDC) into Unity
Catalog via managed serverless pipelines — an alternative to hand-writing the ingestion module
`standards/databricks-pipeline.md` otherwise describes.
