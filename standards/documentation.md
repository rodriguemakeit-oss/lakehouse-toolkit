# Standard — Documentation

- Write docs **from the real code and job/resource definitions** — no invented behavior, no
  drift.
- **`docs/README.md` is required** on every pipeline/bundle and covers, at minimum:
  - the **technical choices made** and why (pipeline shape variant, incremental-read pattern,
    idempotency mechanism — `standards/databricks-pipeline.md`);
  - the **data sources** (system, table/API, owner if known) and the **published outputs**
    (`catalog.schema.table`);
  - the **git repository address** (so anyone landing on a dashboard/table/job can find the
    code that produced it);
  - schedule and owner.
  Keep it accurate to the deployed bundle — update it in the same PR as the change it describes,
  not as an afterthought.
- Docstrings on public functions in `src/<package>/`: what it does, the key columns it relies
  on, and any non-obvious business rule (the *why*, not a restatement of the code).
- Keep column-level comments on published tables in sync with what's actually there (Unity
  Catalog table/column comments) — that's what consumers see; treat it as part of the contract.
- **Confluence export**: some projects keep a `CONFLUENCE_DOC.md` at the repo root (overview,
  architecture, repo structure, parameters, data model per layer, sources, job, deployment,
  contacts) that gets synced to the team's Confluence space. When a project has one, keep it
  accurate to the deployed bundle — regenerate the sections that map 1:1 to `databricks.yml`/
  `resources/*.yml` rather than hand-editing them out of sync.
- **Ops runbooks** (e.g. `databricks-teams-failure-alert-runbook.md`, or any `docs/*-runbook.md`)
  are a valid documentation artifact when they're written to be **handed to Claude Code in a
  fresh session with no prior context** — a numbered checklist with prerequisites, exact
  commands, and the file/resource it produces. Write new recurring procedures this way before
  they're formalized as a skill in this platform.
- Scope: `docs/README.md`, docstrings, Unity Catalog comments, Confluence exports, runbooks.
  Never invent a metric definition or a data contract that isn't already implemented — flag the
  gap instead of guessing.
