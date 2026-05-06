"""Generic batch crawl-and-index tool.

Usage:
    # Crawl one or more URLs directly
    python crawl.py https://en.wikipedia.org/wiki/Venus https://en.wikipedia.org/wiki/Aphrodite

    # Crawl URLs from a text file (one per line, # comments ignored)
    python crawl.py --file urls.txt

    # Options
    --delay N       Seconds between crawls (default: 5, was 25 for Firecrawl)
    --pages N       Expected pages per crawl (default: 1)
    --dry-run       Propose and map only, no actual crawl or index
    --no-index      Crawl only, skip indexing
    --include PATH  Restrict crawl to this path prefix (repeatable)
    --exclude PATH  Exclude this path prefix (repeatable)

    # Include paths default to the seed URL's path (prevents following links elsewhere).
    # Pass --include "" to disable filtering entirely.
"""

import argparse
import os
import sys
import time

env_file = os.path.join(os.path.dirname(__file__), ".env")
with open(env_file) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            os.environ[key.strip()] = value.strip()

sys.path.insert(0, os.path.dirname(__file__))
import server
from urllib.parse import urlparse


def load_urls(args):
    urls = list(args.urls)
    if args.file:
        with open(args.file) as f:
            for line in f:
                line = line.strip()
                if line and not line.startswith("#"):
                    urls.append(line)
    return urls


def default_include(url):
    parsed = urlparse(url)
    return [parsed.path] if parsed.path and parsed.path != "/" else []


def main():
    parser = argparse.ArgumentParser(description="Crawl and index URLs into Supabase.")
    parser.add_argument("urls", nargs="*", help="URLs to crawl")
    parser.add_argument("--file", help="Text file of URLs (one per line)")
    parser.add_argument("--delay", type=float, default=5.0, help="Seconds between crawls")
    parser.add_argument("--pages", type=int, default=1, help="Expected pages per seed URL")
    parser.add_argument("--dry-run", action="store_true", help="Skip actual crawl/index")
    parser.add_argument("--no-index", action="store_true", help="Crawl but do not index")
    parser.add_argument("--include", action="append", dest="include_paths", metavar="PATH")
    parser.add_argument("--exclude", action="append", dest="exclude_paths", metavar="PATH")
    args = parser.parse_args()

    urls = load_urls(args)
    if not urls:
        parser.error("Provide at least one URL or --file.")

    results = []
    for i, url in enumerate(urls):
        if i > 0:
            time.sleep(args.delay)

        include = args.include_paths if args.include_paths is not None else default_include(url)
        exclude = args.exclude_paths or []

        print(f"\n[{i+1}/{len(urls)}] {url}")
        if include:
            print(f"  include: {include}")

        try:
            crawl = server.execute_source_crawl(
                url=url,
                expected_pages=args.pages,
                dry_run=args.dry_run,
                human_approved=True,
                include_paths=include if include else None,
                exclude_paths=exclude if exclude else None,
                max_polls=60,
                poll_interval_seconds=5,
            )
            pages = crawl.get("pages", [])
            print(f"  {len(pages)} page(s) -- job {crawl.get('job_id', '?')}")

            if args.dry_run or args.no_index:
                for page in pages:
                    title = page.get("metadata", {}).get("title", "")
                    print(f"  (not indexed) {title}")
                continue

            for page in pages:
                page_url = page.get("metadata", {}).get("sourceURL", "")
                if "?action=edit" in page_url:
                    continue
                title = page.get("metadata", {}).get("title", "Unknown")
                try:
                    idx = server.index_crawled_source(crawled_page=page)
                    print(f"  OK {title} -- {idx.get('chunk_count')} chunks ({idx.get('page_id')})")
                    results.append({
                        "url": page_url,
                        "title": title,
                        "page_id": idx.get("page_id"),
                        "chunks": idx.get("chunk_count") or 0,
                    })
                except Exception as e:
                    print(f"  INDEX ERROR {title}: {e}")

        except Exception as e:
            print(f"  ERROR: {e}")

    if results:
        print(f"\n=== Summary: {sum(r['chunks'] for r in results)} chunks across {len(results)} pages ===")
        for r in results:
            print(f"  {r['chunks']:3d}  {r['title']}")


if __name__ == "__main__":
    main()
