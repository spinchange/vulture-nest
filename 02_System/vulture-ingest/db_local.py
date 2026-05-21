from __future__ import annotations

import os
from datetime import datetime
from typing import Any
from uuid import UUID


USE_LOCAL_DB = os.environ.get("USE_LOCAL_DB", "false").strip().lower() in {"1", "true", "yes", "on"}
LOCAL_DB_DSN = os.environ.get("LOCAL_DB_DSN", "postgresql://postgres:postgres@localhost:5432/vulture_ingest")


def _lazy_import_psycopg2():
    try:
        import psycopg2
        from psycopg2.extras import RealDictCursor
    except ImportError as exc:  # pragma: no cover - depends on environment
        raise RuntimeError("local DB mode requires `psycopg2-binary`. Install: pip install psycopg2-binary") from exc
    return psycopg2, RealDictCursor


def _table_for_path(path: str) -> str:
    mapping = {
        "/rest/v1/source_pages": "source_pages",
        "/rest/v1/source_chunks": "source_chunks",
        "/rest/v1/source_events": "source_events",
    }
    table = mapping.get(path)
    if not table:
        raise ValueError(f"Unsupported local DB path: {path}")
    return table


def _vector_literal(value: list[float] | None) -> str | None:
    if value is None:
        return None
    return "[" + ",".join(str(item) for item in value) + "]"


def _split_params(params: dict[str, Any] | None) -> tuple[str, dict[str, Any], str | None, str | None]:
    params = params or {}
    select_clause = params.get("select") or "*"
    order_clause = params.get("order")
    on_conflict = params.get("on_conflict")
    filters = {key: value for key, value in params.items() if key not in {"select", "order", "on_conflict"}}
    return str(select_clause), filters, str(order_clause) if order_clause else None, str(on_conflict) if on_conflict else None


def _build_where(filters: dict[str, Any]) -> tuple[str, dict[str, Any]]:
    clauses: list[str] = []
    values: dict[str, Any] = {}
    index = 0
    for column, raw_value in filters.items():
        if raw_value is None:
            continue
        if not isinstance(raw_value, str):
            index += 1
            key = f"w{index}"
            clauses.append(f"{column} = %({key})s")
            values[key] = raw_value
            continue

        if raw_value.startswith("eq."):
            index += 1
            key = f"w{index}"
            clauses.append(f"{column} = %({key})s")
            values[key] = raw_value[3:]
            continue
        if raw_value.startswith("neq."):
            index += 1
            key = f"w{index}"
            clauses.append(f"{column} != %({key})s")
            values[key] = raw_value[4:]
            continue
        if raw_value.startswith("in.(") and raw_value.endswith(")"):
            members = [item for item in raw_value[4:-1].split(",") if item]
            index += 1
            key = f"w{index}"
            clauses.append(f"{column} = ANY(%({key})s)")
            values[key] = members
            continue
        raise ValueError(f"Unsupported PostgREST filter: {column}={raw_value}")

    if not clauses:
        return "", values
    return " WHERE " + " AND ".join(clauses), values


def _build_order(order_clause: str | None) -> str:
    if not order_clause:
        return ""
    parts = order_clause.split(".")
    column = parts[0]
    direction = "ASC"
    if len(parts) > 1 and parts[1].lower() == "desc":
        direction = "DESC"
    return f" ORDER BY {column} {direction}"


def _prepare_row(row: dict[str, Any]) -> tuple[list[str], list[str], dict[str, Any]]:
    columns: list[str] = []
    placeholders: list[str] = []
    values: dict[str, Any] = {}
    for column, value in row.items():
        columns.append(column)
        if column == "embedding" and value is not None:
            placeholders.append(f"%({column})s::extensions.vector")
            values[column] = _vector_literal(value)
        else:
            placeholders.append(f"%({column})s")
            values[column] = value
    return columns, placeholders, values


def _build_returning(select_clause: str) -> str:
    return "" if select_clause == "*" else select_clause


def _fetch_all(cursor) -> list[dict[str, Any]]:
    rows = cursor.fetchall()
    return [{key: _coerce_value(value) for key, value in dict(row).items()} for row in rows]


def _coerce_value(value: Any) -> Any:
    if isinstance(value, UUID):
        return str(value)
    if isinstance(value, datetime):
        return value.isoformat().replace("+00:00", "Z")
    return value


def _execute_rpc(cursor, payload: dict[str, Any] | None) -> list[dict[str, Any]]:
    args = dict(payload or {})
    args["query_embedding"] = _vector_literal(args.get("query_embedding"))
    cursor.execute(
        """
        SELECT * FROM match_documents(
            %(query_embedding)s::extensions.vector,
            %(match_threshold)s,
            %(match_count)s,
            %(filter_domain)s
        )
        """,
        args,
    )
    return _fetch_all(cursor)


