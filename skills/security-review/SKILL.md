---
name: security-review
description: >
  Applies the data security checklist (secrets, Unity Catalog grants, PII exposure, service
  principal auth) to a diff or a targeted area, ranked by severity. Use before scheduling a
  pipeline in prod or on any change that touches grants/PII/secrets.
---

# Security review (data)

Apply `standards/security.md` as the checklist. Scope to the diff when one exists (`git diff`
staged or vs the base branch); otherwise audit the targeted area. This is a **review**: report
findings, do not edit pipeline code.

1. Identify the changed/targeted files and the sensitive surfaces: `databricks.yml` /
   `resources/*.yml` (grants, run-as identity, alert destinations), notebook/`src/` files (new
   external source/sink), any column newly added or exposed.
2. Walk the checklist:
   - **Committed secrets**: no hardcoded keys/tokens/connection strings in notebooks, `src/`, or
     bundle YAML. **Check git history, not just the working tree**: `git ls-files | grep -iE
     '\.env|secret|credential'` and `git log --all -- <suspect-file>` — a file can be gitignored
     *today* and still have a real credential sitting in an old commit
     (`standards/security.md`). Treat any hit as Critical regardless of whether the file still
     exists.
   - **Secrets pattern**: runtime secrets go through a Databricks secret scope
     (`dbutils.secrets.get`) or a UC service credential — never a literal wrapped to look like
     one; only scope/key *names* (not values) appear in `base_parameters`.
   - **Identity**: `prod` (and any shared target) jobs run as a **service principal**
     (`run_as: service_principal_name`), not a personal account or PAT.
   - **Grants (Unity Catalog)**: least privilege — no `ALL PRIVILEGES`/account-wide grants; raw
     and curated catalogs/schemas have separate, scoped grants.
   - **PII**: newly added/exposed columns identified and tagged if they carry PII; exposure in a
     published table is masked or explicitly justified, not incidental; no PII in logs or
     quarantine records without matching access control.
   - **Dependencies**: flag any new external library added to the pipeline's cluster/job
     environment that isn't pinned or vetted.
   - **Resources as code**: any job/alert/grant that looks like it was created outside
     `resources/*.yml` (`standards/orchestration.md`) — an out-of-band resource had no review.
   - **No notebooks / magic commands**: a `.ipynb` or notebook-source `.py`
     (`# COMMAND ----------`, `# MAGIC ...`) anywhere in `src/` violates
     `standards/databricks-pipeline.md` — flag it even though it's not itself a vulnerability,
     since it's usually where the other checks above get skipped.
3. Gather evidence with `grep`/`git log --all`/`git diff` where useful (e.g. grep for
   hardcoded-secret patterns, diff the `grants:`/`permissions:`/`run_as:` blocks).
4. Report findings ranked **Critical / High / Medium / Low**, each with file:line and a concrete
   fix.
5. End with a verdict: **PASS** / **PASS with required fixes** / **BLOCK**.
