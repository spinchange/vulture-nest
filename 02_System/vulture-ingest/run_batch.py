from __future__ import annotations

import argparse
import json
import re
import time
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

import server


REPO_ROOT = Path(__file__).resolve().parents[2]
DEFAULT_MANIFEST = Path(__file__).resolve().parent / "manifests" / "anthropic-batch-2-2026-05-02.json"


def load_manifest(path: Path) -> dict[str, Any]:
    data = json.loads(path.read_text(encoding="utf-8"))
    if not isinstance(data, dict):
        raise ValueError(f"Manifest root must be an object: {path}")
    return data


def iter_entries(manifest: dict[str, Any], sub_batch: str | None = None):
    target = sub_batch.upper() if sub_batch else None
    batches = manifest.get("sub_batches") or []
    for batch in sorted(batches, key=lambda item: item.get("order", 0)):
        batch_id = str(batch.get("id", "")).upper()
        if target and batch_id != target:
            continue
        for entry in batch.get("entries") or []:
            yield batch, entry


def validate_manifest(manifest: dict[str, Any]) -> list[str]:
    errors: list[str] = []
    base = manifest.get("canonical_base_url")
    if not isinstance(base, str) or not base:
        errors.append("canonical_base_url must be a non-empty string")
        return errors

    seen_files: set[str] = set()
    seen_urls: set[str] = set()
    base_host = urlparse(base).netloc
    for batch, entry in iter_entries(manifest):
        corpus_file = entry.get("corpus_file")
        source_url = entry.get("source_url")
        if not isinstance(corpus_file, str) or not corpus_file:
            errors.append(f"sub-batch {batch.get('id')} has an entry with missing corpus_file")
            continue
        if corpus_file in seen_files:
            errors.append(f"duplicate corpus_file detected: {corpus_file}")
        seen_files.add(corpus_file)

        if not isinstance(source_url, str) or not source_url:
            errors.append(f"{corpus_file} is missing source_url")
            continue
        parsed = urlparse(source_url)
        if parsed.scheme != "https" or parsed.netloc != base_host:
            errors.append(f"{corpus_file} does not use canonical host {base_host}: {source_url}")
        if source_url in seen_urls:
            errors.append(f"duplicate source_url detected: {source_url}")
        seen_urls.add(source_url)
    return errors


def run_preflight(manifest: dict[str, Any], sub_batch: str | None) -> dict[str, Any]:
    errors = validate_manifest(manifest)
    entries = list(iter_entries(manifest, sub_batch))
    raw_dir = REPO_ROOT / manifest["raw_output_dir"]
    return {
        "status": "ready" if not errors else "invalid",
        "batch_id": manifest.get("batch_id"),
        "sub_batch": sub_batch.upper() if sub_batch else None,
        "raw_output_dir": str(raw_dir),
        "raw_output_dir_exists": raw_dir.exists(),
        "entry_count": len(entries),
        "errors": errors,
        "entries": [
            {
                "sub_batch": batch["id"],
                "corpus_file": entry["corpus_file"],
                "source_url": entry["source_url"],
                "note_target": batch.get("note_target"),
            }
            for batch, entry in entries
        ],
    }


def run_dry_run(
    manifest: dict[str, Any],
    *,
    sub_batch: str | None,
    requested_by: str | None,
    human_approved: bool,
) -> dict[str, Any]:
    report = run_preflight(manifest, sub_batch)
    if report["errors"]:
        return report

    results: list[dict[str, Any]] = []
    effective_requested_by = requested_by or manifest.get("requested_by", "unknown")
    default_expected_pages = int(manifest.get("default_expected_pages", 1))

    for batch, entry in iter_entries(manifest, sub_batch):
        url = entry["source_url"]
        corpus_file = entry["corpus_file"]
        rationale = f"{manifest['batch_id']} sub-batch {batch['id']} -> {corpus_file}"
        item: dict[str, Any] = {
            "sub_batch": batch["id"],
            "corpus_file": corpus_file,
            "source_url": url,
            "note_target": batch.get("note_target"),
            "human_approved": human_approved,
        }
        try:
            item["intake"] = server.propose_source_intake(
                url=url,
                rationale=rationale,
                requested_by=effective_requested_by,
                expected_pages=default_expected_pages,
                human_approved=human_approved,
            )
            item["orchestration"] = server.orchestrate_ingestion(
                url=url,
                expected_pages=default_expected_pages,
                human_approved=human_approved,
                dry_run=True,
            )
            item["crawl"] = server.execute_source_crawl(
                url=url,
                expected_pages=default_expected_pages,
                human_approved=human_approved,
                dry_run=True,
            )
            item["status"] = "ok"
        except Exception as exc:
            item["status"] = "blocked"
            item["error"] = str(exc)
        results.append(item)

    blocked = [item for item in results if item["status"] != "ok"]
    report["status"] = "ready" if not blocked else "approval_required"
    report["dry_run"] = {
        "requested_by": effective_requested_by,
        "human_approved": human_approved,
        "blocked_count": len(blocked),
        "results": results,
    }
    return report


