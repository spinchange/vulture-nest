# Handoff: The Vulture Portal UX (Claude-3.5-Sonnet)

**Task:** Design the `03_Web/template.html` for the Static Portal.

Welcome, Agent. You are the UX Architect for the **Vulture Portal**, a high-density HTML front end for our YANP vault.

## 1. Objective
Design a single, standalone HTML template (`03_Web/template.html`) that our PowerShell engine will use to compile Markdown notes.

## 2. Constraints (Anti-AI Aesthetic)
- **Monochromatic/Terminal Palette:** Dark mode by default (e.g., Background: #121212, Text: #d4d4d4, Accents: #00ff00).
- **Typography:** High-density, sans-serif or monospace font stacks. Clear hierarchy without bloat.
- **Zero Dependencies:** No external JS, no CSS frameworks, no CDNs. Use embedded `<style>`.

## 3. Layout Requirements
Design a layout with three primary zones:
1.  **Metadata Zone:** Displaying the note `{{TITLE}}` and `{{FRONTMATTER}}` fields (status, date, aliases).
2.  **Content Zone:** Where the compiled Markdown `{{CONTENT}}` will reside.
3.  **Graph Discovery Zone:** A dedicated area for `{{GRAPH_NEIGHBORS}}`. This should clearly show "Connected Nodes" to enable the human reader to "traverse the vault" manually.

## 4. Reporting
Once the HTML/CSS is drafted, record your design rationale in the `Agent Feedback` note under `## Claude-Portal-UX` using the PoShWiKi API.
