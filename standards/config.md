# Standard — Configuration (`config/`)

All environment-dependent and Unity-Catalog-object references live in **`config/`** — nowhere
else. A module in `src/` imports from `config/`; it never redeclares a catalog name, a secret
scope, an external location, or a connection parameter inline
(`standards/project-layout.md`, `standards/security.md`).

## What belongs in `config/`

- **Catalogs & schemas** — the Unity Catalog `catalog`/`schema` the pipeline reads from and
  writes to, one set per environment (`dev`, `prod`, and any other bundle target).
- **Secrets** — the secret scope/key **names** resolved at runtime via
  `dbutils.secrets.get(scope, key)`, or the UC service credential **name** used to federate into
  a cloud secret store — never a secret value (`standards/security.md`).
- **External locations** — the Unity Catalog external location name/path the pipeline reads or
  writes through — not a raw cloud-storage URI hardcoded in a module.
- **Volumes** — the UC Volume path(s) used for state/checkpoints/fixtures.
- **DB connection parameters** — host/port/database *name*, and the secret scope/key used to
  resolve the password — never a literal connection string with an embedded credential.

## Shape

```python
# config/settings.py
from dataclasses import dataclass


@dataclass(frozen=True)
class Settings:
    catalog: str
    schema: str
    external_location: str
    state_volume: str
    db_host: str
    db_port: int
    db_name: str
    db_secret_scope: str
    db_secret_key: str


ENVIRONMENTS = {
    "dev": Settings(
        catalog="<project>_dev",
        schema="<schema>",
        external_location="<external-location-name>",
        state_volume="/Volumes/<catalog>/<schema>/state",
        db_host="<resolved-from-job-parameter-or-config>",
        db_port=5432,
        db_name="<db>",
        db_secret_scope="<project>-secrets",
        db_secret_key="db_password",
    ),
    "prod": Settings(...),
}


def get_settings(env: str) -> Settings:
    if env not in ENVIRONMENTS:
        raise ValueError(f"Unknown env '{env}', expected one of {list(ENVIRONMENTS)}")
    return ENVIRONMENTS[env]
```

## Rules

- `env` is resolved **once**, from a job/CLI parameter (`standards/orchestration.md`), passed
  into `get_settings()` at the top of `main.py` — never hardcoded, never re-derived deeper in
  the call stack.
- Adding a new catalog/schema/secret/external location/volume/DB target means editing
  `config/settings.py` — not adding a new inline constant somewhere in `src/<package>/`.
- `config/` holds **references**, never values: a secret scope/key name is not sensitive by
  itself, the value behind it is.
- If a project's config genuinely outgrows one file (many unrelated pipelines, each with very
  different settings), split by domain (`config/catalogs.py`, `config/secrets.py`, …) rather
  than letting a pipeline module define its own — `config/` stays the single place to look.
