from __future__ import annotations

import hashlib
import logging
import os
import secrets
import re
import tempfile
from datetime import datetime
from pathlib import Path
from typing import Any

try:
    import yaml
except ImportError:  # pragma: no cover - optional dependency fallback
    yaml = None

try:
    from mcp.server.auth.provider import AccessToken, TokenVerifier
    from mcp.server.fastmcp import FastMCP
except ImportError as exc:  # pragma: no cover - runtime dependency gate
    raise RuntimeError(
        "The MCP Python SDK is required to run the ChatGPT web wrapper."
    ) from exc


LOG = logging.getLogger("chatgpt-web-mcp-wrapper")
REPO_ROOT = Path(__file__).resolve().parents[1]
WIKI_ROOT = Path(os.environ.get("VULTURE_WIKI_ROOT", REPO_ROOT / "01_Wiki")).resolve()
HOST = os.environ.get("CHATGPT_WEB_MCP_HOST", "127.0.0.1")
PORT = int(os.environ.get("CHATGPT_WEB_MCP_PORT", "3000"))
PUBLIC_URL = os.environ.get("CHATGPT_WEB_MCP_PUBLIC_URL", f"http://{HOST}:{PORT}")
BEARER_TOKEN = os.environ.get("CHATGPT_WEB_MCP_BEARER_TOKEN", "")


class StaticBearerTokenVerifier(TokenVerifier):
    def __init__(self, expected_token: str, server_url: str) -> None:
        self.expected_token = expected_token
        self.server_url = server_url

    async def verify_token(self, token: str) -> AccessToken | None:
        if not self.expected_token:
            return None
        if not secrets.compare_digest(token, self.expected_token):
            return None

        return AccessToken(
            token=token,
            client_id="chatgpt-web",
            scopes=["vault:read", "vault:write"],
            expires_at=None,
            resource=self.server_url,
        )


def _relative_note_path(note_path: str) -> Path:
    candidate = Path(note_path.strip())
    if not candidate.suffix:
        candidate = candidate.with_suffix(".md")

    if candidate.is_absolute():
        try:
            candidate = candidate.relative_to(WIKI_ROOT)
        except ValueError as exc:
            raise ValueError("Note path must resolve within 01_Wiki.") from exc

    resolved = (WIKI_ROOT / candidate).resolve()
    if resolved != WIKI_ROOT and WIKI_ROOT not in resolved.parents:
        raise ValueError("Note path must resolve within 01_Wiki.")
    return resolved


def _all_notes() -> list[Path]:
    return sorted(WIKI_ROOT.rglob("*.md"))


def _read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def _frontmatter_block(text: str) -> str | None:
    match = re.match(r"(?s)^---\s*\r?\n(.*?)\r?\n---\s*", text)
    return match.group(1) if match else None


def _frontmatter_data(text: str) -> dict[str, Any]:
    frontmatter = _frontmatter_block(text)
    if not frontmatter:
        return {}
    if yaml is None:
        return {}
    try:
        data = yaml.safe_load(frontmatter)
        return data if isinstance(data, dict) else {}
    except Exception:
        return {}


def _frontmatter_value(text: str, key: str) -> str | None:
    data = _frontmatter_data(text)
    value = data.get(key)
    if value is None:
        frontmatter = _frontmatter_block(text)
        if not frontmatter:
            return None
        match = re.search(rf"(?m)^\s*{re.escape(key)}\s*:\s*(.+)\s*$", frontmatter)
        if not match:
            return None
        value = match.group(1).strip()
    if isinstance(value, list):
        return ", ".join(str(item) for item in value)
    return str(value).strip()


def _validate_yanp_write(path: Path, content: str) -> list[str]:
    issues: list[str] = []
    if path.suffix.lower() != ".md":
        issues.append("Target must end with .md.")

    stem = path.stem
    if stem != stem.lower() or not re.fullmatch(r"[a-z0-9]+(?:-[a-z0-9]+)*", stem):
        issues.append("Filename stem must be lowercase kebab-case.")

    frontmatter = _frontmatter_block(content)
    if frontmatter is None:
        issues.append("Missing YAML frontmatter.")
        return issues

    data = _frontmatter_data(content)
    required = ("title", "author", "date", "status", "aliases")
    missing = [key for key in required if key not in data]
    if missing:
        issues.append(f"Missing required frontmatter field(s): {', '.join(missing)}.")

    return issues


def _snippet(text: str, term: str, radius: int = 80) -> str:
    idx = text.lower().find(term.lower())
    if idx < 0:
        return text[: 2 * radius].strip()
    start = max(0, idx - radius)
    end = min(len(text), idx + len(term) + radius)
    return text[start:end].replace("\r", " ").replace("\n", " ").strip()


