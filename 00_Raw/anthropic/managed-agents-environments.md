<!--
source_url: https://platform.claude.com/docs/en/managed-agents/environments
requested_url: https://platform.claude.com/docs/en/managed-agents/environments
fetch_date: 2026-05-02T05:32:12.028Z
crawl_job_id: 019dec06-6383-7607-94cf-8606fcb85d14
source_page_id: 6c3121af-585b-452a-9af1-574b81d1fb1e
chunk_ids: 8afbd1fa-09fd-4582-9a06-60b49001e81e, 1738771c-e798-41c1-9638-809be4ee1dce, b4c5a488-8c0d-4217-b8d3-d61b90b8bbca, 0bb61392-1770-45b0-adfd-1e78d8079b51
-->

# Cloud environment setup - Claude API Docs
|
|

Managed Agents

Cloud environment setup

Copy page

Environments define the container configuration where your agent runs. You create an environment once, then reference its ID each time you start a session. Multiple sessions can share the same environment, but each session gets its own isolated container instance.

All Managed Agents API requests require the `managed-agents-2026-04-01` beta header. The SDK sets the beta header automatically.

## Create an environment

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
ant beta:environments create \
  --name "python-dev" \
  --config '{type: cloud, networking: {type: unrestricted}}'
```

The `name` must be unique within your organization and workspace.

## Use the environment in a session

Pass the environment ID as a string when creating a session.

curlPythonTypeScriptC#GoJavaPHPRuby

```
session = client.beta.sessions.create(
    agent=agent.id,
    environment_id=environment.id,
)
```

## Configuration options

### Packages

The `packages` field pre-installs packages into the container before the agent starts. Packages are installed by their respective package managers and cached across sessions that share the same environment. When multiple package managers are specified, they run in alphabetical order (apt, cargo, gem, go, npm, pip). You can optionally pin specific versions; the default is latest.

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
ant beta:environments create <<'YAML'
name: data-analysis
config:
  type: cloud
  packages:
    pip:
      - pandas
      - numpy
      - scikit-learn
    npm:
      - express
  networking:
    type: unrestricted
YAML
```

Supported package managers:

| Field | Package manager | Example |
| --- | --- | --- |
| `apt` | System packages (apt-get) | `"ffmpeg"` |
| `cargo` | Rust (cargo) | `"ripgrep@14.0.0"` |
| `gem` | Ruby (gem) | `"rails:7.1.0"` |
| `go` | Go modules | `"golang.org/x/tools/cmd/goimports@latest"` |
| `npm` | Node.js (npm) | `"express@4.18.0"` |
| `pip` | Python (pip) | `"pandas==2.2.0"` |

### Networking

The `networking` field controls the container's outbound network access. It does not impact the `web_search` or `web_fetch` tools' allowed domains.

| Mode | Description |
| --- | --- |
| `unrestricted` | Full outbound network access, except for a general safety blocklist. This is the default. |
| `limited` | Restricts container network access to the `allowed_hosts` list. Further access is enabled via the `allow_package_managers` and `allow_mcp_servers` bool. |

curlPythonTypeScriptC#GoJavaPHPRuby

```
config = {
    "type": "cloud",
    "networking": {
        "type": "limited",
        "allowed_hosts": ["api.example.com"],
        "allow_mcp_servers": True,
        "allow_package_managers": True,
    },
}
```

For production deployments, use `limited` networking with an explicit `allowed_hosts` list. Follow the principle of least privilege by granting only the minimum network access your agent requires, and regularly audit your allowed domains.

When using `limited` networking:

- `allowed_hosts` specifies domains the container can reach. These must be HTTPS-prefixed.
- `allow_mcp_servers` permits outbound access to MCP server endpoints configured on the agent, beyond those listed in the `allowed_hosts` array. Defaults to `false`.
- `allow_package_managers` permits outbound access to public package registries (PyPI, npm, etc.) beyond those listed in the `allowed_hosts` array. Defaults to `false`.

## Environment lifecycle

- Environments persist until explicitly archived or deleted.
- Multiple sessions can reference the same environment.
- Each session gets its own container instance. Sessions do not share file system state.
- Environments are not versioned. If you frequently update your environments, you may want to log these updates on your side, to map environment state with sessions.

## Manage environments

curlCLIPythonTypeScriptC#GoJavaPHPRuby

```
# List environments
ant beta:environments list

# Retrieve a specific environment
ant beta:environments retrieve --environment-id "$ENVIRONMENT_ID"

# Archive an environment (read-only, existing sessions continue)
ant beta:environments archive --environment-id "$ENVIRONMENT_ID"

# Delete an environment (only if no sessions reference it)
ant beta:environments delete --environment-id "$ENVIRONMENT_ID"
```

## Pre-installed runtimes

Cloud containers include common runtimes out of the box. See [Container reference](https://platform.claude.com/docs/en/managed-agents/cloud-containers) for the full list of pre-installed languages, databases, and utilities.

Was this page helpful?

Ask Docs
![Chat avatar](https://platform.claude.com/docs/images/book-icon-light.svg)
