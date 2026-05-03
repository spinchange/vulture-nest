<!--
source_url: https://platform.claude.com/docs/en/api/beta-headers
requested_url: https://platform.claude.com/docs/en/api/beta-headers
fetch_date: 2026-05-02T01:27:44.228Z
crawl_job_id: 019deac0-168d-723c-a061-c1ee313f8a91
source_page_id: 234f0178-d816-436b-9d87-569f53b558b0
chunk_ids: de3e6ef4-8d5e-4129-b2fc-3b1d30b0029f, f85ec4b5-a5eb-4ea4-bb8b-e8de42551f73, 294a9a46-0fa7-484e-81bb-ec97052ba32e
-->

# Beta headers - Claude API Docs
Using the API

Beta headers

Copy page

Beta headers allow you to access experimental features and new model capabilities before they become part of the standard API.

These features are subject to change and may be modified or removed in future releases.

Beta headers are often used in conjunction with the [beta namespace in the client SDKs](https://platform.claude.com/docs/en/api/client-sdks#beta-namespace-in-client-sdks)

## How to use beta headers

To access beta features, include the `anthropic-beta` header in your API requests:

```
POST /v1/messages
Content-Type: application/json
X-API-Key: YOUR_API_KEY
anthropic-beta: BETA_FEATURE_NAME
```

When using the SDK, you can specify beta headers in the request options:

cURLCLIPythonTypeScript

```
client = Anthropic()

response = client.beta.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello, Claude"}],
    betas=["files-api-2025-04-14"],
)
```

Beta features are experimental and may:

- Have breaking changes with notice
- Be deprecated or removed
- Have different rate limits or pricing
- Not be available in all regions

### Multiple beta features

To use multiple beta features in a single request, include all feature names in the header separated by commas:

```
anthropic-beta: feature1,feature2,feature3
```

### Endpoint-specific headers

Some beta features are scoped to specific endpoints rather than individual request parameters. [Claude Managed Agents](https://platform.claude.com/docs/en/managed-agents/overview) uses a single beta header for all endpoints:

| Endpoints | Beta header |
| --- | --- |
| `/v1/agents`, `/v1/sessions`, `/v1/environments` | `managed-agents-2026-04-01` |

See the [Managed Agents overview](https://platform.claude.com/docs/en/managed-agents/overview) for details.

### Version naming conventions

Beta feature names typically follow the pattern: `feature-name-YYYY-MM-DD`, where the date indicates when the beta version was released. Always use the exact beta feature name as documented.

## Error handling

If you use an invalid or unavailable beta header, you'll receive an error response:

Output

```
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "Unsupported beta header: invalid-beta-name"
  }
}
```

## Getting help

For questions about beta features:

1. Check the documentation for the specific feature
2. Review the [API changelog](https://platform.claude.com/docs/en/api/versioning) for updates
3. Contact support for assistance with production usage

Remember that beta features are provided "as-is" and may not have the same SLA guarantees as stable API features.

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
