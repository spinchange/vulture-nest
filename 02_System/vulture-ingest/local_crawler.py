from __future__ import annotations

"""Local Firecrawl replacement for bounded source ingestion.

One-time setup for JS-rendered pages:
    pip install playwright
    playwright install chromium

Manual dependency install for this module:
    pip install requests trafilatura html2text playwright
"""

import re
import time
import uuid
from collections import deque
from dataclasses import dataclass
from html import unescape
from html.parser import HTMLParser
from typing import Any
from urllib.parse import urljoin, urlparse, urlunparse


_SKIP_EXTENSIONS = {
    ".7z",
    ".avi",
    ".bin",
    ".csv",
    ".doc",
    ".docx",
    ".epub",
    ".exe",
    ".gif",
    ".gz",
    ".ico",
    ".jpeg",
    ".jpg",
    ".json",
    ".mp3",
    ".mp4",
    ".pdf",
    ".png",
    ".ppt",
    ".pptx",
    ".rar",
    ".svg",
    ".tar",
    ".tgz",
    ".tif",
    ".tiff",
    ".txt",
    ".webm",
    ".webp",
    ".xls",
    ".xlsx",
    ".xml",
    ".zip",
}
_MIN_MARKDOWN_CHARS = 400
_MIN_STATIC_BODY_CHARS = 1200
_REQUEST_TIMEOUT = 30
_REQUEST_DELAY_SECONDS = 1.0
_USER_AGENT = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) "
    "AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"
)


def _lazy_import_requests():
    try:
        import requests
    except ImportError as exc:  # pragma: no cover - depends on environment
        raise RuntimeError("local_crawler requires `requests`. Install: pip install requests") from exc
    return requests


def _lazy_import_trafilatura():
    try:
        import trafilatura
    except ImportError as exc:  # pragma: no cover - depends on environment
        raise RuntimeError("local_crawler requires `trafilatura`. Install: pip install trafilatura") from exc
    return trafilatura


def _lazy_import_html2text():
    try:
        import html2text
    except ImportError as exc:  # pragma: no cover - depends on environment
        raise RuntimeError("local_crawler requires `html2text`. Install: pip install html2text") from exc
    return html2text


def _lazy_import_playwright():
    try:
        from playwright.sync_api import sync_playwright
    except ImportError as exc:  # pragma: no cover - depends on environment
        raise RuntimeError("local_crawler requires `playwright`. Install: pip install playwright") from exc
    return sync_playwright


class _AnchorParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        if tag.lower() != "a":
            return
        for key, value in attrs:
            if key.lower() == "href" and value:
                self.links.append(value)
                break


@dataclass
class _FetchedPage:
    url: str
    status_code: int
    html: str
    markdown: str
    title: str
    language: str
    links: list[str]


def _normalize_url(url: str) -> str:
    parsed = urlparse(url.strip())
    if not parsed.scheme or not parsed.netloc:
        raise ValueError(f"Invalid URL: {url}")
    path = parsed.path or "/"
    normalized = parsed._replace(fragment="", path=path)
    return urlunparse(normalized)


def _normalize_path_prefix(path: str) -> str:
    if not path:
        return "/"
    parsed = urlparse(path)
    candidate = parsed.path if parsed.scheme or parsed.netloc else path
    if not candidate.startswith("/"):
        candidate = f"/{candidate}"
    return candidate.rstrip("/") or "/"


def _matches_path_filters(url: str, include_paths: list[str], exclude_paths: list[str]) -> bool:
    path = urlparse(url).path.rstrip("/") or "/"
    normalized_includes = [_normalize_path_prefix(item) for item in include_paths if item]
    normalized_excludes = [_normalize_path_prefix(item) for item in exclude_paths if item]
    if normalized_includes and not any(path.startswith(prefix) for prefix in normalized_includes):
        return False
    if any(path.startswith(prefix) for prefix in normalized_excludes):
        return False
    return True


def _is_same_domain(candidate_url: str, domain: str) -> bool:
    parsed = urlparse(candidate_url)
    return parsed.scheme in {"http", "https"} and parsed.netloc == domain


def _is_skippable_url(candidate_url: str) -> bool:
    parsed = urlparse(candidate_url)
    lowered_path = parsed.path.lower()
    return any(lowered_path.endswith(ext) for ext in _SKIP_EXTENSIONS)


def _extract_title(html: str) -> str:
    match = re.search(r"<title[^>]*>(.*?)</title>", html, flags=re.IGNORECASE | re.DOTALL)
    if not match:
        return ""
    return re.sub(r"\s+", " ", unescape(match.group(1))).strip()


def _extract_language(html: str) -> str:
    match = re.search(r"<html[^>]+lang=[\"']?([a-zA-Z-]+)", html, flags=re.IGNORECASE)
    if not match:
        return "en"
    return match.group(1).strip() or "en"


def _extract_links(base_url: str, html: str, domain: str) -> list[str]:
    parser = _AnchorParser()
    parser.feed(html)
    links: list[str] = []
    seen: set[str] = set()
    for href in parser.links:
        absolute = _normalize_discovered_url(base_url, href)
        if not absolute or absolute in seen:
            continue
        if not _is_same_domain(absolute, domain) or _is_skippable_url(absolute):
            continue
        seen.add(absolute)
        links.append(absolute)
    return links


