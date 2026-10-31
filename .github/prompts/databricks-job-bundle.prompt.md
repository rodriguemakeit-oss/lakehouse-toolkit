---
agent: agent
description: Wire or update a Databricks Asset Bundle job (trigger, variables, service-principal prod run-as)
---

Wire a pipeline into a Databricks Asset Bundle job. Apply `standards/orchestration.md`. Locate
`databricks.yml`; if it doesn't exist, create it with `include: [resources/*.yml,
resources/*/*.yml]` and `dev`/`prod` targets first.

1. Confirm the pipeline's trigger: time-based (`schedule.quartz_cron_expression`), event-driven
   (`trigger.table_update`), or simple periodic (`trigger.periodic`) — don't default to cron
   without checking what actually fits.
2. In `resources/<pipeline>.job.yml`, define the task as a **`python_wheel_task`** (package name
   + entry point matching `[project.scripts]`) or a **`spark_python_task`** for a small
   unpackaged script — **never a `notebook_task`**. Pass `env` as a task parameter. Add
   `queue: { enabled: true }` and, unless the project has a reason not to,
   `performance_target: PERFORMANCE_OPTIMIZED`.
3. In `databricks.yml`, confirm every variable has a `description:`, and each target sets its
   own `env` — the actual catalog/schema/secret names live in `config/settings.py`
   (`standards/config.md`), not duplicated as bundle variables.
4. Set `run_as: service_principal_name: <id>` on the `prod` target (`standards/security.md`) —
   ask for the id if not already known, never leave prod on a personal identity. Add a
   `permissions:` block granting `CAN_MANAGE` to the maintainer(s).
5. Set `pause_status`: `UNPAUSED` in `dev`; confirm with the user before unpausing `prod` (or any
   shared target) — that's what makes the schedule actually run for real.
6. Secret values go through a secret scope or service credential; only scope/key *names* — from
   `config/settings.py` — ever appear in a task parameter.
7. Validate: `databricks bundle validate`. Fix until clean.
8. Report the job's trigger, task graph, and per-target pause status. Remind the user this
   resource must only change via `databricks bundle deploy -t <target>` — never hand-edited in
   the workspace UI. Suggest `/databricks-failure-alert` next if the job doesn't have one yet.
