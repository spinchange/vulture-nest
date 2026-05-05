import os, sys, time, json, pathlib

env_file = os.path.join(os.path.dirname(__file__), ".env")
with open(env_file) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            os.environ[key.strip()] = value.strip()

sys.path.insert(0, os.path.dirname(__file__))
import server

urls = [
    ("https://en.wikipedia.org/wiki/Heliosphere",           ["/wiki/Heliosphere"]),
    ("https://en.wikipedia.org/wiki/Heliopause_(astronomy)", ["/wiki/Heliopause_(astronomy)"]),
    ("https://en.wikipedia.org/wiki/Stellar_nucleosynthesis",["/wiki/Stellar_nucleosynthesis"]),
    ("https://en.wikipedia.org/wiki/Van_Allen_radiation_belt",["/wiki/Van_Allen_radiation_belt"]),
    ("https://en.wikipedia.org/wiki/Outer_Space_Treaty",     ["/wiki/Outer_Space_Treaty"]),
    ("https://en.wikipedia.org/wiki/Space_debris",           ["/wiki/Space_debris"]),
]

DELAY = 25  # seconds between crawls to respect 3 req/min limit

results = []
for i, (url, include_paths) in enumerate(urls):
    if i > 0:
        print(f"  Waiting {DELAY}s before next crawl...")
        time.sleep(DELAY)

    print(f"\n[{i+1}/{len(urls)}] Crawling: {url}")
    try:
        crawl = server.execute_source_crawl(
            url=url,
            expected_pages=1,
            dry_run=False,
            human_approved=True,
            include_paths=include_paths,
            max_polls=60,
            poll_interval_seconds=5,
        )
        pages = crawl.get("pages", [])
        print(f"  Crawled {len(pages)} page(s) — job {crawl.get('job_id','?')}")

        for page in pages:
            page_url = page.get("metadata", {}).get("sourceURL", "")
            if "?action=edit" in page_url:
                print(f"  Skipping edit page: {page_url}")
                continue
            title = page.get("metadata", {}).get("title", "Unknown")
            print(f"  Indexing: {title}")
            idx = server.index_crawled_source(crawled_page=page)
            print(f"    status={idx.get('status')} page_id={idx.get('page_id')} chunks={idx.get('chunk_count')}")
            results.append({"url": page_url, "title": title, "page_id": idx.get("page_id"), "chunks": idx.get("chunk_count")})

    except Exception as e:
        print(f"  ERROR: {e}")

print("\n=== Summary ===")
for r in results:
    print(f"  {r['title']}: {r['chunks']} chunks ({r['page_id']})")
