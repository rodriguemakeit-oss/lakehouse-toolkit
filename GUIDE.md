# lakehouse-toolkit

[![version](https://img.shields.io/badge/version-0.7.0-blue.svg)](./.claude-plugin/plugin.json)
[![Claude Code](https://img.shields.io/badge/Claude_Code-D97757?logo=anthropic&logoColor=white)](#for-claude-code)
[![GitHub Copilot](https://img.shields.io/badge/GitHub_Copilot-24292e?logo=githubcopilot&logoColor=white)](#for-github-copilot)
[![Genie Code](https://img.shields.io/badge/Databricks_Genie_Code-demo-user?logo=databricks&logoColor=white)](#for-databricks-genie-code)

Development standards, skills, and coding-assistant instructions for **Databricks data
pipeline** projects (plain modular Python + SQL, no notebooks). One set of rules in
`standards/`, applied consistently across the three coding assistants a project might touch:
**Claude Code**, **GitHub Copilot**, and Databricks' own **Genie Code**.

This README is the full reference — what every file is, what it does, and exactly how to use
this platform as a developer starting a new project. For how the platform itself is designed
and how to contribute to it, see [CONTRIBUTING.md](./CONTRIBUTING.md).

## Contents

- [Why this exists](#why-this-exists)
- [Quick start — GitHub Copilot (VS Code)](#quick-start--github-copilot-vs-code)
- [Quick start — Claude Code](#quick-start--claude-code)
- [Quick start — Databricks Genie Code](#quick-start--databricks-genie-code)
- [Reference: standards](#reference-standards)
- [Reference: skills](#reference-skills)
- [Reference: GitHub Copilot files](#reference-github-copilot-files)
- [Reference: Claude Code / Genie Code files](#reference-claude-code--genie-code-files)
- [How vendoring works (`install.sh`)](#how-vendoring-works-installsh)
- [For GitHub Copilot](#for-github-copilot)
- [For Databricks Genie Code](#for-databricks-genie-code)
- [For Claude Code](#for-claude-code)
- [Troubleshooting](#troubleshooting)
- [In short](#in-short)

## Why this exists

Databricks pipeline projects at portfolio were converging on a set of conventions the hard way —
project by project, mostly undocumented, sometimes contradicting each other (which secret
pattern, whether notebooks are OK, whether tests are expected). This repo makes those
conventions explicit once, in `standards/`, and packages them so any of the three coding
assistants a developer might use applies them automatically — no one has to remember or
re-explain the rules project after project.

Everything else in this repo (`skills/`, `.github/`, `templates/CLAUDE.md`) is a **pointer** to
`standards/` in a format one of those three tools understands natively. None of it restates a
rule — if a rule needs to change, it changes in exactly one file.

## Quick start — GitHub Copilot (VS Code)

This walks through using the platform the way a developer with **VS Code + GitHub Copilot**
would, starting from nothing.

### 1. Clone this repo once

```bash
git clone https://github.com/rodriguemakeit-oss/lakehouse-toolkit.git
```

Anywhere on your machine — you won't edit it, you'll just run its install script against your
own project(s).

### 2. Create your new project

```bash
mkdir my-new-pipeline && cd my-new-pipeline
git init
```

An empty folder is enough — `install.sh` doesn't require any pre-existing files.

### 3. Vendor the platform into it

```bash
/path/to/lakehouse-toolkit/scripts/install.sh /path/to/my-new-pipeline
```

This copies `standards/`, `.github/instructions/`, `.github/prompts/`,
`.github/copilot-instructions.md`, `CLAUDE.md`, `.claude/skills/`, and `.assistant/skills/`
into your project. See [How vendoring works](#how-vendoring-works-installsh) for exactly what
lands where and why.

### 4. Commit the result

```bash
cd my-new-pipeline
git add -A
git commit -m "chore: vendor lakehouse-toolkit"
```

Not required for the tools to work, but it gives you a clean checkpoint before you start adding
your own code.

### 5. Open it in VS Code

```bash
code .
```

Confirm the GitHub Copilot extension is active (status bar icon).

### 6. Confirm Copilot picked up the rules

Open Copilot Chat and ask:

> what custom instructions are you following for this repo?

It should describe the fixed codebase structure, the no-notebooks rule, `config/`, mandatory
tests, etc. — the content of `.github/copilot-instructions.md`, loaded with zero configuration.
If it doesn't, see [Troubleshooting](#troubleshooting).

### 7. Scaffold your first pipeline

In Copilot Chat:

```
/scaffold-databricks-pipeline
```

It asks for a package name and what the pipeline does, then creates `config/`, `src/<package>/`,
`resources/<name>.job.yml`, and `docs/README.md` following `standards/project-layout.md`.

### 8. Check it's actually following the rules

Open the `.py` file it created under `src/`, ask Copilot to add a transformation, and check it
stays in plain Python (no notebook, no `%sql` magic), reads config via
`config.get_settings(env)`, and stays modular — without you having to ask for any of that
explicitly. That's the instructions doing their job.

### 9. Try the other prompts

```
/pyspark-unit-test        # add the required unit tests
/databricks-job-bundle    # wire the schedule/trigger properly
/databricks-failure-alert # add the Teams alert once the job is real
/security-review          # run the checklist before you consider it done
```

## Quick start — Claude Code

Same platform, no VS Code required — this works equally well from a plain terminal. The main
difference from the Copilot flow: skills aren't invoked with a slash command, Claude picks the
relevant one itself by matching your request against each skill's description (you can also
name one explicitly).

### 1–4. Clone, create your project, vendor, commit

Identical to steps 1–4 of the [Copilot quick start](#quick-start--github-copilot-vs-code):

```bash
git clone https://github.com/rodriguemakeit-oss/lakehouse-toolkit.git
mkdir my-new-pipeline && cd my-new-pipeline && git init
/path/to/lakehouse-toolkit/scripts/install.sh /path/to/my-new-pipeline
cd my-new-pipeline
git add -A && git commit -m "chore: vendor lakehouse-toolkit"
```

### 5. Start Claude Code in the project

```bash
claude
```

(Run from inside `my-new-pipeline/` — or in VS Code's integrated terminal, or the Claude Code
VS Code extension, if you'd rather work there instead of a bare terminal.)

### 6. Confirm it loaded `CLAUDE.md`

Ask it directly:

> What are this project's conventions, and which skills do you have available here?

It should describe the same rules as the Copilot flow (`CLAUDE.md` is auto-discovered by
walking up the directory tree, no configuration) and list the skills from `.claude/skills/` —
the 7 portfolio ones plus the 12 Databricks platform-knowledge ones.

### 7. Ask for what you want — don't worry about naming the skill

> Scaffold a new pipeline called `orders_sync` that reads from Postgres and lands the result in
> a Delta table.

Claude matches this against `scaffold-databricks-pipeline`'s description and runs it — same
result as `/scaffold-databricks-pipeline` under Copilot, without you needing to know that name.
If you want to force a specific one: "use the `security-review` skill on this diff."

### 8. Check it's actually following the rules

Same check as the Copilot flow: ask it to extend the generated code and confirm it stays
notebook-free, modular, and reads config via `config.get_settings(env)` without being told.

### 9. Alternative: install as a plugin instead of vendoring

Useful if you're working across many projects and don't want to vendor into each one:

```bash
claude plugin marketplace add /path/to/lakehouse-toolkit   # or the git URL
claude plugin install lakehouse-toolkit
```

Skills become available in every project on that machine; you still won't get
`copilot-instructions.md`/`.github/instructions/` this way since those are Copilot-specific —
plugin install only covers the Claude Code side.

## Quick start — Databricks Genie Code

The same vendored files that make Claude Code work also make Genie Code work — same
`CLAUDE.md`, same `SKILL.md` files (just a different folder, `.assistant/skills/`). The
difference is *where* you run `install.sh`: against a local clone of the project's git repo,
then push — Genie Code reads whatever is in the Databricks Repo, which mirrors that same git
repo.

> These steps are based on Databricks' own documentation for Genie Code and Agent Skills (linked
> below) — this platform doesn't have a way to verify them end-to-end itself. If a step doesn't
> match what you see in your workspace, trust what's in front of you over this document and let
> us know so it can be corrected.

### 1–4. Clone, create your project, vendor, commit

Same as the [Claude Code quick start](#quick-start--claude-code) above.

### 5. Push the project to its git remote

```bash
git remote add origin <your project's git URL>
git push -u origin main
```

### 6. Add or sync it as a Databricks Repo

In the Databricks workspace: **Repos → Add Repo**, point it at the same git URL (or, if it's
already linked as a Repo, **Pull** to bring in the commit with the vendored files).

### 7. Open a notebook, the SQL editor, or the Lakeflow Pipelines Editor inside that Repo

Open the Genie Code panel and confirm it picked up the project:

> What are this project's conventions, and which skills do you have available?

It should describe the same rules (`CLAUDE.md`, auto-discovered) and list the skills from
`.assistant/skills/`.

### 8. Ask for what you want

Same as Claude Code — describe the task in plain language, Genie Code loads the relevant skill
from its `description` automatically, or `@`-mention one by name.

References: [Get coding help from Genie Code](https://docs.databricks.com/aws/en/notebooks/code-assistant),
[Extend Genie Code with agent skills](https://docs.databricks.com/aws/en/genie-code/skills).

## Reference: standards

The source of truth. Every skill, instruction, and prompt file below points to one or more of
these — none of them restate the rule, so this is the only place to actually read it in full.

| Standard | Covers |
|---|---|
| `databricks-pipeline.md` | The one canonical pipeline shape: modular Python, no notebooks, no magic commands (`%sql`, `%py`, `%md`, `%sh`, `%pip`). Idempotency (full-rebuild / `MERGE INTO` / upsert-with-no-op-guard), the two incremental-read patterns (Delta CDF, watermark), schema evolution. |
| `project-layout.md` | The fixed codebase structure — `databricks.yml`, `config/`, `resources/`, `src/<package>/`, `tests/`, `fixtures/`, `docs/`. Nothing lives outside it. |
| `config.md` | `config/` is the *only* place catalogs, schemas, secret scope/key names, external locations, volumes, and DB connection parameters are declared. |
| `orchestration.md` | Databricks Asset Bundle structure, `include:` pattern, triggers (cron / table-update / periodic), targets, service-principal `run_as` in prod. Resources exist **exclusively** as code in `resources/*.yml`. |
| `alerting.md` | The Teams failure-alert pattern: SQL Alert v2 + Email notification destination querying `system.lakeflow.job_run_timeline` (webhooks aren't allowed on these workspaces). |
| `data-quality.md` | Where to validate (the boundary where a consumer starts trusting the data), two implementations (Delta constraints vs. an accept/reject file gate), fail-vs-quarantine policy. |
| `testing.md` | Unit tests are **required**. Reuses the `databricks bundle init` template's `DatabricksSession` fixture and `fixtures/` loader — nothing custom to learn. |
| `security.md` | The two legitimate secret-resolution patterns (Databricks secret scope vs. UC service credential), service-principal identity, least-privilege grants, PII handling, and the git-history lesson (a `.gitignore` entry doesn't retroactively remove a committed secret). |
| `documentation.md` | `docs/README.md` is required per pipeline: technical choices made, data sources, git repo address, schedule, owner. |
| `commits.md` | Conventional-ish commits — a default to write by, matched to the target project's existing style, not strictly enforced. |

## Reference: skills

19 in total — 7 portfolio-specific ones below, plus 12 Databricks platform-knowledge ones further
down. All 19 follow the open **[Agent Skills](https://agentskills.io) standard** — the same
`SKILL.md` format is read natively by both **Claude Code** and **Databricks Genie Code**.
GitHub Copilot gets the same procedure as a **prompt file** (`.github/prompts/<name>.prompt.md`,
invoked with `/<name>` in Copilot Chat) for all 19 too.

| Skill (`/<name>` in Copilot Chat) | What it does | Standards it applies |
|---|---|---|
| `scaffold-databricks-pipeline` | New pipeline: canonical structure, modular Python package, required tests, job bundle stub, `docs/README.md`. | `project-layout`, `databricks-pipeline`, `config`, `testing`, `documentation` |
| `databricks-job-bundle` | Wire or update a pipeline's Asset Bundle job: trigger type, documented variables, service-principal `run_as` in prod, Python-only tasks (never `notebook_task`). | `orchestration`, `security` |
| `databricks-failure-alert` | Add a Teams failure alert for an already-deployed job: notification destination, alert variables, `resources/<name>_failure_alert.alert.yml`. | `alerting` |
| `delta-table-migration` | Evolve a Delta table's schema safely: consumer search, mandatory manual review, rollback plan via Delta time travel (no native `downgrade()`). | `databricks-pipeline`, `data-quality` |
| `data-quality-check` | Add validation at a pipeline boundary — Delta constraints or an accept/reject gate — with a fail-vs-quarantine decision. | `data-quality` |
| `pyspark-unit-test` | Scaffold or extend the required unit tests for a `src/<package>/` module, using the template's fixture setup. | `testing` |
| `security-review` | Run the secrets/grants/PII/resources-as-code checklist against a diff or a targeted area, ranked Critical→Low, including a git-history check for committed secrets. | `security` |

### Platform-knowledge skills (Databricks features, not portfolio conventions)

12 additional skills, unmodified from
[`databricks/databricks-agent-skills`](https://github.com/databricks/databricks-agent-skills)
(see [`THIRD_PARTY_NOTICES.md`](./THIRD_PARTY_NOTICES.md) for the license) — these cover *how a
Databricks feature works*, complementing the skills above, which cover *how portfolio wants it
used*. Full parity with the 7 portfolio skills: available via `.claude/skills/` (Claude Code),
`.assistant/skills/` (Genie Code), **and** `.github/prompts/*.prompt.md` (`/<name>` in Copilot
Chat) — each Copilot prompt is a thin pointer to the vendored `SKILL.md` rather than a
duplicate, so there's one copy of the actual guidance to keep current.

| Skill (`/<name>` in Copilot Chat) | Covers |
|---|---|
| `databricks-core` | CLI, authentication, profile selection, data exploration — parent skill for the rest. |
| `databricks-dabs` | Full Databricks Asset Bundle mechanics: structure, all resource types, deploy/validate, permissions — complements `databricks-job-bundle`'s portfolio conventions. |
| `databricks-jobs` | Lakeflow Jobs orchestration: task types, triggers, schedules, notifications. |
| `databricks-pipelines` | Lakeflow Declarative Pipelines (formerly DLT), batch and streaming. |
| `databricks-python-sdk` | Python SDK, Databricks Connect, CLI, REST API. |
| `databricks-unity-catalog` | Unity Catalog system tables — lineage, audit, billing (what `alerting.md`'s `system.lakeflow` queries build on). |
| `databricks-dbsql` | SQL warehouse patterns. |
| `databricks-spark-structured-streaming` | Spark Structured Streaming patterns. |
| `databricks-lakeflow-connect` | Managed ingestion connectors. |
| `databricks-serverless-migration` | Migrating classic-compute workloads to serverless. |
| `databricks-synthetic-data-gen` | Realistic synthetic/test data with Faker — useful for `fixtures/`. |
| `databricks-lakebase` | Lakebase (managed Postgres): projects, branching, synced tables. |

## Reference: GitHub Copilot files

Native GitHub Copilot formats (VS Code, JetBrains, Visual Studio, github.com) — auto-loaded,
nothing to configure once vendored into a project.

**`.github/copilot-instructions.md`** — repo-wide, applies to every request. Summarizes the
non-negotiables (fixed structure, no notebooks, `config/` centralization, required tests,
resources-as-code, security) and links out to everything below.

**`.github/instructions/*.instructions.md`** — path-scoped, apply automatically based on the
file being edited (native `applyTo` glob matching):

| File | Applies to (`applyTo`) | Points to |
|---|---|---|
| `pipeline.instructions.md` | `**/*.py`, `**/*.ipynb` | `databricks-pipeline`, `project-layout`, `config`, `data-quality` |
| `orchestration.instructions.md` | `databricks.yml`, `resources/**/*.job.yml`, `resources/**/*.pipeline.yml` | `orchestration` |
| `alerting.instructions.md` | `resources/**/*.alert.yml` | `alerting` |
| `config.instructions.md` | `config/**/*.py` | `config` |
| `tests.instructions.md` | `tests/**`, `fixtures/**` | `testing` |
| `documentation.instructions.md` | `**/*.md` | `documentation` |

**`.github/prompts/*.prompt.md`** — one per skill, all 19 (see the skills tables above), invoked
on-demand with `/<name>` in Copilot Chat. `agent: agent` frontmatter. For the 7 portfolio skills the
body is the same procedure as the matching `SKILL.md`; for the 12 Databricks platform-knowledge
skills the body is a short pointer to the vendored `SKILL.md` (and its `references/` folder)
rather than a duplicate — one copy of the actual content to keep current.

## Reference: Claude Code / Genie Code files

**`templates/CLAUDE.md`** (vendored as `CLAUDE.md` at the project root) — auto-discovered by
both Claude Code and Databricks Genie Code by walking up the directory tree from wherever
you're working, no configuration needed. Same content as `copilot-instructions.md`, adapted to
mention the skills available locally.

**`skills/*/SKILL.md`** — vendored into **two** locations because the two tools look in
different folders for the same open standard:

| Tool | Folder |
|---|---|
| Claude Code | `.claude/skills/<name>/SKILL.md` |
| Databricks Genie Code | `.assistant/skills/<name>/SKILL.md` |

Both auto-load the relevant skill based on its `description`, or you can invoke one by name
(Claude Code: ask for it by name; Genie Code: `@` mention in chat).

## How vendoring works (`install.sh`)

None of the three tools read a separate repo remotely — GitHub Copilot and Genie Code only read
files inside the repo/workspace they're open in (unlike a CLI tool, which can be pointed at an
arbitrary directory via an environment variable). So `scripts/install.sh` **copies** this
platform's files into a target project rather than linking to it:

```bash
./scripts/install.sh /path/to/target-project
```

| Source | Destination | On re-run |
|---|---|---|
| `standards/` | `<target>/standards/` | fully overwritten |
| `.github/instructions/` | `<target>/.github/instructions/` | fully overwritten |
| `.github/prompts/` | `<target>/.github/prompts/` | fully overwritten |
| `skills/` | `<target>/.claude/skills/` | fully overwritten |
| `skills/` | `<target>/.assistant/skills/` | fully overwritten |
| `.github/copilot-instructions.md` | `<target>/.github/copilot-instructions.md` | **merged** — see below |
| `templates/CLAUDE.md` | `<target>/CLAUDE.md` | **merged** — see below |

The two files a project might reasonably add its own notes to (`copilot-instructions.md`,
`CLAUDE.md`) use a marker comment,
`<!-- lakehouse-toolkit:vendored:start -->` … `<!-- lakehouse-toolkit:vendored:end -->`. On
re-run, `install.sh` replaces only the content **between** those markers with the latest
version from this repo — anything a project added below the "Project-specific notes" heading
survives. If a target file predates the markers entirely (hand-written before ever running
`install.sh`), it's left alone and the fresh version is written next to it as `*.new` for a
manual merge, rather than silently overwritten.

**Re-run `install.sh` any time this platform changes** to roll the update out to a project —
that's the whole update mechanism; there's no auto-sync.

## For GitHub Copilot

Works in VS Code, JetBrains, Visual Studio, and github.com — not a CLI-only trick, no
environment variable. Once vendored:

- `.github/copilot-instructions.md` applies to every Copilot Chat/inline-suggestion request.
- `.github/instructions/*.instructions.md` apply automatically based on the file you have open.
- `.github/prompts/*.prompt.md` are available as `/<name>` in Copilot Chat — all 19: the 7 portfolio
  ones (`/scaffold-databricks-pipeline`, `/databricks-job-bundle`, `/databricks-failure-alert`,
  `/delta-table-migration`, `/data-quality-check`, `/pyspark-unit-test`, `/security-review`) and
  the 12 Databricks platform-knowledge ones (`/databricks-core`, `/databricks-dabs`,
  `/databricks-jobs`, `/databricks-pipelines`, `/databricks-python-sdk`,
  `/databricks-unity-catalog`, `/databricks-dbsql`, `/databricks-spark-structured-streaming`,
  `/databricks-lakeflow-connect`, `/databricks-serverless-migration`,
  `/databricks-synthetic-data-gen`, `/databricks-lakebase`).

If your GitHub organization is on Copilot Business/Enterprise, it's worth checking with whoever
administers your GitHub instance whether **organization-level custom instructions** are
available — admin-configured once, applied to every repo automatically, no vendoring needed.
That has to be verified per-instance; a repo can't turn it on itself, so `install.sh` remains
the guaranteed-to-work path in the meantime.

## For Databricks Genie Code

Genie Code is Databricks' own AI assistant (not Claude Code — a separate product built by
Databricks), running inside notebooks, the SQL editor, the Lakeflow Pipelines Editor, and
dashboards. Once this platform is vendored into a Databricks Repo:

- `CLAUDE.md` is auto-discovered the same way Claude Code discovers it — no configuration.
- `.assistant/skills/` is auto-loaded based on the task's description, same `SKILL.md` files as
  Claude Code, per the Agent Skills standard.

References: [Agent skills for AI coding assistants](https://docs.databricks.com/aws/en/agent-skills/),
[Extend Genie Code with agent skills](https://docs.databricks.com/aws/en/genie-code/skills).

## For Claude Code

Two ways to use it:

- **Vendored** (same as the other two tools, via `install.sh`): `CLAUDE.md` + `.claude/skills/`
  land directly in the project — works immediately after `git clone`, no plugin install.
- **As a plugin**, useful while iterating on this platform itself or across many projects
  without vendoring into each one individually:
  ```bash
  claude plugin marketplace add /path/to/lakehouse-toolkit   # or the git URL
  claude plugin install lakehouse-toolkit
  ```

## Troubleshooting

**Copilot Chat doesn't mention any custom instructions when asked.** Confirm
`.github/copilot-instructions.md` actually exists in the project (did `install.sh` run
successfully? check `git status`). Confirm the Copilot extension is up to date — repo-wide
custom instructions support was added relatively recently. If it still doesn't pick it up on
your GitHub Enterprise instance, that's worth reporting rather than working around.

**A path-scoped instruction doesn't seem to apply.** Check the file you're editing actually
matches the `applyTo` glob in the [instructions table](#reference-github-copilot-files) —
these match on the file's path relative to the repo root.

**`/some-skill` isn't offered in Copilot Chat.** Confirm `.github/prompts/<name>.prompt.md`
exists and confirm your Copilot extension version supports prompt files (VS Code: recent
versions only).

**A project-specific note I added to `copilot-instructions.md`/`CLAUDE.md` disappeared after
re-running `install.sh`.** It was added *inside* the vendored markers instead of below the
"Project-specific notes" heading — see [how vendoring works](#how-vendoring-works-installsh).

**I changed a standard here but a project isn't picking it up.** Vendoring is a copy, not a
live link — re-run `install.sh` against that project and commit the result.

## In short

`standards/` is code: change it via PR + review, bump `version` in `.claude-plugin/plugin.json`
on every notable change, then re-run `scripts/install.sh` against each project repo to roll the
update out. See [CONTRIBUTING.md](./CONTRIBUTING.md) for design principles and how to add a new
standard/skill/instruction/prompt.
