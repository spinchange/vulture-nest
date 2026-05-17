import os, sys, time

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

targets = [
    "https://en.wikipedia.org/wiki/Gravitational_wave",
    "https://en.wikipedia.org/wiki/Cosmic_microwave_background",
    "https://en.wikipedia.org/wiki/Exoplanet",
    "https://en.wikipedia.org/wiki/Sirius",
    "https://en.wikipedia.org/wiki/Uranus",
    "https://en.wikipedia.org/wiki/Uranus_(mythology)",
]

DELAY = 5
results = []
for i, url in enumerate(targets):
    if i > 0:
        time.sleep(DELAY)
    path = urlparse(url).path
    print(f"\n[{i+1}/{len(targets)}] {url}")
    try:
        crawl = server.execute_source_crawl(
            url=url, expected_pages=1, dry_run=False, human_approved=True,
            include_paths=[path], max_polls=60, poll_interval_seconds=5,
        )
        pages = crawl.get("pages", [])
        print(f"  {len(pages)} page(s)")
        for page in pages:
            title = page.get("metadata", {}).get("title", "Unknown")
            try:
                idx = server.index_crawled_source(crawled_page=page)
                print(f"  OK {title} -- {idx.get('chunk_count')} chunks ({idx.get('page_id')})")
                results.append({"title": title, "chunks": idx.get("chunk_count") or 0, "page_id": idx.get("page_id")})
            except Exception as e:
                print(f"  INDEX ERROR {title}: {e}")
    except Exception as e:
        print(f"  ERROR: {e}")

print(f"\n=== {sum(r['chunks'] for r in results)} chunks across {len(results)} pages ===")
for r in results:
    print(f"  {r['chunks']:3d}  {r['title']}")
