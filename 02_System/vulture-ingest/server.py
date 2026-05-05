from __future__ import annotations

import asyncio
import json
import os
import signal
import sys
import time
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any
from urllib import error, parse, request

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import TextContent, Tool
except ImportError:  # pragma: no cover - keeps module importable without SDK
    Server = None
    stdio_server = None
    TextContent = None
    Tool = None


MODULE_DIR = Path(__file__).resolve().parent
if str(MODULE_DIR) not in sys.path:
    sys.path.insert(0, str(MODULE_DIR))

# Load environment variables from .env if it exists
try:
    from dotenv import dotenv_values

    for key, value in dotenv_values(MODULE_DIR / ".env").items():
        if value is not None and not os.environ.get(key):
            os.environ[key] = value
except ImportError:
    pass

from policy import (  # noqa: E402
    DEFAULT_POLICY_PATH,
    PipelinePolicy,
    PolicyDeniedError,
    PolicyError,
    RuntimeLedger,
    enforce_policy,
    load_policy,
    record_usage,
)
from epistemic_classifier import classify_draft  # noqa: E402
from conflict_templates import get_template, parse_conflict_report  # noqa: E402
from synthesis_rubric import check_synthesis_scope  # noqa: E402
from local_crawler import crawl_local  # noqa: E402
from provenance import generate_provenance_block, render_provenance_yaml  # noqa: E402


FIRECRAWL_API_BASE = os.environ.get("FIRECRAWL_API_BASE", "https://api.firecrawl.dev/v2")
FIRECRAWL_API_KEY = os.environ.get("FIRECRAWL_API_KEY", "")
OPENAI_API_BASE = os.environ.get("OPENAI_API_BASE", "https://api.openai.com/v1")
OPENAI_API_KEY = os.environ.get("OPENAI_API_KEY", "")
OPENAI_EMBEDDING_MODEL = os.environ.get("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")
SUPABASE_URL = os.environ.get("SUPABASE_URL", "").rstrip("/")
SUPABASE_SERVICE_KEY = os.environ.get("SUPABASE_SERVICE_KEY", "")
USE_LOCAL_CRAWLER = os.environ.get("USE_LOCAL_CRAWLER", "false").strip().lower() in {"1", "true", "yes", "on"}
USE_LOCAL_DB = os.environ.get("USE_LOCAL_DB", "false").strip().lower() in {"1", "true", "yes", "on"}
LOCAL_DB_DSN = os.environ.get("LOCAL_DB_DSN", "postgresql://postgres:postgres@localhost:5432/vulture_ingest")
POLICY_PATH = Path(os.environ.get("VULTURE_PIPELINE_POLICY_PATH", DEFAULT_POLICY_PATH))
WIKI_ROOT = Path(os.environ.get("VULTURE_WIKI_ROOT", Path(__file__).resolve().parents[2] / "01_Wiki"))
RUNTIME_LEDGER = RuntimeLedger()


