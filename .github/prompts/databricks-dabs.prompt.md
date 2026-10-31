---
agent: agent
description: Full Databricks Asset Bundle (DABs) reference — structure, all resource types, deploy/validate, permissions
---

Apply the guidance in `.claude/skills/databricks-dabs/SKILL.md` and its `references/` folder
(same content also at `.assistant/skills/databricks-dabs/` for Genie Code) — read them before
proceeding, don't restate from memory. This is the generic DABs reference; for portfolio's own
conventions on top of it (Teams alerts, `run_as`, Python-only tasks), use
`/databricks-job-bundle` as well.

Use this for bundle structure and `databricks.yml` configuration, any resource type (jobs,
pipelines, alerts, dashboards, volumes, apps), multi-environment targets, deploy/validate/run,
or permissions on bundle resources.
