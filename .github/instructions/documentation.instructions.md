---
applyTo: "**/*.md"
---

# Documentation — Copilot path-scoped instructions

Apply the canonical standard **`standards/documentation.md`** (in this repo's `standards/`).
**Read it — don't restate or reinvent it.**

Reminders (full text in the standard):

- Write **from the real code and job/resource definitions** — no invented behavior, no drift.
- **`docs/README.md` is required**: technical choices made and why, data sources, published
  outputs (`catalog.schema.table`), the **git repository address**, schedule, owner.
- Docstrings on public `src/<package>/` functions: the *why* of a non-obvious business rule, not
  a restatement of the code.
- Keep Unity Catalog table/column comments in sync with what's actually published.
- A `CONFLUENCE_DOC.md`, when a project has one, stays accurate to the deployed bundle. A
  `docs/*-runbook.md` meant to be handed to Claude Code cold is a valid doc artifact — write it
  as an executable checklist, not prose.
