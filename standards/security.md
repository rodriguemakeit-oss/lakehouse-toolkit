# Standard — Security (Databricks)

## Secrets — two legitimate patterns, use whichever the project already uses

- **Databricks secret scope**: `dbutils.secrets.get(scope, key)` at runtime. The scope/key
  **names** (never the values) live in `config/settings.py` (`standards/config.md`) and can
  safely flow through job parameters (`standards/orchestration.md`) so the same code works
  across environments with different underlying secrets.
- **Unity Catalog service credential → cloud secret store**: `dbutils.credentials
  .getServiceCredentialsProvider("<credential-name>")` federated into a cloud SDK session (e.g.
  boto3), then the actual secret is fetched from the cloud's secret manager (e.g. AWS Secrets
  Manager). Slightly more setup, avoids storing the secret in a Databricks-managed scope at all.

Either is fine; don't mix ad hoc alternatives in — no secret value ever hardcoded in `src/`,
`config/settings.py`, `databricks.yml`, or a `resources/*.yml` file. Never `print()` / log a
secret value, even for debugging.

## `.env*` files and git history — a real, observed failure mode

A `.env.dev`-style file with a real credential **can end up committed before it's added to
`.gitignore`** — and adding it to `.gitignore` afterwards does **not** remove it from history;
the file stays readable by anyone who can read the repo's git log. Concretely:

- Add `.env*` to `.gitignore` **before** the first commit that could contain one, not after.
- On an existing repo, don't assume `.gitignore` protects you — check with
  `git ls-files | grep -i env` and `git log --all -- <suspect-file>`.
- If a credential was ever committed (even once, even if the file was later deleted): **treat it
  as leaked** — rotate the credential, then purge it from history (`git filter-repo` or BFG) if
  the repo is or will be shared beyond a small trusted group. Deleting the file in a new commit
  is not sufficient on its own.

## Identity & access

- Jobs in `prod` (and any shared, non-dev target) **run as a service principal**
  (`run_as: service_principal_name`, `standards/orchestration.md`) — never a personal identity; a
  personal account leaving breaks the pipeline, and a personal PAT baked into a job is a standing
  credential-leak risk. A personal identity is fine in `dev`.
- **Least privilege via Unity Catalog grants** — scope write access to the pipeline's own
  catalog/schema and identity; no `ALL PRIVILEGES` / account-wide grant as a shortcut.
- Keep **raw and curated data in separate catalogs/schemas** (not just a table-name suffix) with
  separate grants — a consumer with gold access shouldn't implicitly get bronze/silver access.

## PII

- Identify and **tag PII columns** at the schema level as soon as they're introduced.
- **Mask or exclude PII in gold** unless a consumer has an explicit, reviewed need for it; prefer
  a dynamic view with column masking over granting raw table access.
- **No PII in logs or reject/quarantine records** written to a broadly-readable location — a
  quarantine table/path holding PII needs the same access controls as the source.

## Review triggers

Flag for a `security-review` skill pass before merging or scheduling in `prod`:

- A `.env*` or otherwise credential-shaped file is staged for commit, or found already committed.
- A new table/view is granted to a broader audience than before.
- PII columns are added, renamed, or newly exposed.
- A job's `run_as` identity or its grants change.
- A new external source/sink (API, external DB, secret scope) is added.
- A Databricks resource (job, alert, grant) appears to have been created outside
  `resources/*.yml` — see `standards/orchestration.md`'s exclusively-as-code rule; an
  out-of-band resource is a governance gap as much as a security one.
