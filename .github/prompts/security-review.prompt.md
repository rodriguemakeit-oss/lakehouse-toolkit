---
agent: agent
description: Run the security/PII/resources-as-code checklist on a diff or targeted area, ranked by severity
---

Run a security review. Apply `standards/security.md` as the checklist. Scope to the diff when
one exists (`git diff` staged or vs the base branch); otherwise audit the targeted area. This is
a **review**: report findings, do not edit pipeline code.

1. Identify the changed/targeted files and sensitive surfaces: `databricks.yml` /
   `resources/*.yml` (grants, run-as identity, alert destinations), `src/` modules (new external
   source/sink), any column newly added or exposed.
2. Walk the checklist:
   - **Committed secrets**: no hardcoded keys/tokens/connection strings anywhere. Check git
     history, not just the working tree: `git ls-files | grep -iE '\.env|secret|credential'` and
     `git log --all -- <suspect-file>` — a file can be gitignored today and still have a real
     credential in an old commit. Treat any hit as Critical regardless of whether the file
     still exists.
   - **Secrets pattern**: `dbutils.secrets.get` or a UC service credential — never a literal;
     only scope/key names in task parameters.
   - **Identity**: `prod` (and any shared target) runs as a service principal, never a personal
     account or PAT.
   - **Grants**: least privilege, no `ALL PRIVILEGES`/account-wide grants, raw and curated
     catalogs/schemas have separate scoped grants.
   - **PII**: newly exposed columns tagged; exposure masked or explicitly justified; no PII in
     logs or quarantine records without matching access control.
   - **Dependencies**: flag any new external library that isn't pinned or vetted.
   - **Resources as code**: any job/alert/grant that looks like it was created outside
     `resources/*.yml`.
   - **No notebooks/magic commands**: a `.ipynb` or notebook-source `.py` in `src/` — flag it,
     it's usually where the other checks above get skipped.
3. Gather evidence with `grep`/`git log --all`/`git diff`.
4. Report findings ranked **Critical / High / Medium / Low**, each with file:line and a concrete
   fix.
5. End with a verdict: **PASS** / **PASS with required fixes** / **BLOCK**.
