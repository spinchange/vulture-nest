---
title: Workbench Codex Runner Handoff
author: codex
date: 2026-04-25
status: active
type: permanent
targets: [gemini]
projects: [workbench, vulture-mcp, poshwiki]
aliases: [codex-runner-handoff, workbench-host-runner-handoff]
---

# Workbench Codex Runner Handoff
: Operational brief for adapting Workbench to the hardened Codex environment.

## Objective
Replace Workbench's `child_process` shell host with a Codex-native runner and make proof rounds compatible with the hardened environment.

## Verified Facts
- `node-child-process-runner` fails in this environment with `spawn EPERM`.
- A new runner was added at `00_Raw/workbench/src/host/codex-tool-runner.ts`.
- The new runner wraps `codex.tool("shell_command", ...)`.
- Workbench rebuilds successfully with `npm run build`.
- Direct runner contract tests pass in-process via `node --input-type=module -e "import './dist-test/tests/codex-tool-runner.test.js'"`.
- A proof artifact was produced at `00_Raw/workbench/proof-vulture-mcp-codex-runner.json`.
- Standalone CLI invocation still lacks a live `codex.tool` global and now fails explicitly with `codex.tool is not available in this runtime`.
- The `vulture-mcp` proof flow succeeds through the new host path when a Codex-compatible host is present; the remaining proof warning is the expected `no package.json` / no deterministic JS test path for this [[rust]] repo.

## Constraints
- Plain terminal-launched `node` does not automatically have access to `codex.tool`.
- Node's built-in test runner appears to hit the same hardened spawn restriction in this environment.
- `vulture-mcp` is a Rust repo with no `package.json`, so Workbench proof rounds warn on `testOrExplain()` by design.
- Workbench defaults that write outside the vault are fragile under the hardened environment; vault-local artifact paths are safer.

## Recommended Improvements
- Add a Codex-native Workbench entrypoint that injects a live `codex` global before loading the CLI.
- Make vault-local proof artifact output the default instead of `~/.workbench`.
- Add machine-readable runtime metadata for each tool and runner.
- Create a single session-resume command that returns Seam + recent log + relevant artifacts.
- Separate environment facts from design guidance in future handoffs using the same structure as this note.

## Evidence
- `00_Raw/workbench/src/host/codex-tool-runner.ts`
- `00_Raw/workbench/tests/codex-tool-runner.test.ts`
- `00_Raw/workbench/proof-vulture-mcp-codex-runner.json`
- `02_System/log.md`
- `Session 2026-04-25` (PoShWiKi session page)

## Next Decision
Should Workbench be adapted around:
1. a Codex-native JS entrypoint, or
2. a host abstraction that supports both Codex and standalone Node cleanly?

## Runtime Constraints
```yaml
runtime_constraints:
  shell_spawn_in_node: false
  codex_tool_available_in_terminal_node: false
  pwsh_available: true
  vault_local_artifacts_required: true

verification:
  workbench_build: pass
  codex_runner_contract_test: pass
  standalone_cli_with_codex_runner: fail_expected
  vulture_mcp_proof_via_codex_compatible_host: pass
```

---
*See also: [[workbench-integration]], [[openai-js-repl-integration]], [[ps-automation-spec]]*

