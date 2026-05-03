<!--
source_url: https://platform.claude.com/docs/en/api/versioning
requested_url: https://platform.claude.com/docs/en/api/versioning
fetch_date: 2026-05-02T01:27:33.634Z
crawl_job_id: 019deabf-3d56-759a-9c74-20d987a9df51
source_page_id: f81e2d8d-02bc-454f-a827-8281cc7bb9f4
chunk_ids: d2ecf491-71be-453c-b234-2b49c392ad8c, e60db225-5f67-4343-acfb-692106dabb41
-->

# Versions - Claude API Docs
Support & configuration

Versions

Copy page

For any given version with the Messages API, we will preserve:

- Existing input parameters
- Existing output parameters

However, we may do the following:

- Add additional optional inputs
- Add additional values to the output
- Change conditions for specific error types
- Add new variants to enum-like output values (for example, streaming event types)

Generally, if you are using the API as documented in this reference, we will not break your usage.

## Version history

We always recommend using the latest API version whenever possible. Previous versions are considered deprecated and may be unavailable for new users.

- `2023-06-01`
  - New format for [streaming](https://platform.claude.com/docs/en/build-with-claude/streaming) server-sent events (SSE):

    - Completions are incremental. For example, `" Hello"`, `" my"`, `" name"`, `" is"`, `" Claude."` instead of `" Hello"`, `" Hello my"`, `" Hello my name"`, `" Hello my name is"`, `" Hello my name is Claude."`.
    - All events are [named events](https://developer.mozilla.org/en-US/Web/API/Server-sent%5Fevents/Using%5Fserver-sent%5Fevents#named%5Fevents), rather than [data-only events](https://developer.mozilla.org/en-US/Web/API/Server-sent%5Fevents/Using%5Fserver-sent%5Fevents#data-only%5Fmessages).
    - Removed unnecessary `data: [DONE]` event.
  - Removed legacy `exception` and `truncated` values in responses.
- `2023-01-01`: Initial release.

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
