---
applyTo: "resources/**/*.alert.yml"
---

# Job failure alerting — Copilot path-scoped instructions

Apply the canonical standard **`standards/alerting.md`** (in this repo's `standards/`); the
`/databricks-failure-alert` prompt (Copilot Chat) or `databricks-failure-alert` skill (Claude
Code) wires one up. **Read it — don't restate or reinvent it.**

Reminders (full text in the standard):

- SQL Alert v2 + an **Email-type notification destination** (webhooks aren't allowed on these
  workspaces) pointing at the Teams channel's generated address; same `display_name` across
  workspaces so one `lookup:` resolves everywhere.
- Query `system.lakeflow.job_run_timeline` filtered on the job's id(s) and a lookback window
  larger than the alert's own check interval.
- The alert's cron is **derived from, not linked to,** the job's own cron (~30 min offset) —
  keep them in sync by hand if the job's schedule changes.
- `alert_pause_status` defaults `PAUSED`; unpause only on the target(s) where it should actually
  fire.
- `notify_on_ok: false`, `retrigger_seconds: 0` — fire once per detected failure window.
- One alert can cover several jobs operated together, or one per job — match how they're
  actually operated.
