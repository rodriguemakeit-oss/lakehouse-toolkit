---
name: databricks-job-bundle
description: >
  Creates or updates a Databricks Asset Bundle job (databricks.yml + resources/*.job.yml) with
  a documented variables block, per-target catalogs, and a service-principal prod run-as, per
  standards/orchestration.md. Use once a pipeline's code is ready to run on a schedule, or when
  its trigger/variables/targets need to change.
---

# Wire a pipeline into a Databricks Asset Bundle job

Apply `standards/orchestration.md`. Locate `databricks.yml`; if it doesn't exist, this is a new
bundle — create it with `include: [resources/*.yml, resources/*/*.yml]` and `dev`/`prod` targets
before adding the job.

1. Confirm the pipeline's trigger: time-based (`schedule.quartz_cron_expression`), event-driven
   (`trigger.table_update`), or simple periodic (`trigger.periodic`) — per
   `standards/orchestration.md`, don't default to cron without checking what actually fits.
2. In `resources/<pipeline>.job.yml`, define the task as a **`python_wheel_task`** (package
   name + entry point matching `[project.scripts]` in `pyproject.toml`) or a
   **`spark_python_task`** for a small unpackaged script — **never a `notebook_task`**
   (`standards/databricks-pipeline.md`). Pass `env` (and any other needed parameter) as task
   parameters. Add `queue: { enabled: true }` and, unless the project has a reason not to,
   `performance_target: PERFORMANCE_OPTIMIZED`.
3. In `databricks.yml`, add/confirm every variable the job needs has a `description:`, and that
   each target (`dev`/`prod`, or the project's actual target names) sets its own `env` value —
   the actual catalog/schema/secret names live in `config/settings.py`
   (`standards/config.md`), not duplicated as bundle variables.
4. Set `run_as: service_principal_name: <id>` on the `prod` target (`standards/security.md`) —
   ask for the service principal id/name if not already known, never leave prod on a personal
   identity. Add a `permissions:` block granting `CAN_MANAGE` to the maintainer(s).
5. Set `pause_status`: `UNPAUSED` in `dev`; confirm with the user before setting `prod`'s (or
   any shared target's) to `UNPAUSED` — that's what makes the schedule actually run for real.
6. Secret values go through a secret scope or service credential (`standards/security.md`); only
   scope/key *names* — from `config/settings.py` — ever appear in a task parameter.
7. Validate: `databricks bundle validate`. Fix until clean.
8. Report the job's trigger, task graph, and per-target pause status. Remind the user that this
   resource must only change via `databricks bundle deploy -t <target>` — never hand-edited in
   the workspace UI, never created any other way (`standards/orchestration.md`) — and suggest the
   `databricks-failure-alert` skill next if the job doesn't have one yet.
