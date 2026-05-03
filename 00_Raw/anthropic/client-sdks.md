<!--
source_url: https://platform.claude.com/docs/en/api/client-sdks
requested_url: https://platform.claude.com/docs/en/api/client-sdks
fetch_date: 2026-05-02T01:27:23.815Z
crawl_job_id: 019deabe-27ae-7404-afb8-696a89cfc0e1
source_page_id: 0094ed90-e205-4a81-857d-dbc93e860aa4
chunk_ids: 2428c571-4f7e-403d-ab32-ba1ce5fe6b21, b4620a28-cee1-4281-a71c-6dbf8a56cef8, 738a18b1-6578-4a1f-8f37-e60090b29969
-->

# Client SDKs - Claude API Docs
Client SDKs

Overview

Copy page

Anthropic provides official client SDKs in multiple languages to make it easier to work with the Claude API. Each SDK provides idiomatic interfaces, type safety, and built-in support for features like streaming, retries, and error handling.

[CLI\\
\\
Shell scripting, typed flags, response transforms](https://platform.claude.com/docs/en/api/sdks/cli) [Python\\
\\
Sync and async clients, Pydantic models](https://platform.claude.com/docs/en/api/sdks/python) [TypeScript\\
\\
Node.js, Deno, Bun, and browser support](https://platform.claude.com/docs/en/api/sdks/typescript) [Java\\
\\
Builder pattern, CompletableFuture async](https://platform.claude.com/docs/en/api/sdks/java) [Go\\
\\
Context-based cancellation, functional options](https://platform.claude.com/docs/en/api/sdks/go) [Ruby\\
\\
Sorbet types, streaming helpers](https://platform.claude.com/docs/en/api/sdks/ruby) [C#\\
\\
.NET Standard 2.0+, IChatClient integration](https://platform.claude.com/docs/en/api/sdks/csharp) [PHP\\
\\
Value objects, builder pattern](https://platform.claude.com/docs/en/api/sdks/php)

## Quick installation

CLI

CLI

Python

Python

TypeScript

TypeScript

C#

C#

Go

Go

Java

Java

PHP

PHP

Ruby

Ruby

```
pip install anthropic
```

## Quick start

CLIPythonTypeScriptC#GoJavaPHPRuby

```
import anthropic

client = anthropic.Anthropic()

message = client.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello, Claude"}],
)
print(message.content)
```

## Platform support

All SDKs support multiple deployment options:

| Platform | Description |
| --- | --- |
| Claude API | Connect directly to Claude API endpoints |
| [Amazon Bedrock](https://platform.claude.com/docs/en/build-with-claude/claude-in-amazon-bedrock) | Use Claude through AWS |
| [Google Vertex AI](https://platform.claude.com/docs/en/build-with-claude/claude-on-vertex-ai) | Use Claude through Google Cloud |
| [Microsoft Foundry](https://platform.claude.com/docs/en/build-with-claude/claude-in-microsoft-foundry) | Use Claude through Microsoft Azure |

See individual SDK pages for platform-specific setup instructions.

## Beta features

Access beta features using the `beta` namespace in any SDK:

CLIPythonTypeScriptC#GoJavaPHPRuby

```
message = client.beta.messages.create(
    model="claude-opus-4-7",
    max_tokens=1024,
    messages=[{"role": "user", "content": "Hello"}],
    betas=["feature-name"],
)
```

See [Beta headers](https://platform.claude.com/docs/en/api/beta-headers) for available beta features.

## Requirements

| SDK | Minimum Version |
| --- | --- |
| Python | 3.9+ |
| TypeScript | 4.9+ (Node.js 20+) |
| Java | 8+ |
| Go | 1.23+ |
| Ruby | 3.2.0+ |
| C# | .NET Standard 2.0 |
| PHP | 8.1.0+ |

## GitHub repositories

- [anthropic-sdk-python](https://github.com/anthropics/anthropic-sdk-python)
- [anthropic-sdk-typescript](https://github.com/anthropics/anthropic-sdk-typescript)
- [anthropic-sdk-java](https://github.com/anthropics/anthropic-sdk-java)
- [anthropic-sdk-go](https://github.com/anthropics/anthropic-sdk-go)
- [anthropic-sdk-ruby](https://github.com/anthropics/anthropic-sdk-ruby)
- [anthropic-sdk-csharp](https://github.com/anthropics/anthropic-sdk-csharp)
- [anthropic-sdk-php](https://github.com/anthropics/anthropic-sdk-php)

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
