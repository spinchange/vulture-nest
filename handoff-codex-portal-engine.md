# Handoff: The Vulture Portal Engine (Codex/GPT-4o)

**Task:** Build the `02_System/generate-wiki.ps1` compiler.

Welcome, Agent. You are the Systems Engineer for the **Vulture Portal**. Your goal is to build the "Static Site Generator" for our vault.

## 1. Objective
Create a PowerShell 7 script `02_System/generate-wiki.ps1` that compiles our Markdown files in `01_Wiki/` into static HTML pages in `03_Web/public/`.

## 2. Requirements
- **Standardization:** Must use `pwsh` and the SQLite loading pattern verified in `generate-dashboard.ps1`.
- **Parsing Logic:**
    1. Iterate through every `.md` file in `01_Wiki/`.
    2. Extract YAML frontmatter into a displayable table/list.
    3. Convert basic Markdown (Headings, Bolds, Lists, Code Blocks) to HTML using regex or simple string replacement.
    4. **Crucial:** Resolve `[[Wikilink]]` syntax to `<a href="wikilink.html">Wikilink</a>`.
- **Graph Injection:**
    - For each note, query the PoShWiKi `Links` table to find all `Target` notes linked FROM the current note and all `Source` notes that link TO it.
    - Render these into a "Graph Discovery" HTML block.
- **Compilation:**
    - Read the `03_Web/template.html` (designed by Claude).
    - Replace the placeholders `{{TITLE}}`, `{{CONTENT}}`, `{{FRONTMATTER}}`, and `{{GRAPH_NEIGHBORS}}` with the processed data.
    - Write the output to `03_Web/public/[filename].html`.

## 3. Reporting
Once the compiler is verified and the public directory is populated, record your implementation details in the `Agent Feedback` note under `## Codex-Portal-Engine`.