TOOL_DEFINITIONS = [
    {
        "name": "propose_source_intake",
        "description": "Register a source request and validate it against ingestion policy.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "url": {"type": "string"},
                "rationale": {"type": "string"},
                "requested_by": {"type": "string", "default": "unknown"},
                "expected_pages": {"type": "integer", "minimum": 1, "default": 1},
                "human_approved": {"type": "boolean", "default": False},
            },
            "required": ["url", "rationale"],
        },
    },
    {
        "name": "orchestrate_ingestion",
        "description": "Map a source and produce a bounded ingestion plan.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "url": {"type": "string"},
                "include_paths": {"type": "array", "items": {"type": "string"}},
                "exclude_paths": {"type": "array", "items": {"type": "string"}},
                "expected_pages": {"type": "integer", "minimum": 1, "default": 25},
                "human_approved": {"type": "boolean", "default": False},
                "dry_run": {"type": "boolean", "default": True},
            },
            "required": ["url"],
        },
    },
    {
        "name": "execute_source_crawl",
        "description": "Perform a bounded crawl after policy and approval checks.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "url": {"type": "string"},
                "include_paths": {"type": "array", "items": {"type": "string"}},
                "exclude_paths": {"type": "array", "items": {"type": "string"}},
                "expected_pages": {"type": "integer", "minimum": 1, "default": 25},
                "human_approved": {"type": "boolean", "default": False},
                "dry_run": {"type": "boolean", "default": True},
                "poll_interval_seconds": {"type": "integer", "minimum": 1, "default": 5},
                "max_polls": {"type": "integer", "minimum": 1, "default": 60},
            },
            "required": ["url"],
        },
    },
    {
        "name": "index_crawled_source",
        "description": "Chunk, embed, and store crawled source content in Supabase.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "crawled_page": {"type": "object"},
                "url": {"type": "string"},
                "markdown": {"type": "string"},
                "title": {"type": "string"},
                "description": {"type": "string"},
                "language": {"type": "string"},
                "status_code": {"type": "integer"},
                "crawled_at": {"type": "string"},
                "etag": {"type": "string"},
                "last_modified": {"type": "string"},
                "embeddings": {"type": "array", "items": {"type": "array", "items": {"type": "number"}}},
            },
        },
    },
    {
        "name": "semantic_search_sources",
        "description": "Retrieve indexed source chunks by semantic query or provided embedding.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "query": {"type": "string"},
                "query_embedding": {"type": "array", "items": {"type": "number"}},
                "match_threshold": {"type": "number"},
                "match_count": {"type": "integer", "minimum": 1, "default": 10},
                "filter_domain": {"type": "string"},
            },
        },
    },
    {
        "name": "verify_source_index",
        "description": "Validate indexed source chunks and provenance metadata.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "page_id": {"type": "string"},
                "url": {"type": "string"},
            },
        },
    },
    {
        "name": "promote_synthesis_candidate",
        "description": "Promote a grounded synthesis draft into the wiki with provenance.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "draft_path": {"type": "string"},
                "note_path": {"type": "string"},
                "provenance": {"type": "object"},
                "chunk_ids": {"type": "array", "items": {"type": "string"}},
                "source_record_ids": {"type": "array", "items": {"type": "string"}},
                "retrieved_at": {"type": "string"},
                "acting_agent": {"type": "string", "default": "claude-chronicler"},
                "overwrite": {"type": "boolean", "default": False},
            },
            "required": ["draft_path"],
        },
    },
    {
        "name": "classify_synthesis_draft",
        "description": "Classify draft claims against the epistemic risk tiers.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "claims": {"type": "array", "items": {"type": "object"}},
                "existing_wiki_claims": {"type": "array", "items": {"type": "string"}},
                "min_similarity": {"type": "number"},
                "freshness_days": {"type": "integer", "minimum": 1},
            },
            "required": ["claims"],
        },
    },
    {
        "name": "get_conflict_resolution_template",
        "description": "Return an arbitration prompt template for a synthesis conflict.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "conflict_type": {
                    "type": "string",
                    "enum": ["direct_contradiction", "version_skew", "scope_overlap"],
                }
            },
            "required": ["conflict_type"],
            "additionalProperties": True,
        },
    },
    {
        "name": "run_synthesis_rubric",
        "description": "Check a synthesis draft for atomicity and scope statement coverage.",
        "inputSchema": {
            "type": "object",
            "properties": {"draft_text": {"type": "string"}},
            "required": ["draft_text"],
        },
    },
    {
        "name": "build_provenance_block",
        "description": "Generate a YANP provenance block for a Permanent Note.",
        "inputSchema": {
            "type": "object",
            "properties": {
                "chunk_ids": {"type": "array", "items": {"type": "string"}},
                "source_record_ids": {"type": "array", "items": {"type": "string"}},
                "retrieved_at": {"type": "string"},
                "acting_agent": {"type": "string", "default": "claude-chronicler"},
                "render_yaml": {"type": "boolean", "default": False},
            },
            "required": ["chunk_ids", "source_record_ids"],
        },
    },
]


def _json_request(method: str, path: str, payload: dict[str, Any]) -> dict[str, Any]:
    if not FIRECRAWL_API_KEY:
        raise RuntimeError("FIRECRAWL_API_KEY is not configured.")

    body = None if method.upper() == "GET" else json.dumps(payload).encode("utf-8")
    req = request.Request(
        f"{FIRECRAWL_API_BASE}{path}",
        data=body,
        method=method,
        headers={
            "Authorization": f"Bearer {FIRECRAWL_API_KEY}",
            "Content-Type": "application/json",
        },
    )
    try:
        with request.urlopen(req, timeout=30) as response:
            return json.loads(response.read().decode("utf-8"))
    except error.HTTPError as exc:  # pragma: no cover - depends on live API
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"Firecrawl request failed: {exc.code} {detail}") from exc
    except error.URLError as exc:  # pragma: no cover - depends on network
        raise RuntimeError(f"Firecrawl request failed: {exc.reason}") from exc


