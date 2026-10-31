# Standard — Orchestration (Databricks Asset Bundles)

Pipelines are scheduled as **Databricks Workflows**, defined and deployed via **Databricks
Asset Bundles** (DAB).

## Resources exist exclusively as code

**Every** Databricks resource — jobs, tasks, pipelines, alerts — is created and changed
**exclusively** through `resources/*.yml`. Never create or edit one by hand in the workspace UI,
and never provision one via the SDK/API from inside a script or ad hoc call. If it isn't in
`resources/`, it doesn't exist as far as this platform is concerned — a resource created any
other way gets silently overwritten (or diverges unnoticed) on the next `databricks bundle
deploy`, and nobody reviewed it going in.

## Structure

- `databricks.yml`: bundle name, `include: [resources/*.yml, resources/*/*.yml]`, `variables`
  (every one with a `description:` — a real, followed convention, not optional polish), and
  `targets`. Target names vary by project (`dev`/`prod`, or `dev`/`ppr`/`prod`) — use whatever
  the project already has.
- `resources/<name>.job.yml`: one job per pipeline. `resources/<name>_failure_alert.alert.yml`:
  its failure alert (`standards/alerting.md`, `databricks-failure-alert` skill).

## Tasks call Python, never a notebook

- **`python_wheel_task`** (`package_name`, `entry_point` matching a `[project.scripts]` entry in
  `pyproject.toml`) is the default — the pipeline is built as a wheel and the task runs its
  entrypoint.
- **`spark_python_task`** (`python_file: ../src/<package>/main.py`) is acceptable for a single
  small script that doesn't warrant packaging as a wheel yet.
- **`notebook_task` is not used** — see `standards/databricks-pipeline.md`.

## Triggers — pick the one that matches the pipeline, not cron by default

- `schedule: { quartz_cron_expression, timezone_id, pause_status }` — time-based; the common
  case.
- `trigger: { table_update: { condition: ANY_UPDATED, table_names: [...] } }` — event-driven off
  upstream Delta table changes; use it when the pipeline exists to react to another table
  changing, not to run on a clock.
- `trigger: { periodic: { interval: 1, unit: DAYS } }` — the DAB-template default; simplest
  cron-equivalent when an exact time of day doesn't matter.

## Rules

- **`dev` target is `UNPAUSED`** for fast iteration; **`prod`'s `pause_status` is explicit and
  reviewed** (some projects also unpause a `ppr`/pre-prod target — follow the project's existing
  convention).
- **`run_as: service_principal_name: <id>`** on the `prod` target — never a personal identity
  for the production run-as. A personal identity is fine in `dev`.
- **`permissions:`** grants `CAN_MANAGE` explicitly to maintainers — don't rely on implicit
  ownership from whoever deployed first.
- **`variables` with `lookup:`** (`notification_destination`, `warehouse`, …) resolve by name —
  keep the exact same display name across workspaces; override a `lookup` per-target only when a
  specific workspace genuinely lacks that named resource, with a comment saying why.
- **Environment/config values (catalog, schema, secret scope names, …) come from `config/`**
  (`standards/config.md`), passed into the task as parameters — a job's `base_parameters` sets
  `env` (and, if needed, an override), not the individual catalog/schema/secret values one by
  one.
- **`queue: { enabled: true }`** on jobs so a manual/overlapping trigger queues instead of
  failing outright; `performance_target: PERFORMANCE_OPTIMIZED` is the default seen in practice.
- Validate before every deploy: `databricks bundle validate`, then `databricks bundle deploy -t
  <target>`.

## Example

```yaml
# databricks.yml (excerpt)
variables:
  env:
    description: Environment name, resolved via config.get_settings(env)
    default: dev

targets:
  dev:
    mode: development
    default: true
    variables:
      env: dev
  prod:
    mode: production
    run_as:
      service_principal_name: <service-principal-id>
    variables:
      env: prod
    permissions:
      - user_name: <owner>@example.invalid
        level: CAN_MANAGE
```

```yaml
# resources/<name>.job.yml
resources:
  jobs:
    my_pipeline_job:
      name: "job_my_pipeline-${bundle.target}"
      schedule:
        quartz_cron_expression: "0 0 5 * * ?"
        timezone_id: Europe/Paris
        pause_status: PAUSED
      tasks:
        - task_key: run
          python_wheel_task:
            package_name: my_pipeline
            entry_point: main
            parameters: ["--env", "${var.env}"]
          environment_key: default
      environments:
        - environment_key: default
          spec:
            environment_version: "2"
            dependencies:
              - ../dist/*.whl
      queue:
        enabled: true
      performance_target: PERFORMANCE_OPTIMIZED
```
