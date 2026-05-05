import os, sys

env_file = os.path.join(os.path.dirname(__file__), ".env")
with open(env_file) as f:
    for line in f:
        line = line.strip()
        if line and not line.startswith("#") and "=" in line:
            key, _, value = line.partition("=")
            os.environ[key.strip()] = value.strip()

sys.path.insert(0, os.path.dirname(__file__))
import server

page_id = sys.argv[1]
print(f"Purging page_id: {page_id}")
server._db_request("DELETE", "/rest/v1/source_chunks", params={"page_id": f"eq.{page_id}"})
print("  chunks deleted")
server._db_request("DELETE", "/rest/v1/source_pages", params={"id": f"eq.{page_id}"})
print("  page deleted")
print("Done.")
