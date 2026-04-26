# Vault Tool Registry (Agent Optimized)

This document provides a machine-readable index of the system utilities available in this vault.
## YANP Compliance Auditor
*   **File:** `02_System\audit-yanp.ps1` 
*   **Description:** Scans the 01_Wiki folder to ensure all notes follow the YANP protocol (lowercase kebab-case filenames and valid YAML frontmatter 'type').
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File audit-yanp.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Broken Link Auditor
*   **File:** `02_System\check-broken-links.ps1` 
*   **Description:** Scans all markdown files in the vault to find Wikilinks that point to non-existent notes.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File check-broken-links.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## YANP Note Creator
*   **File:** `02_System\create-yanp-note.ps1` 
*   **Description:** Scaffolds a new YANP-compliant markdown note with valid frontmatter and a kebab-case filename.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File create-yanp-note.ps1` 
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

## Orphan Note Checker
*   **File:** `02_System\orphan-check.ps1` 
*   **Description:** Scans for markdown files in 01_Wiki that have no incoming wikilinks from other notes in the vault.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File orphan-check.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## poshwiki-tools.ps1
*   **File:** `02_System\poshwiki-tools.ps1` 
*   **Description:** No description provided.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File poshwiki-tools.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Master Vault Maintenance
*   **File:** `02_System\run-maintenance.ps1` 
*   **Description:** The "Knowledge CI/CD" master script. Runs compliance audits, orphan checks, link checks, registry updates, generates the visual dashboard, and compiles the static portal.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File run-maintenance.ps1` 
*   **Inputs:** None
*   **Outputs:** None

## Syncs wikilinks from the vault to the PoShWiKi database (Optimized).
*   **File:** `02_System\sync-vault-graph.ps1` 
*   **Description:** Refactored for performance using a single transaction and prepared statements. Parses all Markdown files in 01_Wiki/ for wikilinks and stores the relationship graph in the 'Links' table of the SQLite database.
*   **Command:** `pwsh -NoProfile -ExecutionPolicy Bypass -File sync-vault-graph.ps1` 
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
*Generated by generate-tool-registry.ps1 on 2026-04-25 22:04:19*
