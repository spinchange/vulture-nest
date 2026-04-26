---
title: Workbench Integration
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [workbench-usage, investigation-workflow, executable-knowledge]
---

# Workbench Integration
: Leveraging the dynamic execution layer for vault maintenance.

The [[workbench-integration]] (located in `00_Raw/workbench/`) acts as the dynamic counterpart to the wiki's static knowledge. It provides a persistent, auditable environment for repo-aware investigations and "Executable Knowledge" verification.

## 1. The Proof-Round Workflow
The "Proof Round" is the primary mechanism for generating verifiable evidence from a codebase.

- **Action:** Run `node 00_Raw/workbench/dist/cli/main.js --host 00_Raw/workbench/dist/host/node-child-process-runner.js proof --repo <path>`
- **Output:** A JSON artifact that catalogs workspace state, entrypoints, and test health.
- **Leverage:** These artifacts provide the ground truth for [[zettelkasten-note-types|Literature Notes]]. When ingesting a new tool, run a proof round first to validate its claims before committing them to the wiki.

## 2. Thought API + Workbench
By combining the [[poshwiki-tools]] (the "Thought API") with Workbench's JavaScript REPL, agents can log their interactive discovery process in real-time.

### Example Integration Script
```javascript
// .workbenchrc.js
import { execSync } from 'child_process';

global.logThought = (content) => {
    const cmd = `pwsh -ExecutionPolicy Bypass -File 02_System/poshwiki-tools.ps1 -Content "${content}"`;
    execSync(cmd);
};

// Now in the Workbench REPL:
// > logThought("Discovered that vulture-mcp uses sqlx for SQLite.")
```

## 3. Leverage-Maximizing Strategies

### A. Automatic Ingestion
Use Workbench to scan a repository and generate YANP-compliant drafts.
1. Run `workbench eval "await repoAudit()"` to get a structured JSON summary.
2. Use a script to map that JSON to a [[zettelkasten-note-types|Fleeting Note]].
3. Promote to a [[zettelkasten-note-types|Permanent Note]] after human/librarian review.

### B. Verification Loops
Treat wiki notes as "Type-Checked" artifacts.
1. A wiki note for a tool (like [[vulture-mcp]]) should include a **Workbench Script** to verify its health.
2. Run this script during vault maintenance ([[ps-vault-maintenance]]) to ensure the documentation hasn't drifted from the implementation.

### C. Auditable Handoffs
When ending a session, include the Workbench `audit-log.jsonl` in your [[log|System Log]]. This provides the next agent with a "replay" of the discovery logic, reducing re-work and context drift.

---
*See also: [[yanp-for-agentic-workflows]], [[agentic-tdd-patterns]], [[ps-automation-spec]]*
