# Vulture Ingest Migrations

`schema.sql` is the baseline for fresh databases.

`migrations/*.sql` are additive in-place upgrades for existing databases:
- files are applied in lexical order
- each file should be idempotent where practical
- `apply-migration.ps1` records applied files in `schema_migrations`

Current convention:
- filename: `YYYY-MM-DD_short_description.sql`
- keep each file focused on one schema change set
