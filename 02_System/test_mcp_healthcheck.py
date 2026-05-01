import asyncio

from mcp_healthcheck import DEFAULT_CONFIG, check_config, check_live_services, load_config


def test_gemini_mcp_config_exists_and_declares_servers():
    config = load_config(DEFAULT_CONFIG)

    assert "mcpServers" in config
    assert {"memory-mcp", "vulture-ingest"}.issubset(config["mcpServers"])


def test_configured_mcp_servers_support_discovery():
    results = asyncio.run(check_config(DEFAULT_CONFIG, timeout_seconds=10))
    by_name = {result.name: result for result in results}

    assert by_name["memory-mcp"].ok, by_name["memory-mcp"].error
    assert by_name["vulture-ingest"].ok, by_name["vulture-ingest"].error
    assert {"commit_memory", "search_memories", "prune_memory"}.issubset(by_name["memory-mcp"].tools)
    assert "propose_source_intake" in by_name["vulture-ingest"].tools


def test_live_service_checks_use_effective_dotenv_env(monkeypatch):
    calls = []

    def fake_json_http_request(*, method, url, payload=None, headers=None, timeout=20.0):
        calls.append({"method": method, "url": url, "payload": payload, "headers": headers, "timeout": timeout})
        if url.endswith("/embeddings"):
            return {"data": [{"embedding": [0.1, 0.2, 0.3]}]}
        if "/rest/v1/source_pages?" in url:
            return []
        if url.endswith("/team/credit-usage"):
            return {"creditsUsed": 0}
        raise AssertionError(url)

    monkeypatch.setattr("mcp_healthcheck._json_http_request", fake_json_http_request)

    results = check_live_services(load_config(DEFAULT_CONFIG), timeout_seconds=7, include_firecrawl=True)
    by_name = {result.name: result for result in results}

    assert by_name["openai"].ok
    assert by_name["supabase"].ok
    assert by_name["firecrawl"].ok
    assert len(calls) == 3
    assert calls[0]["payload"]["input"] == "vulture-nest health check"
    assert calls[0]["headers"]["Authorization"].startswith("Bearer ")
    assert calls[1]["headers"]["apikey"]


def test_live_firecrawl_is_skipped_by_default(monkeypatch):
    def fake_json_http_request(*, method, url, payload=None, headers=None, timeout=20.0):
        if url.endswith("/team/credit-usage"):
            raise AssertionError("Firecrawl should not be called without include_firecrawl.")
        if url.endswith("/embeddings"):
            return {"data": [{"embedding": [0.1]}]}
        if "/rest/v1/source_pages?" in url:
            return []
        raise AssertionError(url)

    monkeypatch.setattr("mcp_healthcheck._json_http_request", fake_json_http_request)

    results = check_live_services(load_config(DEFAULT_CONFIG), timeout_seconds=7)
    by_name = {result.name: result for result in results}

    assert by_name["firecrawl"].ok
    assert "skipped" in by_name["firecrawl"].detail
