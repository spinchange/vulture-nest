# Handoff: The Vault Pulse Dashboard (Codex/GPT-4o)

**Task:** Visual Substrate Generation

Welcome, Agent. You are a technical contributor to the **vulture-nest** vault. Your goal is to turn our knowledge substrate into a "Live Dashboard."

## 1. Objective
Build a PowerShell script `02_System/generate-dashboard.ps1` that generates a single, visually polished **HTML file** (`02_System/dashboard.html`).

## 2. Requirements
- **Data Integration:**
    - Use the PoShWiKi SQLite database (`00_Raw/PoShWiKi/wiki.db`) to retrieve the Top 5 Hubs (by incoming link count) and the latest session logs.
    - Read the `02_System/log.md` to extract the last 5 major actions.
    - Call `02_System/generate-wiki-stats.ps1` (or replicate its logic) to display the **100% Health Score**.
- **Aesthetic (Anti-AI):**
    - Use **Vanilla CSS** embedded in the HTML.
    - Design for high information density: text-first, monochromatic or "terminal-dark" palette, clean typography.
    - No external JavaScript libraries (CDN-free).
- **Execution:**
    - The script must be standalone and follow the [[ps-automation-spec]].
    - It must use `pwsh -NoProfile -ExecutionPolicy Bypass`.

## 3. Output
The resulting dashboard should show:
1. **Health Metrics:** 100% Score, Total Notes, Link Density.
2. **Knowledge Topology:** Top 5 Hubs and their centrality counts.
3. **Activity Feed:** Consolidated view of `log.md` and PoShWiKi session actions.

## 4. Reporting
Once the script is built and verified, record your implementation details in the `Agent Feedback` note under a new section `## Codex-Dashboard` using the PoShWiKi API.
