import importlib.util
import hashlib
from pathlib import Path
import sys

import pytest


MODULE_DIR = Path(__file__).parent / "vulture-ingest"
if str(MODULE_DIR) not in sys.path:
    sys.path.insert(0, str(MODULE_DIR))


def _load_module(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    assert spec.loader is not None
    sys.modules[name] = module
    spec.loader.exec_module(module)
    return module


policy = _load_module("policy", MODULE_DIR / "policy.py")
server = _load_module("vulture_ingest_server", MODULE_DIR / "server.py")
TEST_TMP_DIR = Path(__file__).parent / ".tmp" / "vulture-ingest-tests"
TEST_TMP_DIR.mkdir(parents=True, exist_ok=True)


def test_policy_loader_is_fail_closed_for_missing_file():
    missing = TEST_TMP_DIR / "missing.yaml"
    if missing.exists():
        missing.unlink()
    with pytest.raises(policy.PolicyError, match="fail-closed"):
        policy.load_policy(missing)


def test_policy_loader_rejects_invalid_shape():
    bad_policy = TEST_TMP_DIR / "pipeline-policy.yaml"
    bad_policy.write_text("version: nope\n", encoding="utf-8")
    try:
        with pytest.raises(policy.PolicyError, match="Invalid pipeline policy"):
            policy.load_policy(bad_policy)
    finally:
        if bad_policy.exists():
            bad_policy.unlink()


def test_denied_domain_is_blocked():
    loaded = policy.load_policy()
    ledger = policy.RuntimeLedger()

    with pytest.raises(policy.PolicyDeniedError, match="denied"):
        policy.enforce_policy(loaded, ledger, url="https://reddit.com/r/test", human_approved=True)


def test_new_domain_requires_human_approval():
    loaded = policy.load_policy()
    ledger = policy.RuntimeLedger()

    with pytest.raises(policy.PolicyDeniedError, match="AUTH_REQUIRED"):
        policy.enforce_policy(loaded, ledger, url="https://docs.example.com", estimated_pages=5)


def test_propose_source_intake_passes_with_approval():
    payload = server.propose_source_intake(
        url="https://docs.example.com",
        rationale="ingest API reference",
        requested_by="pytest",
        expected_pages=5,
        human_approved=True,
    )

    assert payload["status"] == "proposed"
    assert payload["domain"] == "docs.example.com"
    assert payload["policy_version"] == 1.0


def test_execute_source_crawl_enforces_cost_threshold():
    with pytest.raises(policy.PolicyDeniedError, match="AUTH_REQUIRED"):
        server.execute_source_crawl(
            url="https://docs.example.com",
            expected_pages=25,
            human_approved=False,
            dry_run=True,
        )


def test_index_crawled_source_upserts_page_and_chunks(monkeypatch):
    calls: list[tuple[str, str, object, object, object]] = []

    def fake_supabase_request(method, path, *, payload=None, params=None, prefer=None):
        calls.append((method, path, payload, params, prefer))
        if method == "GET" and path == "/rest/v1/source_pages":
            return []
        if method == "POST" and path == "/rest/v1/source_pages":
            return [{"id": "page-1", "url": "https://docs.example.com/ref", "content_hash": "page-hash", "crawled_at": "2026-04-30T00:00:00Z", "status": "Indexed"}]
        if method == "DELETE" and path == "/rest/v1/source_chunks":
            return {}
        if method == "POST" and path == "/rest/v1/source_chunks":
            return [{"id": "chk-1", "chunk_index": 0, "section_heading": "Intro"}]
        raise AssertionError((method, path, payload, params, prefer))

    monkeypatch.setattr(server, "_supabase_request", fake_supabase_request)
    monkeypatch.setattr(server, "_embed_texts", lambda texts: [[0.1] * 3 for _ in texts])

    payload = server.index_crawled_source(
        url="https://docs.example.com/ref",
        title="Reference",
        markdown="# Intro\n\n" + " ".join(["signal"] * 80),
        crawled_at="2026-04-30T00:00:00Z",
    )

    assert payload["status"] == "indexed"
    assert payload["chunk_count"] == 1
    assert payload["page_id"] == "page-1"
    page_upsert = next(call for call in calls if call[0] == "POST" and call[1] == "/rest/v1/source_pages")
    assert page_upsert[2]["status"] == "Indexed"
    chunk_insert = next(call for call in calls if call[0] == "POST" and call[1] == "/rest/v1/source_chunks")
    assert chunk_insert[2][0]["page_id"] == "page-1"
    assert chunk_insert[2][0]["source_url"] == "https://docs.example.com/ref"


def test_index_crawled_source_skips_reembedding_when_hash_unchanged(monkeypatch):
    content_hash = hashlib.sha256("same markdown body".encode("utf-8")).hexdigest()

    def fake_supabase_request(method, path, *, payload=None, params=None, prefer=None):
        if method == "GET" and path == "/rest/v1/source_pages":
            return [{"id": "page-1", "content_hash": content_hash, "crawled_at": "2026-04-29T00:00:00Z", "status": "Indexed"}]
        if method == "POST" and path == "/rest/v1/source_pages":
            return [{"id": "page-1", "url": "https://docs.example.com/ref", "content_hash": content_hash, "crawled_at": "2026-04-30T00:00:00Z", "status": "Indexed"}]
        if method == "GET" and path == "/rest/v1/source_chunks":
            return [{"id": "chk-1", "chunk_index": 0}]
        raise AssertionError((method, path, payload, params, prefer))

    monkeypatch.setattr(server, "_supabase_request", fake_supabase_request)
    monkeypatch.setattr(server, "_embed_texts", lambda texts: pytest.fail(f"unexpected embedding call for {texts}"))

    payload = server.index_crawled_source(
        url="https://docs.example.com/ref",
        title="Reference",
        markdown="same markdown body",
        crawled_at="2026-04-30T00:00:00Z",
    )

    assert payload["content_changed"] is False
    assert payload["reindexed"] is False
    assert payload["chunk_count"] == 1


def test_semantic_search_sources_calls_match_documents(monkeypatch):
    recorded = {}

    def fake_supabase_request(method, path, *, payload=None, params=None, prefer=None):
        recorded["call"] = (method, path, payload, params, prefer)
        return [
            {
                "id": "chk-1",
                "content": "retrieved content",
                "source_url": "https://docs.example.com/ref",
                "domain": "docs.example.com",
                "page_title": "Reference",
                "section_heading": "Install",
                "chunk_index": 2,
                "crawled_at": "2026-04-30T00:00:00Z",
                "similarity": 0.92,
            }
        ]

    monkeypatch.setattr(server, "_supabase_request", fake_supabase_request)

    payload = server.semantic_search_sources(query_embedding=[0.1, 0.2, 0.3], match_count=4, filter_domain="docs.example.com")

    assert payload["status"] == "retrieved"
    assert payload["result_count"] == 1
    assert payload["results"][0]["heading"] == "Install"
    method, path, rpc_payload, _, _ = recorded["call"]
    assert method == "POST"
    assert path == "/rest/v1/rpc/match_documents"
    assert rpc_payload["filter_domain"] == "docs.example.com"
    assert rpc_payload["match_count"] == 4


def test_verify_source_index_flags_stale_evidence_and_mismatched_provenance(monkeypatch):
    updates: list[dict] = []

    def fake_supabase_request(method, path, *, payload=None, params=None, prefer=None):
        if method == "GET" and path == "/rest/v1/source_pages":
            return [{"id": "page-1", "url": "https://docs.example.com/ref", "title": "Reference", "crawled_at": "2025-01-01T00:00:00Z", "status": "Indexed"}]
        if method == "GET" and path == "/rest/v1/source_chunks":
            return [
                {
                    "id": "chk-1",
                    "page_id": "page-1",
                    "content": " ".join(["signal"] * 80),
                    "source_url": "https://wrong.example.com/ref",
                    "page_title": "Reference",
                    "section_heading": "Intro",
                    "chunk_index": 0,
                    "chunk_total": 1,
                    "crawled_at": "2025-01-01T00:00:00Z",
                }
            ]
        if method == "PATCH" and path == "/rest/v1/source_pages":
            updates.append(payload)
            return {}
        raise AssertionError((method, path, payload, params, prefer))

    monkeypatch.setattr(server, "_supabase_request", fake_supabase_request)

    payload = server.verify_source_index(page_id="page-1")

    assert payload["status"] == "failed"
    codes = {finding["code"] for finding in payload["findings"]}
    assert "PROVENANCE_URL_MISMATCH" in codes
    assert "T3_STALE_EVIDENCE" in codes
    assert updates == []


def test_promote_synthesis_candidate_validates_provenance_and_writes_note(monkeypatch):
    workdir = TEST_TMP_DIR / "promotion"
    workdir.mkdir(parents=True, exist_ok=True)
    draft = workdir / "draft.md"
    draft.write_text("---\ntitle: Test Draft\n---\n\nBody text.\n", encoding="utf-8")
    target = workdir / "promoted.md"
    patch_calls: list[dict] = []

    def fake_supabase_request(method, path, *, payload=None, params=None, prefer=None):
        if method == "GET" and path == "/rest/v1/source_pages":
            return [{"id": "page-1", "url": "https://docs.example.com/ref", "status": "Synthesized"}]
        if method == "GET" and path == "/rest/v1/source_chunks":
            return [{"id": "chk-1", "page_id": "page-1", "source_url": "https://docs.example.com/ref", "chunk_index": 0}]
        if method == "PATCH" and path == "/rest/v1/source_pages":
            patch_calls.append(payload)
            return {}
        raise AssertionError((method, path, payload, params, prefer))

    monkeypatch.setattr(server, "_supabase_request", fake_supabase_request)

    payload = server.promote_synthesis_candidate(
        draft_path=str(draft),
        note_path=str(target),
        chunk_ids=["chk-1"],
        source_record_ids=["page-1"],
        retrieved_at="2026-04-30T12:00:00Z",
    )

    assert payload["status"] == "promoted"
    promoted_text = target.read_text(encoding="utf-8")
    assert 'provenance:' in promoted_text
    assert '"page-1"' in promoted_text
    assert patch_calls[0]["status"] == "Promoted"
