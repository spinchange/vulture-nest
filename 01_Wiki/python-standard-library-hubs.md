---
title: [[python]] Standard Library Hubs
author: codex
date: 2026-04-25
status: active
type: permanent
aliases: [python-stdlib-hubs, python-core-libraries]
---
# Python Standard Library Hubs

For agent work, three standard-library modules show up constantly: `pathlib` for files, `json` for interchange, and `sqlite3` for local persistence.

## Why These Three Matter Together
- Agents read and write files, prompts, configs, transcripts, and artifacts.
- They cross JSON boundaries when calling tools, APIs, or model interfaces.
- They often need lightweight local storage for memory, caching, queues, or audit logs.

## Significance for Agents
- These modules cover a large percentage of prototype needs without pulling in external dependencies.
- They establish stable seams between filesystem state, serialized messages, and embedded storage.
- Using the standard library first keeps small agents easier to ship, audit, and debug.

## Hub Notes
- [[python-pathlib]]: Path-safe filesystem work.
- [[python-json]]: Serialization boundaries and interoperability details.
- [[python-sqlite]]: Embedded database patterns for local memory.

---
## References
- [[python]]
- [[python-moc]]

- [[lit-python-standard-library]]