def _search_notes(query: str, limit: int = 10) -> list[dict[str, Any]]:
    needle = query.strip().lower()
    if not needle:
        return []

    results: list[dict[str, Any]] = []
    for note in _all_notes():
        text = _read_text(note)
        haystack = text.lower()
        title = _frontmatter_value(text, "title") or note.stem
        aliases = _frontmatter_value(text, "aliases") or ""

        if needle not in haystack and needle not in title.lower() and needle not in aliases.lower():
            continue

        matches = []
        for line in text.splitlines():
            if needle in line.lower():
                matches.append(line.strip())
            if len(matches) >= 3:
                break

        results.append(
            {
                "path": str(note.relative_to(WIKI_ROOT)),
                "title": title,
                "matches": matches,
                "snippet": _snippet(text, query),
            }
        )
        if len(results) >= limit:
            break
    return results


def _write_atomic(path: Path, content: str) -> dict[str, Any]:
    path.parent.mkdir(parents=True, exist_ok=True)
    sha256 = hashlib.sha256(content.encode("utf-8")).hexdigest()
    with tempfile.NamedTemporaryFile("w", encoding="utf-8", delete=False, dir=path.parent, suffix=".tmp") as tmp:
        tmp.write(content)
        tmp_path = Path(tmp.name)
    tmp_path.replace(path)
    return {
        "path": str(path.relative_to(WIKI_ROOT)),
        "bytes": len(content.encode("utf-8")),
        "sha256": sha256,
        "written_at": datetime.now().isoformat(timespec="seconds"),
    }


def build_server() -> FastMCP:
    verifier = StaticBearerTokenVerifier(BEARER_TOKEN, PUBLIC_URL) if BEARER_TOKEN else None
    server = FastMCP(
        name="Vulture Nest ChatGPT Web Wrapper",
        instructions=(
            "Remote MCP wrapper for the Vulture Nest vault. "
            "Use for search, read, and atomic note writes."
        ),
        host=HOST,
        port=PORT,
        streamable_http_path="/mcp",
        token_verifier=verifier,
    )

    @server.tool()
    def vault_search(query: str, limit: int = 10) -> dict[str, Any]:
        """Search the vault for matching notes and snippets."""
        return {
            "query": query,
            "limit": limit,
            "wiki_root": str(WIKI_ROOT),
            "results": _search_notes(query, limit=limit),
        }

    @server.tool()
    def vault_read(note_path: str) -> dict[str, Any]:
        """Read a single markdown note from the vault."""
        path = _relative_note_path(note_path)
        if not path.exists():
            raise FileNotFoundError(f"Note not found: {note_path}")
        text = _read_text(path)
        return {
            "path": str(path.relative_to(WIKI_ROOT)),
            "title": _frontmatter_value(text, "title") or path.stem,
            "content": text,
            "sha256": hashlib.sha256(text.encode("utf-8")).hexdigest(),
        }

    @server.tool()
    def vault_propose_write(note_path: str, content: str) -> dict[str, Any]:
        """Validate a proposed note write without applying it."""
        path = _relative_note_path(note_path)
        issues = _validate_yanp_write(path, content)
        return {
            "path": str(path.relative_to(WIKI_ROOT)),
            "ok": not issues,
            "issues": issues,
            "bytes": len(content.encode("utf-8")),
        }

    @server.tool()
    def vault_apply_write(note_path: str, content: str, overwrite: bool = False) -> dict[str, Any]:
        """Atomically write a markdown note into the vault."""
        path = _relative_note_path(note_path)
        issues = _validate_yanp_write(path, content)
        if issues:
            raise ValueError("; ".join(issues))
        if path.exists() and not overwrite:
            raise FileExistsError(f"Refusing to overwrite existing note: {path.relative_to(WIKI_ROOT)}")
        return _write_atomic(path, content)

    return server


def main() -> int:
    logging.basicConfig(level=logging.INFO, format="%(asctime)s %(levelname)s %(message)s")
    if not WIKI_ROOT.exists():
        raise FileNotFoundError(f"Wiki root not found: {WIKI_ROOT}")
    if not BEARER_TOKEN:
        raise RuntimeError(
            "CHATGPT_WEB_MCP_BEARER_TOKEN must be set before starting the remote wrapper."
        )

    server = build_server()
    LOG.info("Starting ChatGPT web wrapper on %s:%s", HOST, PORT)
    LOG.info("Wiki root: %s", WIKI_ROOT)
    LOG.info("Public URL: %s", PUBLIC_URL)
    server.run(transport="streamable-http")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
