---
agent: agent
description: Add a Teams failure alert for a deployed Databricks job (SQL Alert v2 + Email notification destination)
---

Add a Teams failure alert for a Databricks job. Apply `standards/alerting.md`. This assumes a
job already deployed via `resources/<name>.job.yml` — the alert queries its run history, it
doesn't create the job.

1. Gather what's needed: the job's resource key and its cron/trigger frequency (the alert's own
   schedule derives from it); whether a Teams channel + generated email address already exist
   for this project (ask the user — "···" on the channel → "Get email address"); the dev/prod
   workspace host(s) and whether `system.lakeflow` system tables are enabled; an existing SQL
   warehouse per workspace.
2. If no notification destination exists yet, create one **per workspace** (admin-required),
   same `display_name` in every workspace:
   ```bash
   databricks notification-destinations create --profile <profile> --json '{
     "display_name": "teams-<project>-alerts",
     "config": {"email": {"addresses": ["<teams-channel-address>"]}}
   }'
   ```
3. Add the alert variables to `databricks.yml` (`alert_quartz_cron_expression` offset ~30 min
   after the job's own cron, `teams_alert_destination_id` lookup, `alert_warehouse_id` lookup,
   `alert_pause_status` default `PAUSED`) — see `standards/alerting.md` for the exact shape.
4. Create `resources/<name>_failure_alert.alert.yml` as its own file: query
   `system.lakeflow.job_run_timeline` filtered on the job's id(s) and a lookback window larger
   than the alert's own check interval, `evaluation` firing when `n_failed_runs > 0`,
   `notify_on_ok: false`, `retrigger_seconds: 0`.
5. Set `alert_pause_status: UNPAUSED` only on the target(s) where it should actually fire —
   confirm with the user.
6. Validate: `databricks bundle validate`, deploy to `dev` first and confirm the alert fires
   before deploying to `prod`.
7. Report the alert's schedule, scope, and destination — and remind the user the job's cron and
   the alert's offset cron are **not** automatically linked.
