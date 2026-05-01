from __future__ import annotations

import argparse
import asyncio
import json
import os
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Any
from urllib import error, parse, request

from mcp import ClientSession
from mcp.client.stdio import StdioServerParameters, stdio_client

try:
    from dotenv import dotenv_values
except ImportError:  # pragma: no cover - checked by runtime health if missing
    dotenv_values = None


REPO_ROOT = Path(__file__).resolve().parents[1]
DEFAULT_CONFIG = REPO_ROOT / ".gemini" / "settings.json"
SENSITIVE_ENV_NAMES = ("API_KEY", "SERVICE_KEY", "TOKEN", "SECRET")


@dataclass
class ServerHealth:
    name: str
    ok: bool
    command: str
    args: list[str]
    tools: list[str]
    warnings: list[str]
    error: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "ok": self.ok,
            "command": self.command,
            "args": self.args,
            "tools": self.tools,
            "tool_count": len(self.tools),
            "warnings": self.warnings,
            "error": self.error,
        }


@dataclass
class ServiceHealth:
    name: str
    ok: bool
    detail: str
    error: str | None = None

    def to_dict(self) -> dict[str, Any]:
        return {
            "name": self.name,
            "ok": self.ok,
            "detail": self.detail,
            "error": self.error,
        }


def load_config(path: Path) -> dict[str, Any]:
    if not path.exists():
        raise FileNotFoundError(f"MCP config not found: {path}")
    return json.loads(path.read_text(encoding="utf-8"))


def _server_script_exists(args: list[str]) -> bool:
    if not args:
        return True
    first_arg = Path(args[0])
    candidate = first_arg if first_arg.is_absolute() else REPO_ROOT / first_arg
    return candidate.exists()


def _server_dir(args: list[str]) -> Path | None:
    if not args:
        return None
    first_arg = Path(args[0])
    candidate = first_arg if first_arg.is_absolute() else REPO_ROOT / first_arg
    if not candidate.exists():
        return None
    return candidate.parent


def _dotenv_keys(server_dir: Path | None) -> set[str]:
    if dotenv_values is None or server_dir is None:
        return set()
    env_path = server_dir / ".env"
    if not env_path.exists():
        return set()
    return {key for key, value in dotenv_values(env_path).items() if value}


def _dotenv_values(server_dir: Path | None) -> dict[str, str]:
    if dotenv_values is None or server_dir is None:
        return {}
    env_path = server_dir / ".env"
    if not env_path.exists():
        return {}
    return {key: value for key, value in dotenv_values(env_path).items() if value is not None}


def _env_warnings(env: dict[str, str], dotenv_keys: set[str]) -> list[str]:
    warnings = []
    for name, value in sorted(env.items()):
        if any(marker in name.upper() for marker in SENSITIVE_ENV_NAMES) and not value:
            if name in dotenv_keys:
                warnings.append(f"{name} is empty in config; local .env fallback is present")
            else:
                warnings.append(f"{name} is configured but empty")
    return warnings


def effective_server_env(raw: dict[str, Any]) -> dict[str, str]:
    args = raw.get("args") or []
    env = {key: str(value) for key, value in (raw.get("env") or {}).items()}
    effective = os.environ.copy()
    effective.update(env)
    for key, value in _dotenv_values(_server_dir(args)).items():
        if not effective.get(key):
            effective[key] = value
    return effective


async def check_server(name: str, raw: dict[str, Any], timeout_seconds: float) -> ServerHealth:
    command = raw.get("command")
    args = raw.get("args") or []
    env = raw.get("env") or {}
    server_dir = _server_dir(args)
    warnings = _env_warnings(env, _dotenv_keys(server_dir))

    if not isinstance(command, str) or not command:
        return ServerHealth(name, False, str(command), list(args), [], warnings, "Missing command.")
    if not isinstance(args, list) or not all(isinstance(item, str) for item in args):
        return ServerHealth(name, False, command, [], [], warnings, "args must be a string list.")
    if not _server_script_exists(args):
        warnings.append(f"Server script does not exist: {args[0]}")

    merged_env = effective_server_env(raw)
    params = StdioServerParameters(command=command, args=args, cwd=REPO_ROOT, env=merged_env)

    try:
        async with asyncio.timeout(timeout_seconds):
            async with stdio_client(params) as (read, write):
                async with ClientSession(read, write) as session:
                    await session.initialize()
                    result = await session.list_tools()
    except Exception as exc:
        return ServerHealth(name, False, command, args, [], warnings, str(exc))

    tools = [tool.name for tool in result.tools]
    if not tools:
        return ServerHealth(name, False, command, args, tools, warnings, "No tools found during discovery.")

    return ServerHealth(name, True, command, args, tools, warnings)