def _extract_page_for_save(crawled_page: dict[str, Any]) -> dict[str, Any]:
    data = crawled_page.get("data", crawled_page)
    metadata = data.get("metadata", {})
    return {
        "requested_url": data.get("requested_url"),
        "resolved_url": metadata.get("sourceURL") or data.get("source_url") or data.get("url"),
        "title": metadata.get("title") or data.get("title"),
        "markdown": data.get("markdown") or "",
        "crawled_at": data.get("crawled_at") or metadata.get("crawledAt") or metadata.get("cachedAt"),
    }


def _pick_crawled_page(requested_url: str, pages: list[dict[str, Any]]) -> dict[str, Any]:
    if not pages:
        raise RuntimeError(f"Crawl returned zero pages for {requested_url}")

    exact_matches = []
    path_matches = []
    requested_path = urlparse(requested_url).path.rstrip("/")
    for page in pages:
        extracted = _extract_page_for_save(page)
        resolved_url = extracted["resolved_url"]
        if not isinstance(resolved_url, str) or not resolved_url:
            continue
        if resolved_url == requested_url:
            exact_matches.append(page)
            continue
        if urlparse(resolved_url).path.rstrip("/") == requested_path:
            path_matches.append(page)

    if exact_matches:
        return exact_matches[0]
    if path_matches:
        return path_matches[0]
    return pages[0]


def _render_raw_capture(
    *,
    requested_url: str,
    resolved_url: str,
    fetched_at: str,
    title: str | None,
    crawl_job_id: str,
    page_id: str,
    chunk_ids: list[str],
    markdown: str,
) -> str:
    header = [
        "<!--",
        f"source_url: {resolved_url}",
        f"requested_url: {requested_url}",
        f"fetch_date: {fetched_at}",
        f"crawl_job_id: {crawl_job_id}",
        f"source_page_id: {page_id}",
        f"chunk_ids: {', '.join(chunk_ids)}",
        "-->",
        "",
    ]
    if title:
        header.append(f"# {title}")
        header.append("")
    body = markdown.lstrip()
    return "\n".join(header) + body + ("\n" if not body.endswith("\n") else "")


def _resolve_chunk_ids(index_result: dict[str, Any]) -> list[str]:
    chunk_ids = list(index_result.get("chunk_ids") or [])
    if chunk_ids:
        return chunk_ids
    page_id = index_result["page_id"]
    rows = server._supabase_request(  # type: ignore[attr-defined]
        "GET",
        "/rest/v1/source_chunks",
        params={"select": "id", "page_id": f"eq.{page_id}", "order": "chunk_index.asc"},
    )
    return [row["id"] for row in rows]


