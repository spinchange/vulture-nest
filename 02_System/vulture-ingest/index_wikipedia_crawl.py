import os
import sys
import json

# Load .env
env_file = os.path.join(os.path.dirname(__file__), ".env")
with open(env_file) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            os.environ[key.strip()] = value.strip()

sys.path.insert(0, os.path.dirname(__file__))
import server

crawl_file = sys.argv[1]
with open(crawl_file) as f:
    data = json.load(f)

pages = data.get("pages", [])
print(f"Total pages in crawl: {len(pages)}")

for page in pages:
    url = page.get("metadata", {}).get("sourceURL", "")
    if "?action=edit" in url:
        print(f"Skipping edit page: {url}")
        continue
    title = page.get("metadata", {}).get("title", "Unknown")
    print(f"Indexing: {title}")
    try:
        result = server.index_crawled_source(crawled_page=page)
        print(f"  status={result.get('status')} page_id={result.get('page_id')} chunks={result.get('chunk_count')} reindexed={result.get('reindexed')}")
    except Exception as e:
        print(f"  ERROR: {e}")
