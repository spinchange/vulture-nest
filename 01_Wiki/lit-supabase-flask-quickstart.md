---
title: 'Literature Note: Supabase Flask Quickstart'
author: claude-sonnet-4-6
date: 2026-05-01
status: active
type: literature
aliases: [lit-supabase-flask, supabase-flask-quickstart]
source: https://supabase.com/docs/guides/getting-started/quickstarts/flask
provenance:
  source_record_ids:
    - "31f3d047-c0e1-4c19-8c33-a3efeaab355f"
  chunk_ids:
    - "74973d96-0e55-496a-82e2-57a72259182d"
    - "5b049707-c646-4acd-8980-a72feca0b220"
  retrieved_at: "2026-05-01"
  acting_agent: "claude-chronicler"
---

# Literature Note: Supabase Flask Quickstart

Official Supabase guide for connecting a Python Flask app to a Supabase project. Covers project creation, RLS configuration, Python client setup, and a minimal server-side rendering pattern.

## Source Summary

### Project Creation
Supabase projects are created via `database.new` (UI) or the Management API (programmatic, via curl with org ID, project name, region, database password).

### Database Setup
```sql
create table instruments (
  id bigint primary key generated always as identity,
  name text not null
);

insert into instruments (name) values ('violin'), ('viola'), ('cello');

grant select on public.instruments to anon;
alter table instruments enable row level security;
create policy "public can read instruments" on public.instruments
  for select to anon using (true);
```
RLS is enabled from the start; the anon role is granted read via an explicit policy.

### Python Environment
```bash
mkdir my-app && cd my-app
python3 -m venv venv
source venv/bin/activate
pip install flask supabase python-dotenv
```

### Configuration
`.env` file holds two values retrieved from the project's Connect dialog:
```
SUPABASE_URL=
SUPABASE_PUBLISHABLE_KEY=
```

### Application Code
```python
import os
from flask import Flask
from supabase import create_client, Client
from dotenv import load_dotenv

load_dotenv()
app = Flask(__name__)

supabase: Client = create_client(
    os.environ.get("SUPABASE_URL"),
    os.environ.get("SUPABASE_PUBLISHABLE_KEY")
)

@app.route('/')
def index():
    response = supabase.table('instruments').select("*").execute()
    instruments = response.data
    html = '<h1>Instruments</h1><ul>'
    for instrument in instruments:
        html += f'<li>{instrument["name"]}</li>'
    html += '</ul>'
    return html

if __name__ == '__main__':
    app.run(debug=True)
```

## Key Observations
- `create_client()` is called once at module level — acts as a connection singleton
- Query API is method-chained: `.table().select().execute()`
- Response data lives in `.data` attribute of the returned object
- Authorization is handled entirely by RLS, not application logic
- `SUPABASE_PUBLISHABLE_KEY` (not the secret service key) is used — safe for server environments without full privilege escalation risk

## Links
- [[pattern-supabase-flask-integration]] — extracted integration pattern
