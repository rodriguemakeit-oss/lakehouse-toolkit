# Standard — Commits

Follow the spirit of **Conventional Commits**: `<type>: <description>`, optionally
`<type>(<scope>): <description>` when a scope adds clarity. Not strictly enforced across
projects on this stack (no `commit-msg` hook seen in practice) — treat it as a default to write
by, not a rule to police; match the target project's existing style (some write `type :
description` with a space before the colon) rather than reformatting past commits.

- Types: `feat`, `fix`, `refactor`, `docs`, `chore`, `perf`.
- One logical change per commit; a schema migration (`delta-table-migration` skill) is its own
  commit, not bundled with an unrelated change.
- Body explains the *why* when it isn't self-evident from the diff (a business rule, a data
  quality threshold chosen, a schema change's impact on downstream consumers).
