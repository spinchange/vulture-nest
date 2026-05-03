---
title: Anthropic Files API
author: claude-sonnet-4-6
date: "2026-05-02"
status: active
type: permanent
aliases:
  - claude-files-api
  - anthropic-file-upload
source: "[[lit-anthropic-async-data-apis]]"
---

# Anthropic Files API

The **Files API** is a persistent file store for the Claude API. The core pattern is upload-once, reference-many-times: files are stored in your Anthropic workspace and referenced by `file_id` across multiple API calls rather than re-uploaded as base64 each time.

Currently in beta. Requires the `anthropic-beta: files-api-2025-04-14` header. Not available on Amazon Bedrock or Google Vertex AI.

## Use Cases

- Reuse large documents (PDFs, long text) across many inference calls without repeated encoding.
- Provide inputs to the code execution tool (datasets, images) and retrieve its outputs.
- Decouple document ingestion from inference in multi-step pipelines.

## Content Types and Block Mapping

| File Type | MIME Type | Content Block | Supported By |
|---|---|---|---|
| PDF | `application/pdf` | `document` | All Claude 3.5+ models |
| Plain text | `text/plain` | `document` | All Claude 3+ models |
| Images | `image/jpeg`, `image/png`, `image/gif`, `image/webp` | `image` | All Claude 3+ models |
| Datasets / other | Varies | `container_upload` | Code execution tool (Haiku 4.5, Claude 3.7+) |

## Upload and Reference Pattern

```python
# Upload once
uploaded = client.beta.files.upload(
    file=("document.pdf", open("/path/to/document.pdf", "rb"), "application/pdf"),
)
file_id = uploaded.id

# Reference in messages
response = client.beta.messages.create(
    model="claude-opus-4-6",
    max_tokens=1024,
    messages=[{
        "role": "user",
        "content": [
            {"type": "text", "text": "Summarize this document."},
            {
                "type": "document",
                "source": {"type": "file", "file_id": file_id},
            },
        ],
    }],
    betas=["files-api-2025-04-14"],
)
```

For images, use `"type": "image"` instead of `"document"`.

## Document Block Options

```json
{
  "type": "document",
  "source": {"type": "file", "file_id": "file_011CNha..."},
  "title": "Optional title",
  "context": "Optional context string",
  "citations": {"enabled": true}
}
```

`title`, `context`, and `citations` are optional and work the same as with inline document blocks.

## Storage Limits

| Limit | Value |
|---|---|
| Max file size | 500 MB per file |
| Total storage | 500 GB per organization |
| Rate limit (beta) | ~100 requests/minute for file API operations |

## Lifecycle

- Files are workspace-scoped: any API key in the same workspace can reference any file.
- Files persist until explicitly deleted.
- Deleted files cannot be recovered.
- Files created by the code execution tool or skills can be downloaded; uploaded files cannot.

```python
# List files
files = client.beta.files.list()

# Delete
client.beta.files.delete(file_id)

# Download (only for tool/skill outputs)
content = client.beta.files.download(file_id)
content.write_to_file("output.csv")
```

## Billing

File management operations (upload, download, list, delete, metadata) are free. File content used in Messages requests is billed as standard input tokens.

## Common Errors

| Error | Cause |
|---|---|
| 404 File not found | Invalid `file_id` or wrong workspace |
| 400 Invalid file type | Content block type doesn't match file (e.g., image file in `document` block) |
| 400 Exceeds context window | File too large for the context window |
| 413 File too large | Exceeds 500 MB limit |
| 403 Storage limit exceeded | Organization at 500 GB cap |

## See also

- [[anthropic-messages-api]]
- [[anthropic-tool-use]]
- [[anthropic-message-batches]]
- [[lit-anthropic-async-data-apis]]
