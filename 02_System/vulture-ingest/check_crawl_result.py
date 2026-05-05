import json, sys

with open(sys.argv[1]) as f:
    data = json.load(f)
if isinstance(data, list):
    data = json.loads(data[0]["text"])
pages = data.get("pages", [])
print("status:", data.get("status"))
print("mode:", data.get("mode"))
print("page_count:", data.get("page_count"))
print("job_id:", data.get("job_id"))
for p in pages:
    md = p.get("markdown", "")
    title = p.get("metadata", {}).get("title", "")
    url = p.get("metadata", {}).get("sourceURL", "")
    print(f"  [{title}] {url} — {len(md):,} chars markdown")
