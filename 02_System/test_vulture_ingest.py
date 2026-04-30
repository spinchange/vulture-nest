import importlib.util
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
