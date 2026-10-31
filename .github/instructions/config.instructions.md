---
applyTo: "config/**/*.py"
---

# Configuration (`config/`) — Copilot path-scoped instructions

Apply the canonical standard **`standards/config.md`** (in this repo's `standards/`). **Read
it — don't restate or reinvent it.**

Reminders (full text in the standard):

- `config/` is the **only** place catalogs, schemas, secret scope/key names, external
  locations, volumes, and DB connection parameters are declared — nowhere else in the codebase.
- `config/` holds **references**, never values: a secret scope/key name is not sensitive by
  itself, the value behind it is (`standards/security.md`).
- One `Settings` shape per environment, resolved once via `get_settings(env)` — `env` comes from
  a job/CLI parameter, never hardcoded.
- Adding a new catalog/schema/secret/external location/volume/DB target means editing
  `config/settings.py` — not adding an inline constant somewhere in `src/<package>/`.
