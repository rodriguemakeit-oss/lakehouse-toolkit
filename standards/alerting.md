# Standard — Job failure alerting (Teams)

A recurring, now-standard pattern across projects on this stack: notify a Teams channel when a
Databricks job fails, via a **SQL Alert v2** + an **Email-type notification destination** — the
portfolio workspaces used here don't allow webhook-type destinations, so the alert can't post to
Teams directly; it emails the address Teams generates for a channel instead.

## Components

1. **Notification destination** (once per workspace, admin-created):
   ```bash
   databricks notification-destinations create --profile <profile> --json '{
     "display_name": "teams-<project>-alerts",
     "config": {"email": {"addresses": ["<teams-channel-generated-address>"]}}
   }'
   ```
   Use the **same `display_name` in every workspace** (dev/prod) so a single `lookup:` resolves
   in all of them.

2. **Variables in `databricks.yml`**:
   - `alert_quartz_cron_expression` — same cadence as the job's own cron, offset by roughly
     30 minutes later so the alert checks *after* the job would normally finish. Keep it in
     sync **manually** with `quartz_cron_expression` if the job's schedule changes — there's no
     automatic link between the two.
   - `teams_alert_destination_id` — `lookup: { notification_destination: teams-<project>-alerts }`.
   - `alert_warehouse_id` — `lookup: { warehouse: <shared-warehouse-name> }`; override per target
     if a workspace lacks that named warehouse.
   - `alert_pause_status` — default `PAUSED`, explicit `UNPAUSED` only where the alert should
     actually fire (typically `prod`, sometimes a pre-prod target too — match the job's own
     pause convention).

3. **`resources/<name>_failure_alert.alert.yml`** — its own file, not inlined into the job's
   YAML (`standards/orchestration.md`'s exclusively-as-code rule applies to alerts too — never
   created by hand in the workspace UI):
   ```yaml
   resources:
     alerts:
       <name>_failure_alert:
         display_name: "job_<name>-${bundle.target} - Job Failure Alert"
         parent_path: ${workspace.root_path}
         warehouse_id: ${var.alert_warehouse_id}

         query_text: >-
           WITH failed AS (
             SELECT run_id, period_start_time, period_end_time, result_state, termination_code
             FROM system.lakeflow.job_run_timeline
             WHERE job_id = ${resources.jobs.<name>_job.id}
               AND result_state IN ('FAILED', 'ERROR', 'TIMED_OUT', 'CANCELED')
               AND period_end_time >= current_timestamp() - INTERVAL <lookback> MINUTES
           )
           SELECT run_id, period_start_time, period_end_time, result_state,
                  termination_code, COUNT(*) OVER () AS n_failed_runs
           FROM failed ORDER BY period_end_time DESC

         schedule:
           quartz_cron_schedule: ${var.alert_quartz_cron_expression}
           timezone_id: Europe/Paris
           pause_status: ${var.alert_pause_status}

         custom_summary: >-
           🔴 [${bundle.target}] job_<name> a échoué — {{QUERY_RESULT_VALUE}} run(s) en échec
         custom_description: >-
           <p>Le job Databricks <strong>job_<name>-${bundle.target}</strong> a échoué.
           {{QUERY_RESULT_VALUE}} run(s) en échec détecté(s) :</p>
           {{QUERY_RESULT_TABLE}}
           <p><a href="{{ALERT_URL}}">Voir l'alerte</a> &nbsp;|&nbsp;
           <a href="{{QUERY_URL}}">Voir la requête</a></p>

         evaluation:
           comparison_operator: GREATER_THAN
           source:
             name: n_failed_runs
           threshold:
             value:
               double_value: 0
           empty_result_state: OK
           notification:
             notify_on_ok: false
             retrigger_seconds: 0
             subscriptions:
               - destination_id: ${var.teams_alert_destination_id}
   ```
   `<lookback>` is the alert-check interval (e.g. 90 minutes for an hourly job, checked with
   margin) — greater than the gap between two alert runs so nothing is missed between checks.

## Rules

- **One alert can cover several related jobs** (`job_id IN (...)`) when they're deployed and
  operated together, or **one alert per job** when they're independent — match the alert's scope
  to how the jobs are actually operated, not a fixed rule.
- The alert's own schedule is **derived from the job's cron**, not independent — never poll
  continuously for a job that only runs occasionally.
- `notify_on_ok: false` and `retrigger_seconds: 0` — the alert fires once per detected failure
  window, it doesn't re-notify on every subsequent check while still failing, and it doesn't
  send a "back to OK" message (there's nothing actionable in that for this use case).