def _handle_get(cursor, path: str, params: dict[str, Any] | None) -> list[dict[str, Any]]:
    table = _table_for_path(path)
    select_clause, filters, order_clause, _ = _split_params(params)
    where_sql, values = _build_where(filters)
    order_sql = _build_order(order_clause)
    cursor.execute(f"SELECT {select_clause} FROM {table}{where_sql}{order_sql}", values)
    return _fetch_all(cursor)


def _handle_insert(cursor, path: str, payload: dict[str, Any] | list[dict[str, Any]] | None, params: dict[str, Any] | None, prefer: str | None) -> list[dict[str, Any]]:
    if path == "/rest/v1/rpc/match_documents":
        return _execute_rpc(cursor, payload if isinstance(payload, dict) else None)

    table = _table_for_path(path)
    rows = payload if isinstance(payload, list) else [payload or {}]
    if not rows:
        return []

    select_clause, _, _, on_conflict = _split_params(params)
    prefer = prefer or ""
    merge_duplicates = "resolution=merge-duplicates" in prefer
    return_representation = "return=representation" in prefer

    columns, placeholders, values = _prepare_row(rows[0])
    value_sql: list[str] = []
    merged_values: dict[str, Any] = {}
    for row_index, row in enumerate(rows):
        row_columns, row_placeholders, row_values = _prepare_row(row)
        if row_columns != columns:
            raise ValueError("All inserted rows must share the same columns.")
        renamed_placeholders: list[str] = []
        for column in columns:
            key = f"{column}_{row_index}"
            merged_values[key] = row_values[column]
            if column == "embedding" and row_values[column] is not None:
                renamed_placeholders.append(f"%({key})s::extensions.vector")
            else:
                renamed_placeholders.append(f"%({key})s")
        value_sql.append("(" + ", ".join(renamed_placeholders) + ")")

    conflict_sql = ""
    if merge_duplicates:
        if not on_conflict:
            raise ValueError("Local upserts require params['on_conflict'].")
        assignments = [f"{column} = EXCLUDED.{column}" for column in columns if column != on_conflict]
        conflict_sql = f" ON CONFLICT ({on_conflict}) DO UPDATE SET " + ", ".join(assignments)

    returning_sql = ""
    if return_representation:
        returning_columns = _build_returning(select_clause)
        returning_sql = f" RETURNING {returning_columns}"

    cursor.execute(
        f"""
        INSERT INTO {table} ({", ".join(columns)})
        VALUES {", ".join(value_sql)}
        {conflict_sql}
        {returning_sql}
        """,
        merged_values,
    )
    if return_representation:
        return _fetch_all(cursor)
    return []


def _handle_patch(cursor, path: str, payload: dict[str, Any] | None, params: dict[str, Any] | None, prefer: str | None) -> list[dict[str, Any]]:
    table = _table_for_path(path)
    row = payload or {}
    assignments: list[str] = []
    values: dict[str, Any] = {}
    for index, (column, value) in enumerate(row.items(), start=1):
        key = f"s{index}"
        assignments.append(f"{column} = %({key})s")
        values[key] = value
    where_sql, where_values = _build_where({key: value for key, value in (params or {}).items() if key != "select"})
    values.update(where_values)

    returning_sql = ""
    if prefer and "return=representation" in prefer:
        select_clause = str((params or {}).get("select") or "*")
        returning_sql = f" RETURNING {select_clause}"

    cursor.execute(f"UPDATE {table} SET {', '.join(assignments)}{where_sql}{returning_sql}", values)
    if returning_sql:
        return _fetch_all(cursor)
    return []


def _handle_delete(cursor, path: str, params: dict[str, Any] | None) -> list[dict[str, Any]]:
    table = _table_for_path(path)
    _, filters, _, _ = _split_params(params)
    where_sql, values = _build_where(filters)
    cursor.execute(f"DELETE FROM {table}{where_sql}", values)
    return []


def local_db_request(
    method: str,
    path: str,
    payload: dict[str, Any] | list[dict[str, Any]] | None = None,
    params: dict[str, Any] | None = None,
    prefer: str | None = None,
) -> Any:
    psycopg2, RealDictCursor = _lazy_import_psycopg2()
    method = method.upper()

    try:
        with psycopg2.connect(LOCAL_DB_DSN) as connection:
            with connection.cursor(cursor_factory=RealDictCursor) as cursor:
                if method == "GET":
                    return _handle_get(cursor, path, params)
                if method == "POST":
                    return _handle_insert(cursor, path, payload, params, prefer)
                if method == "PATCH":
                    return _handle_patch(cursor, path, payload if isinstance(payload, dict) else None, params, prefer)
                if method == "DELETE":
                    return _handle_delete(cursor, path, params)
                raise ValueError(f"Unsupported local DB method: {method}")
    except psycopg2.Error as exc:  # pragma: no cover - depends on runtime DB
        raise RuntimeError(f"Local PostgreSQL request failed: {exc.pgerror or exc}") from exc