def _json_http_request(
    *,
    method: str,
    url: str,
    payload: dict[str, Any] | None = None,
    headers: dict[str, str] | None = None,
    timeout: float = 20.0,
) -> Any:
    body = None if payload is None else json.dumps(payload).encode("utf-8")
    request_headers = {"Content-Type": "application/json"}
    if headers:
        request_headers.update(headers)
    req = request.Request(url, data=body, method=method.upper(), headers=request_headers)
    with request.urlopen(req, timeout=timeout) as response:
        raw = response.read().decode("utf-8")
    return json.loads(raw) if raw else {}


def _live_openai(env: dict[str, str], timeout: float) -> ServiceHealth:
    api_key = env.get("OPENAI_API_KEY", "")
    model = env.get("OPENAI_EMBEDDING_MODEL", "text-embedding-3-small")
    base = env.get("OPENAI_API_BASE", "https://api.openai.com/v1").rstrip("/")
    if not api_key:
        return ServiceHealth("openai", False, "missing OPENAI_API_KEY", "OPENAI_API_KEY is empty.")
    try:
        payload = {"model": model, "input": "vulture-nest health check"}
        response = _json_http_request(
            method="POST",
            url=f"{base}/embeddings",
            payload=payload,
            headers={"Authorization": f"Bearer {api_key}"},
            timeout=timeout,
        )
        data = response.get("data")
        if not isinstance(data, list) or not data or "embedding" not in data[0]:
            return ServiceHealth("openai", False, "embedding response missing vector", "Unexpected response shape.")
        return ServiceHealth("openai", True, f"embedding request succeeded with model {model}")
    except (error.HTTPError, error.URLError, TimeoutError, ValueError) as exc:
        return ServiceHealth("openai", False, "embedding request failed", str(exc))


def _live_supabase(env: dict[str, str], timeout: float) -> ServiceHealth:
    url = env.get("SUPABASE_URL", "").rstrip("/")
    key = env.get("SUPABASE_SERVICE_KEY", "")
    if not url or not key:
        return ServiceHealth("supabase", False, "missing Supabase URL or service key", "SUPABASE_URL or SUPABASE_SERVICE_KEY is empty.")
    try:
        query = parse.urlencode({"select": "id", "limit": "1"})
        response = _json_http_request(
            method="GET",
            url=f"{url}/rest/v1/source_pages?{query}",
            headers={"apikey": key, "Authorization": f"Bearer {key}"},
            timeout=timeout,
        )
        if not isinstance(response, list):
            return ServiceHealth("supabase", False, "source_pages read returned unexpected payload", "Unexpected response shape.")
        return ServiceHealth("supabase", True, "read-only source_pages query succeeded")
    except (error.HTTPError, error.URLError, TimeoutError, ValueError) as exc:
        return ServiceHealth("supabase", False, "read-only source_pages query failed", str(exc))


def _live_firecrawl(env: dict[str, str], timeout: float) -> ServiceHealth:
    api_key = env.get("FIRECRAWL_API_KEY", "")
    base = env.get("FIRECRAWL_API_BASE", "https://api.firecrawl.dev/v2").rstrip("/")
    if not api_key:
        return ServiceHealth("firecrawl", False, "missing FIRECRAWL_API_KEY", "FIRECRAWL_API_KEY is empty.")
    try:
        response = _json_http_request(
            method="GET",
            url=f"{base}/team/credit-usage",
            headers={"Authorization": f"Bearer {api_key}"},
            timeout=timeout,
        )
        if not isinstance(response, dict):
            return ServiceHealth("firecrawl", False, "credit usage check returned unexpected payload", "Unexpected response shape.")
        return ServiceHealth("firecrawl", True, "credit usage check succeeded")
    except (error.HTTPError, error.URLError, TimeoutError, ValueError) as exc:
        return ServiceHealth("firecrawl", False, "credit usage check failed", str(exc))