def _json_http_request(
    *,
    method: str,
    url: str,
    payload: dict[str, Any] | list[Any] | None = None,
    headers: dict[str, str] | None = None,
) -> Any:
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    request_headers = {"Content-Type": "application/json"}
    if headers:
        request_headers.update(headers)
    req = request.Request(url, data=body, method=method.upper(), headers=request_headers)
    try:
        with request.urlopen(req, timeout=30) as response:
            raw = response.read().decode("utf-8")
            if not raw:
                return {}
            return json.loads(raw)
    except error.HTTPError as exc:  # pragma: no cover - depends on live API
        detail = exc.read().decode("utf-8", errors="replace")
        raise RuntimeError(f"HTTP request failed: {exc.code} {detail}") from exc
    except error.URLError as exc:  # pragma: no cover - depends on network
        raise RuntimeError(f"HTTP request failed: {exc.reason}") from exc


def _supabase_headers(*, prefer: str | None = None) -> dict[str, str]:
    if not SUPABASE_URL or not SUPABASE_SERVICE_KEY:
        raise RuntimeError("SUPABASE_URL and SUPABASE_SERVICE_KEY must be configured.")
    headers = {
        "apikey": SUPABASE_SERVICE_KEY,
        "Authorization": f"Bearer {SUPABASE_SERVICE_KEY}",
    }
    if prefer:
        headers["Prefer"] = prefer
    return headers


def _supabase_request(
    method: str,
    path: str,
    *,
    payload: dict[str, Any] | list[dict[str, Any]] | None = None,
    params: dict[str, Any] | None = None,
    prefer: str | None = None,
) -> Any:
    url = f"{SUPABASE_URL}{path}"
    if params:
        query = parse.urlencode({key: value for key, value in params.items() if value is not None}, doseq=True)
        if query:
            url = f"{url}?{query}"
    return _json_http_request(
        method=method,
        url=url,
        payload=payload,
        headers=_supabase_headers(prefer=prefer),
    )


def _db_request(
    method: str,
    path: str,
    *,
    payload: dict[str, Any] | list[dict[str, Any]] | None = None,
    params: dict[str, Any] | None = None,
    prefer: str | None = None,
) -> Any:
    if USE_LOCAL_DB:
        from db_local import local_db_request

        return local_db_request(method, path, payload=payload, params=params, prefer=prefer)
    return _supabase_request(method, path, payload=payload, params=params, prefer=prefer)


def _embed_texts(texts: list[str]) -> list[list[float]]:
    if not texts:
        return []
    if not OPENAI_API_KEY:
        raise RuntimeError("OPENAI_API_KEY is not configured for embedding generation.")
    payload = {"model": OPENAI_EMBEDDING_MODEL, "input": texts}
    response = _json_http_request(
        method="POST",
        url=f"{OPENAI_API_BASE}/embeddings",
        payload=payload,
        headers={"Authorization": f"Bearer {OPENAI_API_KEY}"},
    )
    data = response.get("data")
    if not isinstance(data, list) or len(data) != len(texts):
        raise RuntimeError(f"Embedding API returned an unexpected payload: {response}")
    return [item["embedding"] for item in data]


def _estimate_credits(page_count: int) -> int:
    return max(1, page_count)


