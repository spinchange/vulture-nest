from pathlib import Path
import sys

sys.path.insert(0, str(Path(__file__).parent / "vulture-ingest"))

from chunker import OVERLAP_TOKENS, chunk_markdown, sliding_window, split_by_heading


def test_no_headings_uses_preamble_section():
    markdown = " ".join(["intro"] * 80)
    sections = split_by_heading(markdown)

    assert sections == [("(preamble)", markdown)]

    chunks = chunk_markdown(
        markdown,
        {"url": "https://example.com/docs", "title": "Doc", "crawled_at": "2026-04-27T00:00:00Z"},
    )
    assert chunks
    assert any("intro" in chunk["content"] for chunk in chunks)
    assert all(chunk["section_heading"] == "(preamble)" for chunk in chunks)


def test_empty_section_body_is_skipped():
    markdown = "## Heading\n\n## Next Heading\n\n" + " ".join(["body"] * 80)
    sections = split_by_heading(markdown)

    assert ("Heading", "\n\n") not in sections
    assert sections[-1][0] == "Next Heading"


def test_min_chunk_enforcement_discards_short_sections():
    markdown = "## Tiny\n\n" + " ".join(["short"] * 30)
    chunks = chunk_markdown(
        markdown,
        {"url": "https://example.com/docs", "title": "Doc", "crawled_at": "2026-04-27T00:00:00Z"},
    )

    assert chunks == []


def test_overlap_correctness():
    text = " ".join(f"word{i}" for i in range(700))
    windows = list(sliding_window(text, max_tokens=512, overlap=OVERLAP_TOKENS))

    assert len(windows) >= 2
    first_words = windows[0].split()
    second_words = windows[1].split()
    assert first_words[-OVERLAP_TOKENS:] == second_words[:OVERLAP_TOKENS]


def test_chunk_total_backfill():
    markdown = "# Heading\n\n" + " ".join(["alpha"] * 700)
    chunks = chunk_markdown(
        markdown,
        {"url": "https://example.com/docs", "title": "Doc", "crawled_at": "2026-04-27T00:00:00Z"},
    )

    assert chunks
    assert all(chunk["chunk_total"] == len(chunks) for chunk in chunks)


def test_provenance_passthrough():
    meta = {"url": "https://docs.example.com/path", "title": "Reference", "crawled_at": "2026-04-27T12:00:00Z"}
    markdown = "# Heading\n\n" + " ".join(["signal"] * 80)
    chunks = chunk_markdown(markdown, meta)

    assert chunks
    for chunk in chunks:
        assert chunk["source_url"] == meta["url"]
        assert chunk["domain"] == "docs.example.com"
        assert chunk["page_title"] == meta["title"]
        assert chunk["crawled_at"] == meta["crawled_at"]
