from __future__ import annotations

import asyncio
import json
import os
import signal
import sys
import time
from pathlib import Path
from typing import Any
from urllib import error, parse, request

try:
    from mcp.server import Server
    from mcp.server.stdio import stdio_server
    from mcp.types import TextContent
except ImportError:  # pragma: no cover - keeps module importable without SDK
    Server = None
    stdio_server = None
    TextContent = None


MODULE_DIR = Path(__file__).resolve().parent
if str(MODULE_DIR) not in sys.path:
    sys.path.insert(0, str(MODULE_DIR))

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
from provenance import generate_provenance_block, render_provenance_yaml  # noqa: E402


FIRECRAWL_API_BASE = os.environ.get("FIRECRAWL_API_BASE", "https://api.firecrawl.dev/v2")
FIRECRAWL_API_KEY = os.environ.get("FIRECRAWL_API_KEY", "")
POLICY_PATH = Path(os.environ.get("VULTURE_PIPELINE_POLICY_PATH", DEFAULT_POLICY_PATH))
RUNTIME_LEDGER = RuntimeLedger()


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


def _estimate_credits(page_count: int) -> int:
    return max(1, page_count)


def _load_runtime_policy() -> PipelinePolicy:
    return load_policy(POLICY_PATH)


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
    if Server is None or TextContent is None:
        raise RuntimeError("The Python MCP SDK is not installed.")

    app = Server("vulture-ingest")

    @app.call_tool()
    async def call_tool(name: str, arguments: dict) -> list[TextContent]:
        try:
            if name == "propose_source_intake":
                payload = propose_source_intake(**arguments)
            elif name == "orchestrate_ingestion":
                payload = orchestrate_ingestion(**arguments)
            elif name == "execute_source_crawl":
                payload = execute_source_crawl(**arguments)
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