def check_live_services(
    config: dict[str, Any],
    *,
    timeout_seconds: float,
    include_firecrawl: bool = False,
) -> list[ServiceHealth]:
    servers = config.get("mcpServers")
    if not isinstance(servers, dict) or "vulture-ingest" not in servers:
        return [ServiceHealth("live-services", False, "vulture-ingest config not found", "Missing vulture-ingest server.")]

    env = effective_server_env(servers["vulture-ingest"])
    results = [_live_openai(env, timeout_seconds), _live_supabase(env, timeout_seconds)]
    if include_firecrawl:
        results.append(_live_firecrawl(env, timeout_seconds))
    else:
        results.append(ServiceHealth("firecrawl", True, "skipped; pass --live-firecrawl to run an external Firecrawl check"))
    return results


async def check_config(path: Path, timeout_seconds: float) -> list[ServerHealth]:
    config = load_config(path)
    return await check_config_data(config, timeout_seconds)


async def check_config_data(config: dict[str, Any], timeout_seconds: float) -> list[ServerHealth]:
    servers = config.get("mcpServers")
    if not isinstance(servers, dict):
        raise ValueError("Invalid MCP config: mcpServers must be an object.")

    results = []
    for name, raw in servers.items():
        if not isinstance(raw, dict):
            results.append(ServerHealth(name, False, "", [], [], [], "Server entry must be an object."))
            continue
        results.append(await check_server(name, raw, timeout_seconds))
    return results


def render_text(results: list[ServerHealth], service_results: list[ServiceHealth] | None = None) -> str:
    lines = ["MCP health check"]
    for result in results:
        status = "OK" if result.ok else "FAIL"
        tool_text = ", ".join(result.tools) if result.tools else "none"
        lines.append(f"- {status} {result.name}: {len(result.tools)} tools ({tool_text})")
        for warning in result.warnings:
            lines.append(f"  warning: {warning}")
        if result.error:
            lines.append(f"  error: {result.error}")
    if service_results is not None:
        lines.append("Live service checks")
        for result in service_results:
            status = "OK" if result.ok else "FAIL"
            lines.append(f"- {status} {result.name}: {result.detail}")
            if result.error:
                lines.append(f"  error: {result.error}")
    return "\n".join(lines)


async def async_main(argv: list[str]) -> int:
    parser = argparse.ArgumentParser(description="Validate MCP server startup and discovery.")
    parser.add_argument("--config", type=Path, default=DEFAULT_CONFIG)
    parser.add_argument("--timeout", type=float, default=10.0)
    parser.add_argument("--json", action="store_true", help="Emit JSON instead of text.")
    parser.add_argument("--live-services", action="store_true", help="Validate live OpenAI and Supabase credentials.")
    parser.add_argument("--live-firecrawl", action="store_true", help="Also validate Firecrawl credentials with a live API call.")
    args = parser.parse_args(argv)

    config = load_config(args.config)
    results = await check_config_data(config, args.timeout)
    service_results = None
    if args.live_services or args.live_firecrawl:
        service_results = check_live_services(
            config,
            timeout_seconds=args.timeout,
            include_firecrawl=args.live_firecrawl,
        )
    if args.json:
        payload: Any = [result.to_dict() for result in results]
        if service_results is not None:
            payload = {
                "servers": [result.to_dict() for result in results],
                "services": [result.to_dict() for result in service_results],
            }
        print(json.dumps(payload, indent=2))
    else:
        print(render_text(results, service_results))
    checks = list(results)
    if service_results is not None:
        checks.extend(service_results)
    return 0 if all(result.ok for result in checks) else 1


def main() -> int:
    try:
        return asyncio.run(async_main(sys.argv[1:]))
    except Exception as exc:
        print(f"MCP health check failed: {exc}", file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
