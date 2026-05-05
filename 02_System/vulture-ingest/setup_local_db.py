from __future__ import annotations

import os
from pathlib import Path


LOCAL_DB_DSN = os.environ.get("LOCAL_DB_DSN", "postgresql://postgres:postgres@localhost:5432/vulture_ingest")
MODULE_DIR = Path(__file__).resolve().parent


def main() -> int:
    try:
        import psycopg2
    except ImportError as exc:
        raise RuntimeError("setup_local_db requires `psycopg2-binary`. Install: pip install psycopg2-binary") from exc

    schema_path = MODULE_DIR / "schema.sql"
    schema_sql = schema_path.read_text(encoding="utf-8")

    with psycopg2.connect(LOCAL_DB_DSN) as connection:
        with connection.cursor() as cursor:
            cursor.execute("CREATE SCHEMA IF NOT EXISTS extensions;")
            cursor.execute("CREATE EXTENSION IF NOT EXISTS vector WITH SCHEMA extensions;")
            cursor.execute("CREATE EXTENSION IF NOT EXISTS pgcrypto;")
            cursor.execute(schema_sql)

    print(f"Local PostgreSQL schema initialized from {schema_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
