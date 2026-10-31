---
name: databricks-failure-alert
description: >
  Wires a Teams failure alert for a Databricks job — SQL Alert v2 + Email notification
  destination querying system.lakeflow.job_run_timeline — per standards/alerting.md. Use once a
  job is deployed and should notify on failure, or when adapting the pattern to a new project.
---

# Add a Teams failure alert for a Databricks job

Apply `standards/alerting.md`. This assumes a job already deployed via
`resources/<name>.job.yml` (`databricks-job-bundle` skill) — the alert queries that job's run
history, it doesn't create the job.

1. Gather what's needed before starting:
   - The job's resource key and its `quartz_cron_expression` (or trigger type/frequency) —
     the alert's own schedule derives from it.
   - Whether a Teams channel + its generated email address already exist for this project (ask
     the user; channel creation and getting the email address is a manual Teams step: "···" on
     the channel → "Get email address").
   - The dev/prod workspace host(s) and whether `system.lakeflow` system tables are enabled and
     readable on them.
   - An existing SQL warehouse per workspace to run the alert query
     (`databricks warehouses list --profile <p> --output json`).
2. If no notification destination exists yet for this project, create one **per workspace**
   (admin-required), same `display_name` in every workspace:
   ```bash
   databricks notification-destinations create --profile <profile> --json '{
     "display_name": "teams-<project>-alerts",
     "config": {"email": {"addresses": ["<teams-channel-address>"]}}
   }'
   ```
3. Add the alert variables to `databricks.yml` (`alert_quartz_cron_expression` offset ~30 min
   after the job's own cron, `teams_alert_destination_id` lookup, `alert_warehouse_id` lookup,
   `alert_pause_status` default `PAUSED`) — see `standards/alerting.md` for the exact shape.
4. Create `resources/<name>_failure_alert.alert.yml` as its **own file** (not inlined into the
   job's YAML): query `system.lakeflow.job_run_timeline` filtered on the job's id(s) and a
   lookback window comfortably larger than the alert's own check interval, `evaluation` firing
   when `n_failed_runs > 0`, `notify_on_ok: false`, `retrigger_seconds: 0`.
5. Set `alert_pause_status: UNPAUSED` only on the target(s) where it should actually fire
   (typically `prod`) — confirm with the user rather than assuming.
6. Validate: `databricks bundle validate`, then deploy to `dev` first and trigger a deliberate
   failure (or dry-run the query directly in a SQL editor) to confirm the alert fires and the
   Teams message reads correctly, before deploying to `prod`.
7. Report the alert's schedule, scope (which job id(s)), and destination — and remind the user
   the job's cron and the alert's offset cron are **not** automatically linked; a future change
   to the job's schedule needs a matching manual update here.