def _load_runtime_policy() -> PipelinePolicy:
    return load_policy(POLICY_PATH)


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _isoformat(dt: datetime) -> str:
    return dt.astimezone(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _parse_timestamp(value: str | None) -> datetime | None:
    if not value:
        return None
    normalized = value.replace("Z", "+00:00")
    return datetime.fromisoformat(normalized)


def _extract_page_payload(
    *,
    crawled_page: dict[str, Any] | None = None,
    url: str | None = None,
    markdown: str | None = None,
    title: str | None = None,
    description: str | None = None,
    language: str | None = None,
    status_code: int | None = None,
    crawled_at: str | None = None,
    etag: str | None = None,
    last_modified: str | None = None,
) -> dict[str, Any]:
    if crawled_page:
        data = crawled_page.get("data", crawled_page)
        metadata = data.get("metadata", {})
        markdown = markdown or data.get("markdown")
        url = url or metadata.get("sourceURL") or data.get("source_url") or data.get("url")
        title = title or metadata.get("title") or data.get("title")
        description = description or metadata.get("description") or data.get("description")
        language = language or metadata.get("language") or data.get("language")
        status_code = status_code if status_code is not None else metadata.get("statusCode") or data.get("status_code")
        crawled_at = crawled_at or data.get("crawled_at") or metadata.get("crawledAt")
        etag = etag or metadata.get("etag") or data.get("etag")
        last_modified = last_modified or metadata.get("lastModified") or data.get("last_modified")

    if not url:
        raise ValueError("A source URL is required.")
    if not markdown:
        raise ValueError("Markdown content is required for indexing.")

    return {
        "url": url,
        "markdown": markdown,
        "title": title,
        "description": description,
        "language": language or "en",
        "status_code": status_code,
        "crawled_at": crawled_at or _isoformat(_utcnow()),
        "etag": etag,
        "last_modified": last_modified,
    }


def _normalize_provenance_input(
    *,
    provenance: dict[str, Any] | None = None,
    chunk_ids: list[str] | None = None,
    source_record_ids: list[str] | None = None,
    retrieved_at: str | None = None,
    acting_agent: str = "claude-chronicler",
) -> dict[str, Any]:
    if provenance is None:
        provenance = generate_provenance_block(
            chunk_ids or [],
            source_record_ids or [],
            retrieved_at=retrieved_at,
            acting_agent=acting_agent,
        )
    block = provenance.get("provenance", provenance)
    return {
        "provenance": {
            "source_record_ids": list(block.get("source_record_ids", [])),
            "chunk_ids": list(block.get("chunk_ids", [])),
            "retrieved_at": block.get("retrieved_at") or retrieved_at or _isoformat(_utcnow()),
            "acting_agent": block.get("acting_agent") or acting_agent,
        }
    }


def _with_provenance_frontmatter(note_text: str, provenance_block: dict[str, Any]) -> str:
    provenance_yaml = render_provenance_yaml(provenance_block)
    if note_text.startswith("---\n"):
        end = note_text.find("\n---", 4)
        if end == -1:
            raise ValueError("Draft note frontmatter is not terminated.")
        frontmatter = note_text[4:end]
        body = note_text[end + 4 :]
        if "provenance:" in frontmatter:
            return note_text
        frontmatter = frontmatter.rstrip()
        stitched = f"---\n{frontmatter}\n{provenance_yaml}\n---{body}"
        return stitched
    return f"---\n{provenance_yaml}\n---\n\n{note_text.lstrip()}"


def _validate_provenance_records(provenance_block: dict[str, Any]) -> dict[str, Any]:
    block = provenance_block["provenance"]
    source_ids = block["source_record_ids"]
    chunk_ids = block["chunk_ids"]
    if not source_ids:
        raise ValueError("Provenance must include at least one source_record_id.")
    if not chunk_ids:
        raise ValueError("Provenance must include at least one chunk_id.")

    pages = _db_request(
        "GET",
        "/rest/v1/source_pages",
        params={"select": "id,url,status", "id": f"in.({','.join(source_ids)})"},
    )
    if len(pages) != len(set(source_ids)):
        found = {row["id"] for row in pages}
        missing = [source_id for source_id in source_ids if source_id not in found]
        raise RuntimeError(f"Provenance references unknown source_record_ids: {missing}")

    chunks = _db_request(
        "GET",
        "/rest/v1/source_chunks",
        params={"select": "id,page_id,source_url,chunk_index", "id": f"in.({','.join(chunk_ids)})"},
    )
    if len(chunks) != len(set(chunk_ids)):
        found = {row["id"] for row in chunks}
        missing = [chunk_id for chunk_id in chunk_ids if chunk_id not in found]
        raise RuntimeError(f"Provenance references unknown chunk_ids: {missing}")

    invalid = [chunk["id"] for chunk in chunks if chunk["page_id"] not in source_ids]
    if invalid:
        raise RuntimeError(f"Provenance chunk/page mismatch detected for chunk_ids: {invalid}")

    return {"pages": pages, "chunks": chunks}


def propose_source_intake(
    *,
    url: str,
    rationale: str,
    requested_by: str = "unknown",
    expected_pages: int = 1,
    human_approved: bool = False,
) -> dict[str, Any]:
    policy = _load_runtime_policy()
    gate = enforce_policy(
        policy,
        RUNTIME_LEDGER,
        url=url,
        estimated_credits=0,
        estimated_pages=expected_pages,
        human_approved=human_approved,
    )
    return {
        "status": "proposed",
        "url": url,
        "domain": gate["domain"],
        "requested_by": requested_by,
        "rationale": rationale,
        "expected_pages": expected_pages,
        "human_approved": human_approved,
        "policy_version": policy.version,
    }


def orchestrate_ingestion(
    *,
    url: str,
    include_paths: list[str] | None = None,
    exclude_paths: list[str] | None = None,
    expected_pages: int = 25,
    human_approved: bool = False,
    dry_run: bool = True,
) -> dict[str, Any]:
    policy = _load_runtime_policy()
    estimated_credits = _estimate_credits(expected_pages)
    gate = enforce_policy(
        policy,
        RUNTIME_LEDGER,
        url=url,
        estimated_credits=estimated_credits,
        estimated_pages=expected_pages,
        human_approved=human_approved,
    )

    include_paths = include_paths or []
    exclude_paths = exclude_paths or []
    if dry_run:
        return {
            "status": "mapped",
            "mode": "dry_run",
            "url": url,
            "domain": gate["domain"],
            "estimated_pages": expected_pages,
            "estimated_credits": estimated_credits,
            "include_paths": include_paths,
            "exclude_paths": exclude_paths,
            "next_state": "approved" if human_approved else "awaiting_approval",
        }

    payload = {
        "url": url,
        "limit": expected_pages,
        "includePaths": include_paths,
        "excludePaths": exclude_paths,
    }
    response = _json_request("POST", "/map", payload)
    urls = response.get("links") or response.get("urls") or []
    mapped_pages = len(urls) if isinstance(urls, list) else expected_pages
    return {
        "status": "mapped",
        "mode": "live",
        "url": url,
        "domain": gate["domain"],
        "estimated_pages": mapped_pages,
        "estimated_credits": _estimate_credits(mapped_pages),
        "mapped_urls": urls,
        "next_state": "approved" if human_approved else "awaiting_approval",
    }


def execute_source_crawl(
    *,
    url: str,
    include_paths: list[str] | None = None,
    exclude_paths: list[str] | None = None,
    expected_pages: int = 25,
    human_approved: bool = False,
    dry_run: bool = True,
    poll_interval_seconds: int = 5,
    max_polls: int = 60,
) -> dict[str, Any]:
    policy = _load_runtime_policy()
    estimated_credits = _estimate_credits(expected_pages)
    gate = enforce_policy(
        policy,
        RUNTIME_LEDGER,
        url=url,
        estimated_credits=estimated_credits,
        estimated_pages=expected_pages,
        human_approved=human_approved,
    )

    include_paths = include_paths or []
    exclude_paths = exclude_paths or []
    if dry_run:
        return {
            "status": "approved" if human_approved else "blocked",
            "mode": "dry_run",
            "url": url,
            "domain": gate["domain"],
            "estimated_pages": expected_pages,
            "estimated_credits": estimated_credits,
            "would_call": "POST /crawl",
            "next_state": "crawled" if human_approved else "awaiting_approval",
        }

    crawl_payload = {
        "url": url,
        "limit": expected_pages,
        "maxDiscoveryDepth": 3,
        "includePaths": include_paths,
        "excludePaths": exclude_paths,
        "scrapeOptions": {
            "formats": ["markdown"],
            "onlyMainContent": True,
        },
    }
    if USE_LOCAL_CRAWLER:
        result = crawl_local(
            url=url,
            expected_pages=expected_pages,
            include_paths=include_paths,
            exclude_paths=exclude_paths,
            max_discovery_depth=crawl_payload["maxDiscoveryDepth"],
        )
        record_usage(
            RUNTIME_LEDGER,
            domain=gate["domain"],
            credits_used=estimated_credits,
            pages_crawled=result["page_count"],
        )
        return result

    job = _json_request("POST", "/crawl", crawl_payload)
    job_id = job.get("id")
    if not job_id:
        raise RuntimeError(f"Firecrawl crawl did not return a job id: {job}")

    last_response: dict[str, Any] = {}
    for _ in range(max_polls):
        last_response = _json_request("GET", f"/crawl/{parse.quote(str(job_id))}", {})
        if last_response.get("status") == "completed":
            pages = last_response.get("data") or []
            record_usage(
                RUNTIME_LEDGER,
                domain=gate["domain"],
                credits_used=estimated_credits,
                pages_crawled=len(pages),
            )
            return {
                "status": "crawled",
                "mode": "live",
                "url": url,
                "domain": gate["domain"],
                "job_id": job_id,
                "page_count": len(pages),
                "pages": pages,
                "next_state": "indexed",
            }
        time.sleep(poll_interval_seconds)

    raise RuntimeError(f"Crawl job {job_id} did not complete in time. Last response: {last_response}")


def index_crawled_source(
    *,
    crawled_page: dict[str, Any] | None = None,
    url: str | None = None,
    markdown: str | None = None,
    title: str | None = None,
    description: str | None = None,
    language: str | None = None,
    status_code: int | None = None,
    crawled_at: str | None = None,
    etag: str | None = None,
    last_modified: str | None = None,
    embeddings: list[list[float]] | None = None,
) -> dict[str, Any]:
    from chunker import chunk_markdown, sha256

    page = _extract_page_payload(
        crawled_page=crawled_page,
        url=url,
        markdown=markdown,
        title=title,
        description=description,
        language=language,
        status_code=status_code,
        crawled_at=crawled_at,
        etag=etag,
        last_modified=last_modified,
    )

    prior_rows = _db_request(
        "GET",
        "/rest/v1/source_pages",
        params={"select": "id,content_hash,crawled_at,status", "url": f"eq.{page['url']}"},
    )
    prior_row = prior_rows[0] if prior_rows else None

    page_hash = sha256(page["markdown"])
    page_row = {
        "url": page["url"],
        "title": page["title"],
        "description": page["description"],
        "language": page["language"],
        "markdown": page["markdown"],
        "status_code": page["status_code"],
        "crawled_at": page["crawled_at"],
        "etag": page["etag"],
        "last_modified": page["last_modified"],
        "content_hash": page_hash,
        "status": "Indexed",
    }
    upserted_pages = _db_request(
        "POST",
        "/rest/v1/source_pages",
        payload=page_row,
        params={"on_conflict": "url", "select": "id,url,content_hash,crawled_at,status"},
        prefer="resolution=merge-duplicates,return=representation",
    )
    indexed_page = upserted_pages[0]

    if prior_row and prior_row["content_hash"] == page_hash:
        existing_chunks = _db_request(
            "GET",
            "/rest/v1/source_chunks",
            params={"select": "id,chunk_index", "page_id": f"eq.{indexed_page['id']}"},
        )
        return {
            "status": "indexed",
            "page_id": indexed_page["id"],
            "source_url": page["url"],
            "chunk_count": len(existing_chunks),
            "reindexed": False,
            "content_changed": False,
            "next_state": "verified",
        }

    _db_request("DELETE", "/rest/v1/source_chunks", params={"page_id": f"eq.{indexed_page['id']}"})

    chunks = chunk_markdown(
        page["markdown"],
        {"url": page["url"], "title": page["title"], "crawled_at": page["crawled_at"]},
    )
    if not chunks:
        raise RuntimeError("Chunking produced zero chunks; markdown is too thin to index.")

    vectors = embeddings or _embed_texts([chunk["content"] for chunk in chunks])
    if len(vectors) != len(chunks):
        raise RuntimeError("Embedding count does not match chunk count.")

    insert_rows: list[dict[str, Any]] = []
    for chunk, vector in zip(chunks, vectors):
        insert_rows.append(
            {
                "page_id": indexed_page["id"],
                "content": chunk["content"],
                "content_hash": chunk["content_hash"],
                "source_url": chunk["source_url"],
                "domain": chunk["domain"],
                "page_title": chunk["page_title"],
                "section_heading": chunk["section_heading"],
                "chunk_index": chunk["chunk_index"],
                "chunk_total": chunk["chunk_total"],
                "crawled_at": chunk["crawled_at"],
                "embedding": vector,
                "embedded_at": _isoformat(_utcnow()),
            }
        )

    inserted_chunks = _db_request(
        "POST",
        "/rest/v1/source_chunks",
        payload=insert_rows,
        params={"select": "id,chunk_index,section_heading"},
        prefer="return=representation",
    )
    return {
        "status": "indexed",
        "page_id": indexed_page["id"],
        "source_url": page["url"],
        "chunk_count": len(inserted_chunks),
        "chunk_ids": [row["id"] for row in inserted_chunks],
        "reindexed": prior_row is not None,
        "content_changed": True,
        "previous_crawled_at": prior_row["crawled_at"] if prior_row else None,
        "next_state": "verified",
    }


def semantic_search_sources(
    *,
    query: str | None = None,
    query_embedding: list[float] | None = None,
    match_threshold: float | None = None,
    match_count: int = 10,
    filter_domain: str | None = None,
) -> dict[str, Any]:
    policy = _load_runtime_policy()
    if query_embedding is None:
        if not query:
            raise ValueError("Either query or query_embedding is required.")
        query_embedding = _embed_texts([query])[0]

    results = _db_request(
        "POST",
        "/rest/v1/rpc/match_documents",
        payload={
            "query_embedding": query_embedding,
            "match_threshold": match_threshold if match_threshold is not None else policy.synthesis.min_similarity_threshold,
            "match_count": match_count,
            "filter_domain": filter_domain,
        },
    )

    return {
        "status": "retrieved",
        "query": query,
        "result_count": len(results),
        "results": [
            {
                "chunk_id": row["id"],
                "content": row["content"],
                "source_url": row["source_url"],
                "domain": row["domain"],
                "title": row.get("page_title"),
                "heading": row.get("section_heading"),
                "chunk_index": row["chunk_index"],
                "crawled_at": row["crawled_at"],
                "similarity": row["similarity"],
            }
            for row in results
        ],
    }


def verify_source_index(
    *,
    page_id: str | None = None,
    url: str | None = None,
) -> dict[str, Any]:
    policy = _load_runtime_policy()
    if not page_id and not url:
        raise ValueError("page_id or url is required for verification.")

    params = {"select": "id,url,title,crawled_at,status"}
    if page_id:
        params["id"] = f"eq.{page_id}"
    else:
        params["url"] = f"eq.{url}"
    pages = _db_request("GET", "/rest/v1/source_pages", params=params)
    if not pages:
        raise RuntimeError("Indexed source page not found.")
    page = pages[0]

    chunks = _db_request(
        "GET",
        "/rest/v1/source_chunks",
        params={
            "select": "id,page_id,content,source_url,page_title,section_heading,chunk_index,chunk_total,crawled_at",
            "page_id": f"eq.{page['id']}",
            "order": "chunk_index.asc",
        },
    )
    findings: list[dict[str, Any]] = []
    if not chunks:
        findings.append({"severity": "error", "code": "NO_CHUNKS", "message": "No chunks found for indexed page."})
    else:
        chunk_total = chunks[0]["chunk_total"]
        if chunk_total != len(chunks):
            findings.append(
                {
                    "severity": "error",
                    "code": "CHUNK_TOTAL_MISMATCH",
                    "message": f"chunk_total={chunk_total} but fetched {len(chunks)} chunks.",
                }
            )
        indexes = [chunk["chunk_index"] for chunk in chunks]
        if indexes != list(range(len(chunks))):
            findings.append(
                {
                    "severity": "error",
                    "code": "CHUNK_INDEX_GAP",
                    "message": f"Chunk indexes are not contiguous: {indexes}",
                }
            )
        for chunk in chunks:
            if chunk["source_url"] != page["url"]:
                findings.append(
                    {
                        "severity": "error",
                        "code": "PROVENANCE_URL_MISMATCH",
                        "message": f"Chunk {chunk['id']} points to {chunk['source_url']} instead of {page['url']}",
                    }
                )
            if chunk.get("page_title") != page.get("title"):
                findings.append(
                    {
                        "severity": "warning",
                        "code": "TITLE_MISMATCH",
                        "message": f"Chunk {chunk['id']} title does not match page title.",
                    }
                )
            if len(chunk["content"].split()) < 50:
                findings.append(
                    {
                        "severity": "warning",
                        "code": "THIN_CHUNK",
                        "message": f"Chunk {chunk['id']} is below the minimum coherence threshold.",
                    }
                )

    stale_cutoff = _utcnow() - timedelta(days=policy.synthesis.freshness_threshold_days)
    crawled_at = _parse_timestamp(page.get("crawled_at"))
    if crawled_at and crawled_at < stale_cutoff:
        findings.append(
            {
                "severity": "warning",
                "code": "T3_STALE_EVIDENCE",
                "message": f"Source was crawled at {page['crawled_at']}, older than {policy.synthesis.freshness_threshold_days} days.",
            }
        )

    verification_status = "passed" if not any(item["severity"] == "error" for item in findings) else "failed"
    if verification_status == "passed":
        _db_request(
            "PATCH",
            "/rest/v1/source_pages",
            payload={"status": "Verified", "verified_at": _isoformat(_utcnow())},
            params={"id": f"eq.{page['id']}"},
        )

    return {
        "status": verification_status,
        "page_id": page["id"],
        "source_url": page["url"],
        "chunk_count": len(chunks),
        "findings": findings,
        "next_state": "synthesized" if verification_status == "passed" else "indexed",
    }


def promote_synthesis_candidate(
    *,
    draft_path: str,
    note_path: str | None = None,
    provenance: dict[str, Any] | None = None,
    chunk_ids: list[str] | None = None,
    source_record_ids: list[str] | None = None,
    retrieved_at: str | None = None,
    acting_agent: str = "claude-chronicler",
    overwrite: bool = False,
) -> dict[str, Any]:
    provenance_block = _normalize_provenance_input(
        provenance=provenance,
        chunk_ids=chunk_ids,
        source_record_ids=source_record_ids,
        retrieved_at=retrieved_at,
        acting_agent=acting_agent,
    )
    validated = _validate_provenance_records(provenance_block)

    draft = Path(draft_path)
    if not draft.exists():
        raise RuntimeError(f"Draft note not found: {draft}")

    target = Path(note_path) if note_path else WIKI_ROOT / draft.name
    if target.exists() and not overwrite:
        raise RuntimeError(f"Target note already exists: {target}")
    target.parent.mkdir(parents=True, exist_ok=True)

    promoted_text = _with_provenance_frontmatter(draft.read_text(encoding="utf-8"), provenance_block)
    target.write_text(promoted_text, encoding="utf-8")

    promoted_at = _isoformat(_utcnow())
    for page in validated["pages"]:
        _db_request(
            "PATCH",
            "/rest/v1/source_pages",
            payload={
                "status": "Promoted",
                "promoted_at": promoted_at,
                "promoted_note_path": str(target),
            },
            params={"id": f"eq.{page['id']}"},
        )

    return {
        "status": "promoted",
        "note_path": str(target),
        "source_record_ids": provenance_block["provenance"]["source_record_ids"],
        "chunk_ids": provenance_block["provenance"]["chunk_ids"],
        "next_state": "promoted",
    }


def classify_synthesis_draft(
    *,
    claims: list[dict],
    existing_wiki_claims: list[str] | None = None,
    min_similarity: float | None = None,
    freshness_days: int | None = None,
) -> dict:
    """Classify synthesis draft claims against the T0–T5 epistemic risk tiers."""
    policy = _load_runtime_policy()
    kwargs: dict = {}
    if min_similarity is not None:
        kwargs["min_similarity"] = min_similarity
    else:
        kwargs["min_similarity"] = policy.synthesis.min_similarity_threshold
    if freshness_days is not None:
        kwargs["freshness_days"] = freshness_days
    else:
        kwargs["freshness_days"] = policy.synthesis.freshness_threshold_days
    if existing_wiki_claims is not None:
        kwargs["existing_wiki_claims"] = existing_wiki_claims
    return classify_draft(claims, **kwargs)


def get_conflict_resolution_template(
    *,
    conflict_type: str,
    **context,
) -> dict:
    """Return a filled arbitration prompt template for a given conflict type.

    conflict_type must be one of: direct_contradiction, version_skew, scope_overlap.
    Remaining keyword arguments are substituted into the template.
    """
    prompt = get_template(conflict_type, **context)
    return {"conflict_type": conflict_type, "prompt": prompt}


def run_synthesis_rubric(*, draft_text: str) -> dict:
    """Check a synthesis draft for atomicity and the presence of a scope statement."""
    result = check_synthesis_scope(draft_text)
    return result.to_dict()


def build_provenance_block(
    *,
    chunk_ids: list[str],
    source_record_ids: list[str],
    retrieved_at: str | None = None,
    acting_agent: str = "claude-chronicler",
    render_yaml: bool = False,
) -> dict:
    """Generate a YANP provenance block for a Permanent Note.

    If render_yaml is True, also includes the YAML text ready for frontmatter insertion.
    """
    block = generate_provenance_block(
        chunk_ids,
        source_record_ids,
        retrieved_at=retrieved_at,
        acting_agent=acting_agent,
    )
    result: dict = {**block}
    if render_yaml:
        result["yaml"] = render_provenance_yaml(block)
    return result


def build_server():
    if Server is None or TextContent is None or Tool is None:
        raise RuntimeError("The Python MCP SDK is not installed.")

    app = Server("vulture-ingest")

    @app.list_tools()
    async def list_tools() -> list[Tool]:
        return [Tool(**definition) for definition in TOOL_DEFINITIONS]

    @app.call_tool()
    async def call_tool(name: str, arguments: dict) -> list[TextContent]:
        try:
            if name == "propose_source_intake":
                payload = propose_source_intake(**arguments)
            elif name == "orchestrate_ingestion":
                payload = orchestrate_ingestion(**arguments)
            elif name == "execute_source_crawl":
                payload = execute_source_crawl(**arguments)
            elif name == "index_crawled_source":
                payload = index_crawled_source(**arguments)
            elif name == "semantic_search_sources":
                payload = semantic_search_sources(**arguments)
            elif name == "verify_source_index":
                payload = verify_source_index(**arguments)
            elif name == "promote_synthesis_candidate":
                payload = promote_synthesis_candidate(**arguments)
            elif name == "classify_synthesis_draft":
                payload = classify_synthesis_draft(**arguments)
            elif name == "get_conflict_resolution_template":
                payload = get_conflict_resolution_template(**arguments)
            elif name == "run_synthesis_rubric":
                payload = run_synthesis_rubric(**arguments)
            elif name == "build_provenance_block":
                payload = build_provenance_block(**arguments)
            else:
                raise ValueError(f"Unknown tool: {name}")
        except (PolicyError, PolicyDeniedError, RuntimeError, ValueError) as exc:
            payload = {"error": str(exc), "tool": name}
        return [TextContent(type="text", text=json.dumps(payload))]

    return app


async def main() -> None:
    if stdio_server is None:
        raise RuntimeError("The Python MCP SDK is not installed.")

    app = build_server()

    def _shutdown(*_args):
        return None

    for sig in (signal.SIGTERM, signal.SIGINT):
        signal.signal(sig, _shutdown)

    async with stdio_server() as (read, write):
        await app.run(read, write, app.create_initialization_options())


if __name__ == "__main__":
    asyncio.run(main())
