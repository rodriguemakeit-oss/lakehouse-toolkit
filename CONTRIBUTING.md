# Contributing to lakehouse-toolkit

Development standards and tool adapters for Databricks data pipeline projects. Rules live only
in `standards/`; every other file in this repo points to them.

## Design principles

- **Standards are the source of truth.** Skills, Copilot instructions, and prompt files *apply*
  standards; they don't restate them — they link to `standards/*.md`. Name the concern, not the
  mutable value (e.g. "respect the reject-rate threshold", not a specific number) so a value
  change only touches the standard.
- **One rule set, three tool-native formats.** `skills/*/SKILL.md` follows the open **Agent
  Skills standard** ([agentskills.io](https://agentskills.io)) — Claude Code and Databricks
  Genie Code both read it natively, same file, two discovery folders
  (`.claude/skills/` vs `.assistant/skills/`). `.github/instructions/*.instructions.md` +
  `.github/prompts/*.prompt.md` + `.github/copilot-instructions.md` are GitHub Copilot's native
  formats. `templates/CLAUDE.md` is auto-discovered by both Claude Code and Genie Code. All of
  it points at the same `standards/`. A rule evolution is a single edit there.
- **Vendored, not remotely referenced.** None of the three tools read a separate repo the way a
  CLI can with an environment variable — GitHub Copilot and Genie Code only read files inside
  the repo/workspace they're open in. So project repos get a **copy** of this repo's `.github/`,
  `skills/`, `templates/CLAUDE.md`, and `standards/` via `scripts/install.sh`, re-synced when
  this platform changes, rather than a live pointer. Keep every vendored file self-contained (no
  path assumptions about where `lakehouse-toolkit` itself happens to sit on disk) so the copy
  works standalone.
- **Codebase structure and dev practice are fixed, not detected.** Every pipeline follows
  `standards/project-layout.md`'s structure, is plain modular Python (no notebooks, no magic
  commands), and ships with unit tests. An existing project that predates these rules and does
  it differently is a known migration gap to flag, not a variant to keep documenting as
  equally valid.
- **Patterns actually seen in practice, generalized.** Where this platform doesn't mandate a
  specific mechanism (which secret-resolution pattern, which incremental-read pattern), it
  documents the proven options and says "pick whichever fits" rather than inventing a
  hypothetical one — but doesn't treat every deviation as a pattern worth keeping either.
- **No project-specific identifiers in this repo.** Standards/skills use placeholders
  (`<catalog>`, `<project>`, `${var.x}`) — never a real bucket name, catalog name, service
  principal id, or workspace host. Those live in a target project's own `databricks.yml` and
  `config/settings.py`, not here.
- **English-only** canonical content.
- **Keep it lean.** A new piece must earn its place; prefer extending an existing standard to
  adding a near-duplicate.
- **Platform knowledge vs. portfolio convention are separate, complementary skill sets.** 12 skills
  under `skills/databricks-*` are vendored unmodified from
  [`databricks/databricks-agent-skills`](https://github.com/databricks/databricks-agent-skills)
  (license terms in [`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md)) — they teach *how a
  Databricks feature works*, generically. This platform's own skills teach *how portfolio wants it
  used*. Don't fold the two together: if an portfolio convention needs to layer on top of one of the
  vendored skills (the way `databricks-job-bundle` layers portfolio's job conventions on top of
  `databricks-dabs`'s generic bundle mechanics), write it as a new, separate skill that
  references the vendored one — never hand-edit a vendored skill in place (the license requires
  marking changed files as changed, and it'll be silently lost on the next re-pull anyway).
  Re-pull those 12 periodically from upstream to catch Databricks' own updates — there's no
  auto-sync.

## How to add a component

| Add a… | Where | Then |
|---|---|---|
| **Standard** | `standards/<name>.md` | link it from the skills/instructions/prompts that apply it — pointer only, no rule text |
| **Skill** | `skills/<name>/SKILL.md` (Agent Skills standard frontmatter: `name`, `description`) | reference its standard(s); it's automatically available to Claude Code and Genie Code once vendored — add the matching `.github/prompts/<name>.prompt.md` (frontmatter: `agent: agent`, `description`) so Copilot Chat gets the same procedure via `/<name>` |
| **Copilot instruction** | `.github/instructions/<name>.instructions.md` (frontmatter: `applyTo`) | point to the matching standard only, add reminders (not new rules) |
| **Copilot prompt file** | `.github/prompts/<name>.prompt.md` | keep it in lockstep with the matching `skills/<name>/SKILL.md` — same procedure, two formats |

Whenever `standards/`, `.github/`, or `skills/` change, re-run `scripts/install.sh` against any
project repo that should pick up the update (or ask its maintainer to).

## Committed vs local

- **Committed in this repo**: everything under `standards/`, `skills/`, `.github/`,
  `templates/`, `scripts/`.
- **Committed in a *project* repo, after vendoring**: its own copies of the above, plus
  project-specific notes appended below the vendored block in `copilot-instructions.md` /
  `CLAUDE.md` — `install.sh` preserves those on re-sync.

## Versioning

Bump `version` in `.claude-plugin/plugin.json` on every notable change (new skill/standard, or a
wording fix that changes behavior). Commits follow **Conventional Commits**
(`standards/commits.md`).
