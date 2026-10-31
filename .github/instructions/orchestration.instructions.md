---
applyTo: "databricks.yml,resources/**/*.job.yml,resources/**/*.pipeline.yml"
---

# Orchestration (Databricks Asset Bundles) — Copilot path-scoped instructions

Apply the canonical standard **`standards/orchestration.md`** (in this repo's `standards/`); the
`/databricks-job-bundle` prompt (Copilot Chat) or `databricks-job-bundle` skill (Claude Code)
wires one up. **Read it — don't restate or reinvent it.**

Reminders (full text in the standard):

- **Resources are exclusively code**: jobs, tasks, pipelines, alerts live only in
  `resources/*.yml` — never created/edited by hand in the workspace UI, never provisioned via
  the SDK/API from a script.
- **`include: [resources/*.yml, resources/*/*.yml]`** — one file per job/pipeline/alert, not
  everything inlined in the root `databricks.yml`, on new work.
- **Tasks call Python — `python_wheel_task` or `spark_python_task` — never `notebook_task`**
  (`standards/databricks-pipeline.md`).
- **Trigger matches the pipeline**: `schedule` (cron) for time-based, `trigger.table_update` for
  event-driven off an upstream table, `trigger.periodic` for the simple default — not cron by
  habit.
- **`dev` unpaused, `prod`'s pause status explicit and reviewed.**
- **`run_as: service_principal_name`** on `prod` (and any shared target) — never a personal
  identity (`standards/security.md`).
- **Every `variables:` entry has a `description:`.** `lookup:` variables keep the same display
  name across workspaces. Catalog/schema/secret *values* live in `config/settings.py`
  (`standards/config.md`), not duplicated as bundle variables.
- **Secrets referenced in task parameters are scope/key names, never values.**
- Validate with `databricks bundle validate` before every deploy.
