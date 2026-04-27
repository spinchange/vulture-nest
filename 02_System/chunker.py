import hashlib
import re
from collections.abc import Iterator
from urllib.parse import urlparse

MAX_CHUNK_TOKENS = 512
OVERLAP_TOKENS = 50
MIN_CHUNK_WORDS = 50

try:
    import tiktoken
except ImportError:  # pragma: no cover - exercised via fallback path
    tiktoken = None


def sha256(text: str) -> str:
    return hashlib.sha256(text.encode("utf-8")).hexdigest()


def extract_domain(url: str) -> str:
    return urlparse(url).netloc


def count_tokens(text: str) -> int:
    if tiktoken is None:
        return max(1, int(len(text.split()) * 1.3))
    encoding = tiktoken.get_encoding("cl100k_base")
    return len(encoding.encode(text))


def split_by_heading(markdown: str) -> list[tuple[str, str]]:
    """Split on H1/H2/H3 headings. Returns list of (heading_text, section_body)."""
    pattern = re.compile(r"^(#{1,3} .+)$", re.MULTILINE)
    parts = pattern.split(markdown)
    result = [("(preamble)", parts[0] if parts else "")]
    for i in range(1, len(parts), 2):
        heading = parts[i].lstrip("#").strip()
        body = parts[i + 1] if i + 1 < len(parts) else ""
        if body.strip():
            result.append((heading, body))
    return result


def sliding_window(text: str, max_tokens: int, overlap: int) -> Iterator[str]:
    """Yield overlapping token windows over text using word boundaries."""
    words = text.split()
    if not words:
        return

    start = 0
    while start < len(words):
        end = min(len(words), start + max_tokens)
        yield " ".join(words[start:end])
        if end >= len(words):
            break
        start = max(start + 1, end - overlap)


def chunk_markdown(markdown: str, page_meta: dict) -> list[dict]:
    """Split markdown by heading, then fixed-size within each section."""
    sections = split_by_heading(markdown)
    chunks: list[dict] = []
    idx = 0

    for heading, section_text in sections:
        for window in sliding_window(section_text, MAX_CHUNK_TOKENS, OVERLAP_TOKENS):
            if len(window.split()) < MIN_CHUNK_WORDS:
                continue
            chunks.append(
                {
                    "content": window,
                    "content_hash": sha256(window),
                    "section_heading": heading,
                    "chunk_index": idx,
                    "source_url": page_meta["url"],
                    "domain": extract_domain(page_meta["url"]),
                    "page_title": page_meta["title"],
                    "crawled_at": page_meta["crawled_at"],
                }
            )
            idx += 1

    for chunk in chunks:
        chunk["chunk_total"] = idx

    return chunks
