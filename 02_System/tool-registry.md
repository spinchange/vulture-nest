# Vault Tool Registry (Agent Optimized)

This document provides a machine-readable index of the system utilities available in this vault.
## audio-overview-workflow.ps1 [-InputFiles] <string[]> [-OutputRoot <string>] [-TranscriptModel <string>] [-Language <string>] [-WaveformVideo] [<CommonParameters>]
*   **File:** `02_System\audio-overview-workflow.ps1` 
*   **Description:** No description provided.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File audio-overview-workflow.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## audit-moc-coverage.ps1
*   **File:** `02_System\audit-moc-coverage.ps1` 
*   **Description:** No description provided.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File audit-moc-coverage.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## YANP Compliance Auditor
*   **File:** `02_System\audit-yanp.ps1` 
*   **Description:** Scans 01_Wiki recursively and validates note filenames plus opening YAML frontmatter structure.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File audit-yanp.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Auto-links semantically related notes using Gemini as the link-direction judge.
*   **File:** `02_System\auto-link.ps1` 
*   **Description:** Loads note embeddings, finds high-similarity unlinked pairs, asks Gemini to decide directionality for each pair, and writes wikilinks directly into the notes. Run sync-vault-graph.ps1 afterwards to update the graph.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File auto-link.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Broken Link Auditor
*   **File:** `02_System\check-broken-links.ps1` 
*   **Description:** Scans markdown files in the vault and reports unresolved wikilinks with source path and line number.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File check-broken-links.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## MCP Config Health Checker
*   **File:** `02_System\check-mcp-health.ps1` 
*   **Description:** Validates configured MCP servers by starting each server from .gemini/settings.json, running protocol initialization, and asserting discovery returns at least one tool. Empty credential-like environment variables are reported as warnings. Live credential checks are opt-in; by default this command performs no external service calls beyond starting the local MCP servers.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File check-mcp-health.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## YANP Note Creator
*   **File:** `02_System\create-yanp-note.ps1` 
*   **Description:** Scaffolds a new YANP-compliant markdown note with valid frontmatter and a kebab-case filename.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File create-yanp-note.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Exports PoShWiKi pages from the active SQLite database into repo-backed markdown snapshots.
*   **File:** `02_System\export-poshwiki-pages.ps1` 
*   **Description:** Reads pages from the active PoShWiKi database and writes each page to 02_System/poshwiki-pages so CI and GitHub Pages can rebuild dashboard/session state from checked-in artifacts.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File export-poshwiki-pages.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## find-thin-nodes.ps1
*   **File:** `02_System\find-thin-nodes.ps1` 
*   **Description:** No description provided.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File find-thin-nodes.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Generates the Vault Pulse dashboard as a standalone HTML file.
*   **File:** `02_System\generate-dashboard.ps1` 
*   **Description:** Builds a single-file dashboard that combines vault health metrics, graph topology, and recent activity from both log.md and the PoShWiKi SQLite database.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File generate-dashboard.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Tool Registry Generator
*   **File:** `02_System\generate-tool-registry.ps1` 
*   **Description:** Scans 02_System/ for .ps1 files, extracts help metadata, and generates a machine-readable tool-registry.md for agents.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File generate-tool-registry.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Vault Stats Generator
*   **File:** `02_System\generate-wiki-stats.ps1` 
*   **Description:** Calculates high-level metrics for the vault, including note counts, link density, and health indicators.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File generate-wiki-stats.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Compiles wiki markdown notes into static HTML pages (Incremental).
*   **File:** `02_System\generate-wiki.ps1` 
*   **Description:** Reads all markdown files in 01_Wiki, extracts YAML frontmatter, converts a supported markdown subset to HTML, resolves wikilinks, injects graph neighbors from the PoShWiKi SQLite database, and writes HTML files into 03_Web/public using 03_Web/template.html.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File generate-wiki.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Installs the Vulture Watcher as a Windows Daemon.
*   **File:** `02_System\install-vulture-daemon.ps1` 
*   **Description:** Registers the watch-wiki.ps1 script as a Windows Scheduled Task that starts automatically when the user logs in.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File install-vulture-daemon.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Creates a dated experiment scaffold under 04_Experiments.
*   **File:** `02_System\new-experiment.ps1` 
*   **Description:** Generates a new experiment directory and pre-fills entry.md with frontmatter and section headings for runs, debates, and evaluations.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File new-experiment.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Orphan Note Checker
*   **File:** `02_System\orphan-check.ps1` 
*   **Description:** Scans markdown notes in 01_Wiki recursively and reports notes with no incoming wikilinks from other vault files.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File orphan-check.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Standardized API wrapper for PoShWiKi.
*   **File:** `02_System\poshwiki-tools.ps1` 
*   **Description:** Provides high-level functions for recording durable thoughts and logs in the PoShWiKi database. This script acts as the "Thought API" for agents to ensure standardized note-taking. Adheres to ps-automation-spec and agent-note-conventions.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File poshwiki-tools.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Reviews Gemini-authored wiki notes with Claude for accuracy and robustness.
*   **File:** `02_System\review-gemini-pages.ps1` 
*   **Description:** Selects notes from 01_Wiki by frontmatter author, optional path list, or git diff scope, then sends each note to Claude for a second-pass review. Produces structured findings on technical accuracy, robustness, graph integration, overclaim risk, and revision priority. DryRun mode shows the candidate set without calling the Anthropic API.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File review-gemini-pages.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Master Vault Maintenance
*   **File:** `02_System\run-maintenance.ps1` 
*   **Description:** The "Knowledge CI/CD" master script. Runs compliance audits, orphan checks, link checks, registry updates, generates the visual dashboard, and compiles the static portal.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File run-maintenance.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Seeds the PoShWiKi Pages table from repo-backed markdown snapshots.
*   **File:** `02_System\seed-poshwiki-pages.ps1` 
*   **Description:** Loads checked-in PoShWiKi page exports from 02_System/poshwiki-pages and writes them into the active wiki.db so CI and fresh workspaces can rebuild the same session/activity context used by the dashboard.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File seed-poshwiki-pages.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Suggests missing wikilinks based on semantic similarity of note embeddings.
*   **File:** `02_System\suggest-links.ps1` 
*   **Description:** Loads all embeddings from NoteEmbeddings, computes pairwise cosine similarity, and surfaces pairs above the similarity threshold that have no existing wikilink in either direction. These are "semantic orphans" — conceptually adjacent notes that are structurally disconnected. Run sync-embeddings.ps1 first.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File suggest-links.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Syncs note embeddings to SQLite using the Gemini text-embedding-004 API.
*   **File:** `02_System\sync-embeddings.ps1` 
*   **Description:** Reads all notes from 01_Wiki/, computes SHA256 hashes for change detection, calls the Gemini batch embedding API for new or changed notes, and stores vectors as JSON in the NoteEmbeddings table. Incremental: skips notes whose content hasn't changed since last embedding. Exits 0 gracefully if GEMINI_API_KEY is not set.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File sync-embeddings.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Syncs wikilinks from the vault to the PoShWiKi database (Optimized).
*   **File:** `02_System\sync-vault-graph.ps1` 
*   **Description:** Refactored for performance using a single transaction and prepared statements. Parses all Markdown files in 01_Wiki/ for wikilinks and stores the relationship graph in the 'Links' table of the SQLite database.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File sync-vault-graph.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Tier-2 compliance auditor for PowerShell automation scripts.
*   **File:** `02_System\test-tier-compliance.ps1` 
*   **Description:** Scans all 02_System/*.ps1 files and checks whether each script sets $ErrorActionPreference = 'Stop' and contains a try/catch block.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File test-tier-compliance.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Elicits tail-distribution knowledge from Claude via Mode-Anchored Departure (Idea 3, Approach B).
*   **File:** `02_System\verbalized-sampling.ps1` 
*   **Description:** Two-call pipeline: Call 1 — Claude names its modal response (the most probable default), then enumerates 9 departures ranked by departure distance from that anchor, each with a verbalized P(%). The modal anchor is what makes this Approach B: departures are measured against an explicit reference point, not inferred from rank order alone. Call 2 — Tail departures (ranks TailStart–9) plus the modal are submitted as context for a synthesis pass that produces a response the modal would not contain. ParseWarning is set on: missing modal block, fewer than 9 ranks, rank-9 modal collapse, or Call 2 reversion (synthesis token-overlap with modal above threshold).
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File verbalized-sampling.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## The Vulture Engine: Graph-Aware Discovery (Optimized & Ranked)
*   **File:** `02_System\vulture-search.ps1` 
*   **Description:** A specialized retrieval engine that uses a weighted ranking model to surface relevant knowledge and tools. Leverages the PoShWiKi graph for second-order discovery.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File vulture-search.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Vulture Watchdog: Debounced Recompiler
*   **File:** `02_System\watch-wiki.ps1` 
*   **Description:** Monitors 01_Wiki/ for changes and triggers a graph sync and portal compilation. Uses a debounced FileSystemWatcher to prevent redundant builds during save bursts.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File watch-wiki.ps1` 
*   **Inputs:** None
*   **Outputs:** None

---
*Generated by generate-tool-registry.ps1 on 2026-05-19 23:28:24*