def run_live(
    manifest: dict[str, Any],
    *,
    sub_batch: str | None,
    requested_by: str | None,
    human_approved: bool,
) -> dict[str, Any]:
    if not human_approved:
        raise ValueError("Live execution requires explicit human approval.")

    report = run_preflight(manifest, sub_batch)
    if report["errors"]:
        return report

    results: list[dict[str, Any]] = []
    effective_requested_by = requested_by or manifest.get("requested_by", "unknown")
    default_expected_pages = int(manifest.get("default_expected_pages", 1))
    raw_dir = REPO_ROOT / manifest["raw_output_dir"]
    raw_dir.mkdir(parents=True, exist_ok=True)

    for batch, entry in iter_entries(manifest, sub_batch):
        url = entry["source_url"]
        corpus_file = entry["corpus_file"]
        rationale = f"{manifest['batch_id']} sub-batch {batch['id']} -> {corpus_file}"
        item: dict[str, Any] = {
            "sub_batch": batch["id"],
            "corpus_file": corpus_file,
            "source_url": url,
            "note_target": batch.get("note_target"),
            "human_approved": human_approved,
        }
        try:
            for attempt in range(1, 4):
                try:
                    item["intake"] = server.propose_source_intake(
                        url=url,
                        rationale=rationale,
                        requested_by=effective_requested_by,
                        expected_pages=default_expected_pages,
                        human_approved=True,
                    )
                    item["orchestration"] = server.orchestrate_ingestion(
                        url=url,
                        expected_pages=default_expected_pages,
                        human_approved=True,
                        dry_run=False,
                    )
                    item["crawl"] = server.execute_source_crawl(
                        url=url,
                        expected_pages=default_expected_pages,
                        human_approved=True,
                        dry_run=False,
                    )

                    selected_page = _pick_crawled_page(url, item["crawl"].get("pages") or [])
                    extracted = _extract_page_for_save(selected_page)
                    index_result = server.index_crawled_source(crawled_page=selected_page)
                    verify_result = server.verify_source_index(page_id=index_result["page_id"])

                    raw_path = raw_dir / corpus_file
                    raw_text = _render_raw_capture(
                        requested_url=url,
                        resolved_url=extracted["resolved_url"] or url,
                        fetched_at=extracted["crawled_at"] or selected_page.get("crawled_at") or "unknown",
                        title=extracted["title"],
                        crawl_job_id=item["crawl"]["job_id"],
                        page_id=index_result["page_id"],
                        chunk_ids=_resolve_chunk_ids(index_result),
                        markdown=extracted["markdown"],
                    )
                    raw_path.write_text(raw_text, encoding="utf-8")

                    item["indexed"] = index_result
                    item["verified"] = verify_result
                    item["raw_path"] = str(raw_path)
                    item["resolved_url"] = extracted["resolved_url"] or url
                    item["attempts"] = attempt
                    item["status"] = "ok" if verify_result["status"] == "passed" else "failed"
                    break
                except Exception as exc:
                    message = str(exc)
                    rate_limit_match = re.search(r"retry after\s+(\d+)s", message, re.IGNORECASE)
                    if attempt < 3 and "Rate limit exceeded" in message and rate_limit_match:
                        wait_seconds = int(rate_limit_match.group(1)) + 2
                        item["retry_after_seconds"] = wait_seconds
                        item["attempts"] = attempt
                        time.sleep(wait_seconds)
                        continue
                    if attempt < 3 and (" 502 " in f" {message} " or "502 Bad Gateway" in message):
                        wait_seconds = 5 * attempt
                        item["retry_after_seconds"] = wait_seconds
                        item["attempts"] = attempt
                        time.sleep(wait_seconds)
                        continue
                    raise
        except Exception as exc:
            item["status"] = "failed"
            item["error"] = str(exc)
        results.append(item)
        if item["status"] != "ok":
            break

    failures = [item for item in results if item["status"] != "ok"]
    report["status"] = "ready" if not failures else "failed"
    report["live_run"] = {
        "requested_by": effective_requested_by,
        "human_approved": human_approved,
        "failure_count": len(failures),
        "results": results,
    }
    return report


def main() -> int:
    parser = argparse.ArgumentParser(description="Preflight or dry-run an external ingestion batch manifest.")
    parser.add_argument("--manifest", type=Path, default=DEFAULT_MANIFEST)
    parser.add_argument("--mode", choices=("preflight", "dry-run", "live-run"), default="preflight")
    parser.add_argument("--sub-batch", help="Optional sub-batch id such as E, A, B, C, or D.")
    parser.add_argument("--requested-by", help="Override the requested_by actor recorded in dry-run intake payloads.")
    parser.add_argument("--human-approved", action="store_true", help="Set when HITL approval has already been granted.")
    args = parser.parse_args()

    manifest = load_manifest(args.manifest)
    if args.mode == "preflight":
        report = run_preflight(manifest, args.sub_batch)
    elif args.mode == "dry-run":
        report = run_dry_run(
            manifest,
            sub_batch=args.sub_batch,
            requested_by=args.requested_by,
            human_approved=args.human_approved,
        )
    else:
        report = run_live(
            manifest,
            sub_batch=args.sub_batch,
            requested_by=args.requested_by,
            human_approved=args.human_approved,
        )
    print(json.dumps(report, indent=2))
    return 0 if report["status"] in {"ready", "approval_required"} else 1


if __name__ == "__main__":
    raise SystemExit(main())
