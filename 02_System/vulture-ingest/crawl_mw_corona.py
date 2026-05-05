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

targets = [
    ("https://en.wikipedia.org/wiki/Milky_Way",    ["/wiki/Milky_Way"]),
    ("https://en.wikipedia.org/wiki/Solar_corona",  ["/wiki/Solar_corona"]),
]

DELAY = 25

results = []
for i, (url, include_paths) in enumerate(targets):
    if i > 0:
        print(f"\n  Waiting {DELAY}s...")
        time.sleep(DELAY)
    print(f"\n[{i+1}/{len(targets)}] Crawling: {url}")
    try:
        crawl = server.execute_source_crawl(
            url=url, expected_pages=1, dry_run=False, human_approved=True,
            include_paths=include_paths, max_polls=60, poll_interval_seconds=5,
        )
        pages = crawl.get("pages", [])
        print(f"  {len(pages)} page(s) — job {crawl.get('job_id','?')}")
        for page in pages:
            page_url = page.get("metadata", {}).get("sourceURL", "")
            title = page.get("metadata", {}).get("title", "Unknown")
            print(f"  Indexing: {title}")
            idx = server.index_crawled_source(crawled_page=page)
            print(f"    chunks={idx.get('chunk_count')} page_id={idx.get('page_id')}")
            results.append({"url": page_url, "title": title,
                            "page_id": idx.get("page_id"), "chunks": idx.get("chunk_count")})
    except Exception as e:
        print(f"  ERROR: {e}")

print("\n=== Summary ===")
for r in results:
    print(f"  {r['chunks']:3d} chunks  {r['title']}  ({r['page_id']})")
print(f"  Total: {sum(r['chunks'] or 0 for r in results)} chunks")