def _normalize_discovered_url(base_url: str, href: str) -> str | None:
    candidate = href.strip()
    if not candidate or candidate.startswith(("#", "mailto:", "tel:", "javascript:")):
        return None
    joined = urljoin(base_url, candidate)
    parsed = urlparse(joined)
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        return None
    if parsed.query:
        filtered_pairs = []
        for item in parsed.query.split("&"):
            if item.startswith(("utm_", "fbclid=", "gclid=", "ref=")):
                continue
            filtered_pairs.append(item)
        query = "&".join(filtered_pairs)
    else:
        query = ""
    normalized = parsed._replace(fragment="", query=query, path=parsed.path or "/")
    return urlunparse(normalized)


def _html_to_markdown(html: str) -> str:
    html2text = _lazy_import_html2text()
    renderer = html2text.HTML2Text()
    renderer.body_width = 0
    renderer.ignore_images = True
    renderer.ignore_emphasis = False
    renderer.ignore_links = False
    return renderer.handle(html).strip()


def _extract_markdown(html: str, url: str) -> str:
    trafilatura = _lazy_import_trafilatura()
    markdown = trafilatura.extract(
        html,
        url=url,
        output_format="markdown",
        include_links=True,
        include_images=False,
        include_formatting=True,
        favor_precision=True,
    )
    if markdown and markdown.strip():
        return markdown.strip()
    return _html_to_markdown(html)


def _needs_js_render(response_text: str, markdown: str) -> bool:
    if len(markdown.strip()) >= _MIN_MARKDOWN_CHARS:
        return False
    if len(response_text) < _MIN_STATIC_BODY_CHARS:
        return True
    lower = response_text.lower()
    markers = (
        "__next",
        'id="root"',
        "data-reactroot",
        "application/ld+json",
        "webpack",
        "hydration",
    )
    return any(marker in lower for marker in markers)


def _fetch_with_requests(url: str) -> tuple[int, str]:
    requests = _lazy_import_requests()
    response = requests.get(
        url,
        timeout=_REQUEST_TIMEOUT,
        headers={"User-Agent": _USER_AGENT, "Accept-Language": "en-US,en;q=0.9"},
    )
    response.raise_for_status()
    return response.status_code, response.text


def _fetch_with_playwright(url: str) -> tuple[int, str]:
    sync_playwright = _lazy_import_playwright()
    try:
        with sync_playwright() as playwright:
            browser = playwright.chromium.launch(headless=True)
            page = browser.new_page(user_agent=_USER_AGENT, locale="en-US")
            response = page.goto(url, wait_until="networkidle", timeout=_REQUEST_TIMEOUT * 1000)
            page.wait_for_timeout(1200)
            html = page.content()
            browser.close()
            return response.status if response else 200, html
    except Exception as exc:  # pragma: no cover - depends on browser install/network
        raise RuntimeError(
            "Playwright render failed. Ensure dependencies are installed and run `playwright install chromium`."
        ) from exc


def _fetch_page(url: str, domain: str) -> _FetchedPage:
    status_code, html = _fetch_with_requests(url)
    markdown = _extract_markdown(html, url)
    if _needs_js_render(html, markdown):
        status_code, html = _fetch_with_playwright(url)
        markdown = _extract_markdown(html, url)
    title = _extract_title(html)
    language = _extract_language(html)
    links = _extract_links(url, html, domain)
    return _FetchedPage(
        url=url,
        status_code=status_code,
        html=html,
        markdown=markdown,
        title=title,
        language=language,
        links=links,
    )


def crawl_local(
    url: str,
    expected_pages: int,
    include_paths: list[str] | None,
    exclude_paths: list[str] | None,
    max_discovery_depth: int,
) -> dict[str, Any]:
    seed_url = _normalize_url(url)
    include_paths = include_paths or []
    exclude_paths = exclude_paths or []
    domain = urlparse(seed_url).netloc
    expected_pages = max(1, int(expected_pages))
    max_discovery_depth = max(0, int(max_discovery_depth))
    job_id = str(uuid.uuid4())

    queue: deque[tuple[str, int]] = deque([(seed_url, 0)])
    queued = {seed_url}
    visited: set[str] = set()
    pages: list[dict[str, Any]] = []

    while queue and len(pages) < expected_pages:
        current_url, depth = queue.popleft()
        if current_url in visited:
            continue
        visited.add(current_url)
        if not _matches_path_filters(current_url, include_paths, exclude_paths):
            continue

        fetched = _fetch_page(current_url, domain)
        if fetched.markdown.strip():
            pages.append(
                {
                    "markdown": fetched.markdown,
                    "metadata": {
                        "title": fetched.title,
                        "sourceURL": fetched.url,
                        "statusCode": fetched.status_code,
                        "language": fetched.language,
                    },
                }
            )

        if depth >= max_discovery_depth or len(pages) >= expected_pages:
            time.sleep(_REQUEST_DELAY_SECONDS)
            continue

        for discovered_url in fetched.links:
            if discovered_url in visited or discovered_url in queued:
                continue
            if not _matches_path_filters(discovered_url, include_paths, exclude_paths):
                continue
            queue.append((discovered_url, depth + 1))
            queued.add(discovered_url)

        time.sleep(_REQUEST_DELAY_SECONDS)

    return {
        "status": "crawled",
        "mode": "live",
        "url": seed_url,
        "domain": domain,
        "job_id": job_id,
        "page_count": len(pages),
        "pages": pages,
        "next_state": "indexed",
    }
