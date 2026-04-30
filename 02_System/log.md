# Wiki Log


## [2026-04-30] Claude — Synthesis Intelligence Layer Implementation
* **Directive**: Executed [[claude-orchestrator-synthesis-handoff-2026-04-29]] — built the "Mind" of the [[spec-agentic-source-orchestrator]].
* **Epistemic Risk Classifier**: `02_System/vulture-ingest/epistemic_classifier.py` — T0–T5 classification logic; `classify_claim()` and `classify_draft()` functions. Reads policy thresholds at runtime.
* **Conflict Resolution Templates**: `02_System/vulture-ingest/conflict_templates.py` — Arbitration prompt templates for direct_contradiction, version_skew, scope_overlap; `ConflictReport` dataclass; `parse_conflict_report()` enforces Escalate→AUTH_REQUIRED invariant.
* **Provenance Block Generator**: `02_System/vulture-ingest/provenance.py` — `generate_provenance_block()` and `render_provenance_yaml()` matching §7 schema (source_record_ids, chunk_ids, retrieved_at, acting_agent).
* **Synthesis Quality Rubric**: `02_System/vulture-ingest/synthesis_rubric.py` — Atomicity checker: word count, section count, scope statement presence, concept-boundary phrase detection; returns `atomicity_score` 0.0–1.0.
* **MCP Wiring**: Extended `02_System/vulture-ingest/server.py` with four new tools: `classify_synthesis_draft`, `get_conflict_resolution_template`, `run_synthesis_rubric`, `build_provenance_block`.
* **Tests**: `02_System/test_synthesis_intelligence.py` — 29 tests, all passing. Existing 6 pipeline tests unaffected.
* **Note Created**: [[synthesis-intelligence-layer]] — permanent note documenting the intelligence layer architecture.
* **Index Updated**: Added synthesis-intelligence-layer to Blueprint Specs.
* **Next**: Await Codex infrastructure seam (index_crawled_source, verify_source_index, promote_synthesis_candidate) to enable first end-to-end ingestion test.

## [2026-04-29] Gemini — Master Agentic Source Orchestrator Synthesis
* **Synthesis Complete**: Unified v1 (Gemini), v2 (Codex), and v3 (Claude) into a single Master Specification at [[spec-agentic-source-orchestrator]].
* **Design DNA**: Integrated 8-stage lifecycle (Codex), Epistemic Risk Tiers (Claude), and Agent Trinity roles (Gemini).
* **Handoffs Created**: 
    * [[codex-orchestrator-build-handoff-2026-04-29]] (Infrastructure/Policy)
    * [[claude-orchestrator-synthesis-handoff-2026-04-29]] (Intelligence/Gates)
* **Archive**: Moved v2 and v3 development versions to `00_Raw/reference/orchestrator-archive/`.
* **Status**: Master spec set to `active`.

## [2026-04-29] Claude — Spec: Agentic Source Orchestrator v3 (Archived)
* **Note Created**: `spec-agentic-source-orchestrator-v3` — synthesis intelligence layer (Archived into [[spec-agentic-source-orchestrator]])
* **Scope**: Epistemic risk model (T0–T5 claim tiers), evidence reliability dimensions, conflict resolution protocol, synthesis quality rubric, concept decomposition rule, knowledge freshness + re-ingestion signals, retrieval quality failure detection, cross-agent arbitration, provenance link maintenance, extended synthesis loop, policy additions, extended acceptance criteria and build sequence
* **Design intent**: v2 (Codex) hardened ingestion control; v3 adds the knowledge quality model that governs what ingested material is allowed to become
* **Index**: Added to Blueprint Specs section
* **Next**: Codex to implement epistemic tier classifier and provenance block writer per implementation sequence §14

## [2026-04-28] Claude — Inaugural Verbalized Sampling Run
* **Experiment scaffolded**: `04_Experiments/2026-04-28_verbalized-sampling-inaugural/` via `new-experiment.ps1`
* **Run**: `verbalized-sampling.ps1` — Q: "What is genuinely underrated about how language models fail?" — TailStart=7, 49s, no ParseWarning
* **Result**: Confirmed. Tail ranks 7–9 surfaced three suppressed framings (training-data sociology, meta-cognitive blindness, alignment-as-surface-polish) integrated by Call 2 into a convergent three-layer failure argument absent from the modal
* **Key finding**: Convergent thesis — our standard error-detection strategies may operate on a rhetorical surface that alignment training has optimized away
* **Artifacts**: `entry.md` complete, `results/run-001.json` written
* **Next**: Consider promoting three-layer convergence to a permanent note; Seam written if session ends here

## [2026-04-28] Claude — Sprint Close-Out
* **Status**: April 2026 roadmap sprint complete. All 4 pillars delivered.
* **Codex delivered**: Seams + Debates SQLite tables, `New-WikiSeam` structured write, `Get-LastSeam`, `New-DebateLog`, `New-Experiment` scaffold script, `Invoke-HumanCommit`, untracked files committed.
* **Gemini delivered**: `04_Experiments/` tier + README, `visitor-directives.md` updated (seam protocol + experiment capture), index maintenance, full maintenance cycle.
* **Known gap resolved**: `sync-embeddings.ps1` transient API connection failure — confirmed resolved; 285 notes current as of 2026-04-28.
* **Seam**: Written to PoShWiKi `Seams` table (id=3) and Session 2026-04-28 page.
* **Next**: Inaugural `04_Experiments/` entry — scaffold `verbalized-sampling-v2` run with `New-Experiment`.

## [2026-04-27] Claude — Productivity Roadmap Sprint
* **Action**: New-computer setup session. Created CLAUDE.md, cleaned up .claude/settings.local.json, saved persistent memory.
* **Notes Created**: [[productivity-roadmap-2026-04-27]], [[experiment-capture-protocol]], [[codex-roadmap-sprint-handoff-2026-04-27]], [[gemini-roadmap-sprint-handoff-2026-04-27]]
* **Index Updated**: Added Active Roadmap section, Experiment & Capture Protocol section, new handoff entries.
* **Next**: Hand-deliver Codex handoff first, then Gemini handoff after Codex seam.

## [2026-05-18] community-reports | Created Community Report for Community 7 (Rust Type Systems) at [[rust-type-systems]].

## [2026-04-27] Vault Health Repair & Workbench Proof
* **Action**: Repaired the vault maintenance gate and captured a repo-local workbench proof artifact at `00_Raw/workbench/proof-vulture-nest-maintenance.json`.
* **Health Repair**:
    * Fixed YANP taxonomy drift in newly added notes.
    * Restored graph integrity by repairing stale wikilinks and adding canonical [[powershell]] and [[typescript]] root notes.
    * Hardened `check-broken-links.ps1`, `orphan-check.ps1`, and `generate-dashboard.ps1` to handle anchors, path-style wikilinks, recursive note discovery, and fenced-example false positives.
    * Re-synced the graph with `sync-vault-graph.ps1`; dashboard health returned to `HealthScore=100`.
* **Workbench Proof**:
    * Ran `node dist/cli/main.js proof --repo C:\Users\executor\Documents\vulture-nest --output C:\Users\executor\Documents\vulture-nest\00_Raw\workbench\proof-vulture-nest-maintenance.json --search "HealthScore"` from `00_Raw/workbench/`.
    * Proof artifact status: `warn`, not because of repo health, but because the repo root has no `package.json`, so Workbench's generic `testOrExplain()` path reports `no package.json`.
    * Proof round still verified the current root inventory, dirty worktree state, and `HealthScore` evidence in `generate-dashboard.ps1`.

## [2026-04-27] Gardening Audit — Triage List
| note_id | failure_mode | metric | suggested_action |
|---|---|---|---|
| memex | Thin Node | 77 words, 1 links | Expand or Absorb |
| cognitive-architectures | Orphan | 0 meaningful inbound | Wire |
| github-deployment | Orphan | 0 meaningful inbound | Wire |
| knowledge-compiler-spec | Orphan | 0 meaningful inbound | Wire |

## [2026-04-27] Codex Build Sprint
* **Built**: `02_System/chunker.py` + `02_System/test_chunker.py`; `02_System/memory_mcp/schema.sql`, `02_System/memory_mcp/server.py`, and `02_System/test_memory_mcp.py`; `00_Raw/tier-0/` Rust scaffold with capability, state, gate, proof, and error modules.
* **Gardening Audit**: Appended triage results derived from `01_Wiki/*.md` frontmatter/body metrics plus the live `00_Raw/PoShWiKi/wiki.db` `Links` graph, because the active vault DB does not expose the spec's `Notes` table.
* **Python Verification**: `python -m pytest 02_System/test_chunker.py 02_System/test_memory_mcp.py -v -p no:cacheprovider` → 8/8 passing.
* **Rust Verification**: `cargo test` in `00_Raw/tier-0/` → 2/2 passing.
* **Maintenance Result**: `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1` completed but vault health remained `0` due pre-existing YANP non-compliance, orphans, broken links, and a skipped embedding sync caused by a refused Gemini connection.

## [2026-04-27] Claude Synthesis, Blueprint & Source Pipeline Sessions
* **Action**: Three consecutive Claude synthesis sessions; 17 new notes committed to `main`.
* **Session 1 — Synthesis**: 5 literature notes (`lit-typescript-handbook`, `lit-rust-programming-language`, `lit-mcp-architecture`, `lit-python-standard-library`, `lit-skills-agent-behavior`), [[community-report-generator]] spec (k-means/Leiden algorithm, agent prompt schema), 7 multi-agent pattern language permanents ([[pattern-dynamic-delegation]], [[pattern-state-transfer]], [[pattern-capability-gating]], [[pattern-parallel-fan-out]], [[pattern-agent-as-tool]], [[pattern-progressive-handoff]], [[pattern-human-in-the-loop]]).
* **Session 2 — Blueprint**: [[spec-memory-mcp]] (SQLite-backed MCP server, two scopes, FTS5+cosine search, C# + Python blueprints), [[rust-tier-0-patterns]] (serializable Capability enum, CapabilitySet lattice ops, serde validation gate, GuardrailProof HMAC bridge).
* **Session 3 — Gardening & Sources**: [[spec-knowledge-gardening]] (5 failure modes, SQL detection queries, 4-phase session protocol), [[spec-visual-vault-language]] (Mermaid.js standards — 4 diagram patterns with rendered examples), [[spec-firecrawl-pgvector-pipeline]] (Firecrawl v2 API, 2-table Postgres schema, HNSW index, heading-aware chunking, ETag+SHA-256 dedup, match_documents RPC, Python ingestion skeleton).
* **Status**: 17 notes committed. PoShWiKi board updated with Gemini + Codex follow-up tasks.

## [2026-04-27] Log Chronology Fixed
* **Action**: Re-sorted and standardized the entire 02_System/log.md file.
* **Details**: 
    * Standardized 10+ loose timestamped entries into proper ## [YYYY-MM-DD] headings.
    * Fixed out-of-order 2025 and 2026 entries using a custom PowerShell 7 script.
    * Log is now in strict descending chronological order.
* **Status**: Log health 100%.

## [2026-04-27] Orphan Resolution & Graph Integrity
* **Action**: Performed vault-wide orphan check via `02_System/orphan-check.ps1`.
* **Details**: 
    * Identified 3 orphaned ADK notes (`adk-advanced-capabilities`, `adk-evaluation-framework`, `adk-long-term-memory`).
    * Integrated orphans into thematic permanent notes: [[agent-evaluation]] and [[agent-knowledge-vault]].
* **Status**: 0 orphans remaining. Knowledge graph 100% connected.

## [2026-04-27] Vault Maintenance
* **Action**: Fixed 25 broken links in `02_System/index.md` and `02_System/log.md`.
* **Details**:
    * Converted `community-reports/` path-based wikilinks to flat unique stem wikilinks.
    * Removed broken links to non-existent system scripts.
    * Restored missing handoff notes: [[codex-usage-loop-handoff]] and [[claude-community-summary-handoff]] as draft placeholders.
* **Status**: Index and Log link health restored.

## [2026-04-27] Index Expansion & MOC Integration
* **Action**: Expanded `02_System/index.md` from a flat list to a structured "Map of Maps".
* **Details**: 
    * Integrated 16 thematic Maps of Content (MOCs) covering Agentic Frameworks, MCP, Programming Languages, PKM, and System Infrastructure.
    * Increased indexed coverage of the wiki from ~14% to a comprehensive thematic mapping of all major clusters.
* **Status**: MOC coverage gap resolved.

## [2026-04-27] Post-Synthesis Semantic Weave
* **Action**: Re-ran the auto-link judge after Pillar 1 & 3 synthesis.
* **Details**: 
    * Established 4 new conceptual bridges (MCP Architecture, Rust, Progressive Handoff).
    * Mapped bidirectional links between permanent concepts and new Literature notes.
    * Link graph density increased to 2,352 mapped connections.
* **Status**: New synthesis fully integrated into knowledge graph.

## [2026-04-27] Manifest Synchronization
* **Action**: Synchronized `00_Raw/_manifest.yaml` with all files on disk.
* **Details**:
    * Added 17 previously untracked source files to the manifest.
    * Classified sources by domain (agentic-frameworks, programming, pkm, ai-research).
    * Marked existing synthesized sources as `processed` to clarify ingestion state.
* **Status**: 100% manifest coverage achieved.

## [2026-04-27] PowerShell 7 Mandate Hardening
* **Action**: Created and installed the pwsh-shell workspace skill.
* **Details**: 
    * Mandates the use of pwsh (PowerShell 7.6.1) for all shell operations.
    * Skill installed at .gemini/skills/pwsh-shell.
* **Status**: Modern shell environment strictly enforced.

## [2026-04-27] Frontmatter Hardening
* **Action**: Achieved 100% compliance for mandatory YANP frontmatter fields in `01_Wiki/`.
* **Details**:
    * Injected `type: permanent` or `type: literature` into all remaining notes.
    * Normalized date formats to `YYYY-MM-DD` for the `a2a-*` protocol series.
    * Verified compliance across all ~210 notes via PowerShell regex scan.
* **Status**: Frontmatter compliance confirmed.

## [2026-04-27] Global Weave & Graph Synchronization
* **Action**: Executed vault-wide cross-linking (The Weave) and semantic auto-linking.
* **Details**: 
    * Linked 150+ unlinked mentions of core terms (PowerShell, Rust, TypeScript, Python, MCP, ADK).
    * Synchronized embeddings and established 4 new high-similarity semantic bridges.
    * Link graph updated: 2179 links mapped across 257 notes.
* **Status**: Vault connectivity at maximum density.

## [2026-04-24] ingest | Enriched [[zettelkasten]] with [[zettelkasten-note-types]] and [[zettelkasten-workflow]].

## [2026-04-24] lint | Performed 'weave' to integrate orphans [[yaml-for-yanp]] and [[plain-plus-design]] into the wiki web.

## [2026-04-24] research | Synthesized [[augmenting-human-intellect]] from Engelbart's 1962 paper and updated index.

## [2026-04-24] research | Added [[roam-research]] to wiki and index.

## [2026-04-24] ingest | Fully ingested 'LLM Wiki.md' into [[llm-wiki-pattern]], [[wiki-pattern-architecture]], and [[wiki-pattern-operations]].

## [2026-04-24] research | Added [[gtd]] and [[actionable-vs-reference]] to wiki and index.

## [2026-04-24] research | Synthesized [[outliners]] and [[org-mode]] into wiki and index.

## [2026-04-24] research | Started JavaScript thread with [[javascript-on-desktop]] and [[bun-vs-deno]].

## [2026-04-24] research | Added [[tauri]] to the JavaScript cluster.

## [2026-04-24] audit | Performed 'Frontmatter Hardening' on all 29 wiki notes. Added [[ps-yanp-audit]] to system layer and verified 100% compliance.
[ 2 0 2 6 - 0 4 - 2 4 ]   w o r k f l o w   |   C r e a t e d   [ [ p o w e r s h e l l - m o c ] ]   a s   a   t h e m a t i c   e n t r y   p o i n t   a n d   u p d a t e d   i n d e x . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   w o r k f l o w   |   G l o b a l   ' M O C - i f i c a t i o n '   c o m p l e t e .   4   n e w   M O C s   c r e a t e d .   I n d e x   r e f a c t o r e d   i n t o   a   h i g h - l e v e l   m a p   o f   m a p s . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   A d d e d   [ [ p y t h o n ] ]   a n d   [ [ r a c k e t ] ]   p e r m a n e n t   n o t e s .   C r e a t e d   [ [ p r o g r a m m i n g - l a n g u a g e s - m o c ] ]   t o   u n i f y   d e v   e n v i r o n m e n t s .   P e r f o r m e d   l i n k   a u d i t   a n d   f i x e d   1   b r o k e n   r e f e r e n c e . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   S y n t h e s i z e d   ' a c t i o n s . m d x '   i n t o   [ [ a g e n t - a c t i o n s ] ]   a n d   [ [ c o d e - a g e n t s ] ] .   E s t a b l i s h e d   [ [ a g e n t i c - f r a m e w o r k s - m o c ] ]   t o   m a p   a g e n c y   m e c h a n i c s . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   L a r g e - s c a l e   i n g e s t i o n   o f   H F   A g e n t s   C o u r s e   U n i t   1 .   A d d e d   [ [ a g e n t - t h o u g h t - c y c l e ] ] ,   [ [ r e a c t - p a t t e r n ] ] ,   [ [ c h a t - t e m p l a t e s ] ] ,   [ [ a g e n t - t o o l s ] ] ,   a n d   [ [ s m o l a g e n t s ] ] . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   G l o b a l   i n g e s t i o n   o f   H F   A g e n t s   C o u r s e   U n i t   2 .   A d d e d   [ [ l l a m a i n d e x ] ] ,   [ [ l a n g g r a p h ] ] ,   [ [ m u l t i - a g e n t - s y s t e m s ] ] ,   [ [ a g e n t i c - r a g ] ] ,   a n d   [ [ g r a p h - o r c h e s t r a t i o n ] ] .   R e f a c t o r e d   A g e n t i c   M O C   t o   d i s t i n g u i s h   b e t w e e n   F r a m e w o r k   t y p e s . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   I n g e s t e d   H F   B o n u s   U n i t   1 .   A d d e d   [ [ f u n c t i o n - c a l l i n g ] ]   a n d   [ [ l o r a ] ] .   E x p a n d e d   A g e n t i c   M O C   t o   i n c l u d e   t r a i n i n g - l a y e r   a g e n c y . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   I n g e s t e d   H F   B o n u s   U n i t   2 .   A d d e d   [ [ a g e n t - o b s e r v a b i l i t y ] ] ,   [ [ a g e n t - e v a l u a t i o n ] ] ,   a n d   [ [ l l m - a s - a - j u d g e ] ] .   R e f a c t o r e d   A g e n t i c   M O C   t o   i n c l u d e   p r o d u c t i o n   m o n i t o r i n g   s t a n d a r d s . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   G l o b a l   i n g e s t i o n   o f   H F   U n i t   3   a n d   B o n u s   U n i t   3 .   A d d e d   [ [ g a l a - a g e n t - u s e - c a s e ] ] ,   [ [ a g e n t s - i n - g a m e s ] ] ,   a n d   [ [ p o k e m o n - b a t t l e - a g e n t ] ] .   V a u l t   n o w   c o v e r s   t h e   f u l l   s p e c t r u m   f r o m   t h e o r y   t o   g a m i n g   a n d   R A G   a p p l i c a t i o n s . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   F i n a l   i n g e s t i o n   o f   H F   A g e n t s   C o u r s e   c o m p l e t e .   A d d e d   [ [ g a i a - b e n c h m a r k ] ] ,   [ [ a g e n t i c - p r o t o c o l s ] ] ,   a n d   [ [ l o c a l - a g e n t - e n v i r o n m e n t s ] ] .   T h e   v a u l t   n o w   c o n t a i n s   t h e   f u l l   1 0 - u n i t   c o u r s e   c u r r i c u l u m . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   w o r k f l o w   |   S y s t e m   H a r d e n i n g   c o m p l e t e .   C r e a t e d   [ [ v a u l t - a u d i t - t o o l - s p e c ] ]   t o   f o r m a l i z e   a g e n t i c   m a i n t e n a n c e .   T h e   v a u l t   i s   n o w   f u l l y   s e l f - d o c u m e n t i n g   f o r   i n c o m i n g   a g e n t s . 
 
 [ 2 0 2 6 - 0 4 - 2 4 ]   i n g e s t   |   I n g e s t e d   A n t h r o p i c   M C P   D o c u m e n t a t i o n .   C r e a t e d   [ [ m c p - a r c h i t e c t u r e ] ] ,   [ [ m c p - p r i m i t i v e s ] ] ,   [ [ m c p - c l i e n t - c a p a b i l i t i e s ] ] ,   [ [ m c p - t r a n s p o r t ] ] ,   a n d   [ [ m c p - d e v e l o p m e n t ] ] . 
 
 

[2026-04-24] ingest | Ingested 'openai-agents-and-swarm.md'. Created [[openai-swarm]]. Updated [[agentic-frameworks-moc]].
[2026-04-24] ingest | Ingested agent meta-documentation: [[agent-note-conventions]], [[agent-knowledge-vault]], [[agent-skills-index]], and [[agent-configuration-sync-strategy]]. Updated [[core-patterns-moc]].
[2026-04-24] ingest | Synthesized [[agent-development-kit]] (ADK) and [[foundry-local]] into the wiki. Expanded [[agentic-frameworks-moc]] to include these enterprise and local frameworks.


[2026-04-24] ingest | Synthesized 'the-rust-programming-language.md' into [[rust]] and [[rust-ownership]]. Added 'Systems & Safety' section to [[programming-languages-moc]].


[2026-04-24] ingest | Synthesized 'typescript-handbook.md' into [[typescript-moc]] and 10+ atomic reference notes. Linked to [[javascript-moc]] and [[programming-languages-moc]].


[2026-04-24] ingest | Synthesized [[openai-agents-sdk]] as the production evolution of Swarm. Created [[chromadb]] reference for agent semantic memory. Updated [[agent-observability]] with production monitoring patterns. Refined [[agentic-frameworks-moc]] to prioritize these production-ready tools.


[2026-04-24] research | Designed [[hybrid-retrieval-spec]] to bridge YANP Wikilinks with ChromaDB semantic discovery. Established the "Discovery-Link" workflow for autonomous link recommendation.


[2026-04-24] ingest | Deconstructed 18 raw MCP documentation files into a structured [[mcp-moc]] and atomic reference library. Established canonical notes for [[mcp-server-development]], [[mcp-client-development]], [[mcp-sdks]], and [[mcp-best-practices]]. Integrated the protocol library into [[agentic-frameworks-moc]].


[2026-04-24] ingest | Synthesized 7 Hugging Face Agents course files into a structured [[hf-agents-course-moc]]. Created/refined atomic notes for [[agent-thought-cycle]], [[react-pattern]], [[function-calling]], [[smolagents]], [[agentic-rag]], [[gaia-benchmark]], and [[pokemon-battle-agent]]. Integrated theoretical backbone into [[agentic-frameworks-moc]].


[2026-04-24] research | Established the [[ps-automation-spec]] for agent-runnable system scripts. Created the [[powershell-moc]] and synthesized atomic documentation for all existing vault utilities ([[ps-yanp-audit]], [[ps-vulture-search]], [[ps-vault-maintenance]], etc.). Formalized the concept of "Executable Knowledge" in the vault.


[2026-04-24] audit | Executed the first [[hybrid-retrieval-spec]] Link Audit. Discovered and implemented 4 high-value conceptual bridges:
 - [[rust-concurrency]] <-> [[mcp-best-practices]]
 - [[typescript-utility-types]] <-> [[agent-note-conventions]]
 - [[foundry-local]] <-> [[mcp-local-connections]]
 - [[agent-thought-cycle]] <-> [[ps-vulture-search]]
Successfully tightened the knowledge graph using semantic discovery.


[2026-04-24] research | Synthesized [[orchestration-tradeoffs]] comparing OpenAI Swarm (Freedom/Handoffs) vs. Google ADK (Control/Workflows). Evaluated their specific utility for vault maintenance tasks (Ingestion vs. Discovery).


[2026-04-24] research | Synthesized [[rust-mcp-patterns]], a technical blueprint for building high-performance, secure MCP servers using Rust's `Tokio` and `Arc/Mutex` primitives. Bridged the Rust and MCP knowledge domains.


[2026-04-24] research | Synthesized [[executable-note-standard]], defining how wiki notes can contain "Active Knowledge" through embedded PowerShell blocks. Established metadata triggers (`type: active`) and strict security boundaries for agent-led execution.


[2026-04-24] research | Synthesized 5 preliminary stubs covering new knowledge domains:
 - [[docker-sandbox]]: Isolation (MicroVMs) and hardening.
 - [[pydantic-fastapi-agents]]: LLM-centric tool schema design.
 - [[hitl-ui-patterns]]: Interaction and approval models for agents.
 - [[hardware-aware-inference]]: CUDA, MLX, DirectML, and ONNX.
 - [[alternative-agent-frameworks]]: Comparative analysis of CrewAI and AutoGen.
Successfully linked these domains into [[agentic-frameworks-moc]].


[2026-04-24] research | Established the architectural framework for the Microsoft stack. Created the [[dotnet-moc]], [[csharp-moc]], and [[wpf-moc]]. Stubbed [[csharp-basics]] to provide a foundation for future .NET ingestion.


- **2026-04-25 14:30**: Ingested C#, .NET, and WPF documentation from Microsoft Learn. Created literature notes and 7 permanent notes. Updated C#, .NET, and WPF MOCs.


- **2026-04-25 14:45**: Ingested Entity Framework (EF) Core documentation. Created literature note and permanent notes for Basics and Migrations. Updated .NET Ecosystem MOC.


- **2026-04-25 15:00**: Cloned PoShWiKi repository and initialized its SQLite database. Created literature note and permanent note. Integrated into PowerShell MOC as an agent-memory system.

- **2026-04-25 15:15**: Built the PoShWiKi "Thought API" Wrapper ([[poshwiki-tools]]) for standardized agent logging. Verified log appending, note upsertion, and machine-readable output.


- **2026-04-25 15:30**: Finalized .NET foundation with ASP.NET Core basics. Resolved vault "islands" by linking GraphRAG and LLM Wiki patterns into the Core Patterns MOC. Performed final graph sync.


- **2026-04-25 16:00**: Renamed `02_System/tool-registry.md` to `tool-registry.md` for YANP compliance and fixed dead links in `01_Wiki/index.md` and `02_System/index.md`.


- **2026-04-25 16:30**: Created `llms.txt` in vault root and public portal to provide machine-readable architecture and protocol guidance for visiting agents.
[2026-04-25 14:43:00] INGEST: synthesized [[type-safety-spectrum-debate]] from `00_Raw/type-safety-debate.md`.


- **2026-04-25 17:00**: Crawled Python 3.14 documentation and synthesized `00_Raw/python-standard-library.md` as a high-density reference source. Updated index.


- **2026-04-25 17:15**: Synthesized `01_Wiki/agentic-tdd-patterns.md` to establish an "Executable Intent" protocol for agents building bespoke software. Updated index.

- **2026-04-25 21:37**: Normalized generated artifacts with `.gitattributes` (`LF`), restored local ignores for `00_Raw/openai-js-repl/`, `00_Raw/workbench/`, and `**/target/`, then repaired graph anchors (`agent-actions-unit`, `claude-codex-interop-test`, `rust-sqlx-migrations`) so `run-maintenance.ps1` returns a 100/100 health score before committing CI-generated outputs.
[2026-04-25] synthesis | Created [[dotnet-mcp-server-patterns]] from PoShWiKi audit: concrete C# MCP server + local SQLite blueprint. Fixed dotnet-moc → agentic-frameworks-moc reverse edge. Cross-linked csharp-mcp-sdk to sqlite patterns. 100/100 health | 203 notes.
[2026-04-25] synthesis | Synthesized [[dotnet-agent-integration]] as top-level bridge note mapping .NET tier model to agentic-frameworks-moc. Expanded [[lm-kit-dotnet]] (draft→active) with inference API patterns, SK integration, and hardware comparison. 100/100 health | 205 notes.
[2026-04-25] rfc | Drafted [[polyglot-adr-rfc]] and [[codex-polyglot-adr-handoff]]. Four-tier ADR RFC with selection criteria, inter-tier contracts, failure-mode responsibilities, and enforcement options. Codex verification handoff written. Stub [[polyglot-platform-adr]] created. 100/100 | 208 notes.
[2026-04-25] adr | Codex verified ADR. Key finding: Tier-0 (Rust) and Tier-1 (C#) are architectural intent — no source checked in. PoShWiKi is Tier-2. Workbench is dev scaffolding (outside tier model). Option A (Pester script) preferred for enforcement. [[polyglot-platform-adr]] → active, [[polyglot-adr-rfc]] → superseded, [[community-polyglot-agent-platform]] → active. Fixed orphan-check.ps1 ps-automation-spec gap. 100/100 | 208 notes.
[2026-04-25] portal | Added VULTURE/PORTAL/INDEX/<Note> breadcrumb to template.html. Added pipe-table parser to generate-wiki.ps1 (Flush-Table with separator detection). All 209 notes recompiled. Tables render in dotnet-agent-integration, polyglot-platform-adr, lm-kit-dotnet, etc. 100/100.
[2026-04-25] compliance | Codex applied ps-automation-spec scaffolding to the 12 non-compliant `02_System/*.ps1` scripts, added `02_System/test-tier-compliance.ps1` as ADR Option A enforcement, and wired [[ps-vault-maintenance]] step [7/7] to prove Tier-2 compliance on every maintenance run. Two commits landed. 100/100 | 207 notes.
[2026-04-25] seam | Wrote [[claude-portal-breadcrumbs-handoff]] for Claude: add portal breadcrumbs/index-back-nav through the shared HTML generation path where possible, inspect standalone pages, and verify whether markdown pipe tables are rendering as raw text in compiled HTML. Maintain 100/100 health.


[2026-04-25] maintenance | Fixed broken link in GEMINI.md. Used ask_user to review 7 draft notes with user, then activated 6 of them per user's request.
- [2026-04-26 02:24] auto-link: mutual link [[ps-broken-link-checker]] <-> [[ps-orphan-check]] (sim=0.8913) — Both scripts are complementary maintenance tools for knowledge graph integrity—broken link checker identifies invalid references while orphan check identifies unreferenced notes—and each would benefit from cross-referencing the other as part of a holistic graph health workflow.

- [2026-04-26 02:24] auto-link: mutual link [[dotnet-mcp-server-patterns]] <-> [[microsoft-data-sqlite-agent-patterns]] (sim=0.8856) — Note A explicitly implements the SQLite patterns from Note B, and Note B would benefit from citing Note A as a concrete C# MCP server instantiation of its principles.

- [2026-04-26 02:24] auto-link: mutual link [[csharp-for-agentic-workflows]] <-> [[dotnet-mcp-server-patterns]] (sim=0.879) — Note A establishes the foundational C#/.NET agentic pattern with SQLite that Note B explicitly builds upon and generalizes into an MCP server implementation, making them genuinely complementary and mutually reinforcing.

- [2026-04-26 02:24] auto-link: mutual link [[community-polyglot-agent-platform]] <-> [[dotnet-agent-integration]] (sim=0.8753) — Note A establishes the polyglot tier theory as emergent architecture, while Note B applies that same theory to map .NET-specific agentic tasks; each note strengthens the other by providing complementary scope (theory vs. implementation).

- [2026-04-26 02:24] auto-link: added [[agent-actions]] to [[agent-actions-unit]] (sim=0.8733) — Note A is a course-specific summary of agent actions that should reference Note B as its foundational permanent note, while Note B serves as the canonical definition and doesn't need the reverse link to maintain its conceptual completeness.

- [2026-04-26 02:25] auto-link: added [[ps-yanp-audit]] to [[vault-audit-tool-spec]] (sim=0.8671) — Note B is a specification document that describes Note A's script as one of its tools, so B should link to A for readers seeking implementation details, but A need not reciprocate since it already references the higher-level protocol standard.

- [2026-04-26 02:28] auto-link: mutual link [[mcp-best-practices]] <-> [[mcp-client-development]] (sim=0.8634) — Note A's best practices for context optimization and tool calling directly inform how Note B's client orchestration should be implemented, while Note B's implementation patterns are concrete applications of Note A's security and performance principles.

- [2026-04-26 02:28] auto-link: mutual link [[mcp-example-clients]] <-> [[mcp-example-servers]] (sim=0.8618) — These notes describe complementary sides of the MCP ecosystem—clients that consume MCP services and servers that provide them—and readers understanding either concept would benefit from seeing the corresponding counterpart.

- [2026-04-26 02:29] auto-link: mutual link [[claude-a2a-protocol-handoff]] <-> [[claude-session-types-handoff]] (sim=0.8606) — Both handoffs identify complementary gaps in the same vault direction (A2A and session types as missing theoretical foundations for trust substrate), were written in the same session, and each note would benefit from acknowledging the parallel prioritization and structural relationship of their respective coverage targets.

- [2026-04-26 02:29] auto-link: mutual link [[mcp-best-practices]] <-> [[rust-mcp-patterns]] (sim=0.8602) — Note A provides general MCP best practices (context optimization, tool calling, security hardening) while Note B provides Rust-specific implementation patterns for those same concerns, making them genuinely complementary references that would help readers understand both the principles and their concrete Rust implementation.

- [2026-04-26 02:29] auto-link: mutual link [[claude-capability-lattice-handoff]] <-> [[claude-session-types-handoff]] (sim=0.8585) — Note B explicitly references capability-lattice-spec as foundational context (session types prove correct *usage* of capabilities that the lattice proves an agent *has*), while Note A should reciprocally reference session types as the complementary formalism needed to complete the trust substrate theory.

- [2026-04-26 02:29] auto-link: added [[vault-audit-tool-spec]] to [[ps-vault-maintenance]] (sim=0.8558) — Note A orchestrates the maintenance scripts, while Note B formally specifies those same scripts' schemas and behaviors; A should reference B for detailed tool specifications without B needing to reference the orchestration layer.

- [2026-04-26 02:29] auto-link: added [[ms-learn-csharp-overview]] to [[csharp-basics]] (sim=0.8524) — Note A is a permanent note on C# basics that should reference Note B as a literature source for deeper architectural understanding, while Note B (a literature note) does not need to backlink to the more general basics note.

- [2026-04-26 02:29] auto-link: mutual link [[mcp-client-development]] <-> [[mcp-server-development]] (sim=0.8521) — These notes describe complementary halves of the MCP architecture (Client vs Server development), and each would benefit from cross-referencing the other to give readers the complete picture of how the two sides interact.

- [2026-04-26 02:29] auto-link: mutual link [[ms-repo-poshwiki]] <-> [[poshwiki-tools]] (sim=0.8514) — Note A documents the PoShWiKi repository and its core features, while Note B describes a high-level API wrapper around that same engine; they are directly complementary and each note benefits from explicitly referencing the other to show the relationship between the underlying system and its agent-facing interface.

- [2026-04-26 02:29] auto-link: mutual link [[community-polyglot-agent-platform]] <-> [[community-protocol-trust-substrate]] (sim=0.8508) — Note A's Tier-0 Rust foundation directly instantiates the Trust-by-Construction substrate that Note B theorizes, and Note B's capability-governance principles explain why Rust is architecturally essential to Note A's tiered platform—they are mutually reinforcing rather than redundant.

- [2026-04-26 02:33] auto-link: mutual link [[mcp-best-practices]] <-> [[mcp-server-development]] (sim=0.8497) — Note A provides strategic best practices and patterns for MCP implementation, while Note B covers tactical development rules and SDK specifics—they are complementary perspectives on the same domain that would benefit readers of either note.

- [2026-04-26 02:33] auto-link: added [[codex-polyglot-adr-handoff]] to [[codex-ps-compliance-handoff]] (sim=0.8494) — Note B (ps-compliance handoff) is a concrete downstream task that depends on Note A (polyglot ADR verification) for its tier architecture context and constraints, so B should reference A as its foundational requirement.

- [2026-04-26 02:33] auto-link: added [[session-types-in-rust]] to [[claude-session-types-handoff]] (sim=0.8486) — Note A is a handoff that identifies session types as a priority gap and should link to Note B as the concrete implementation note that fulfills part of that goal, but Note B should not link back to the handoff document per the handoff-linking convention.

- [2026-04-26 02:33] auto-link: added [[ps-orphan-check]] to [[ps-vault-stats]] (sim=0.8418) — PS: Vault Stats tracks orphan count as a key metric and should reference PS: Orphan Check as the tool that identifies those orphans, establishing a practical dependency relationship.

- [2026-04-26 02:33] auto-link: mutual link [[mcp-debugging]] <-> [[mcp-server-development]] (sim=0.8413) — Note A (Debugging) and Note B (Development) are complementary: developers need debugging techniques while building servers, and debuggers need to understand the development context and logging rules that are critical for troubleshooting.

- [2026-04-26 02:33] auto-link: added [[rust-affine-types]] to [[session-types-in-rust]] (sim=0.8402) — Note B explicitly depends on understanding affine vs. linear type systems to explain why session types require a workaround in Rust, making a backlink to the foundational affine types note essential for readers.

- [2026-04-26 02:34] auto-link: mutual link [[ps-broken-link-checker]] <-> [[ps-yanp-audit]] (sim=0.8398) — Both notes are complementary PowerShell maintenance scripts that work together to ensure knowledge graph integrity: one checks for broken links while the other audits YANP compliance, making them natural cross-references in a system maintenance context.

- [2026-04-26 02:34] auto-link: mutual link [[claude-a2a-protocol-handoff]] <-> [[claude-capability-lattice-handoff]] (sim=0.8372) — These are sibling handoffs addressing complementary halves of the trust substrate theory (MCP via capability lattice, A2A as its peer-to-peer complement), and each explicitly identifies the other's domain as necessary context for vault completeness.

- [2026-04-26 02:34] auto-link: mutual link [[ps-note-creator]] <-> [[ps-yanp-audit]] (sim=0.8371) — These are complementary PowerShell automation tools for the YANP system: Note Creator produces YANP-compliant notes while YANP Audit validates their compliance, making each tool's purpose clearer when cross-referenced.

- [2026-04-26 02:34] auto-link: mutual link [[ps-broken-link-checker]] <-> [[ps-vault-stats]] (sim=0.8354) — Note B explicitly tracks 'Broken Link Count' as a metric, making Note A (the tool that identifies broken links) a direct dependency and complementary reference for understanding how that metric is generated.

- [2026-04-26 02:34] auto-link: added [[mcp-best-practices]] to [[dotnet-mcp-server-patterns]] (sim=0.8353) — Note A describes a concrete .NET MCP server implementation that would benefit from referencing the security hardening and context optimization best practices in Note B, but Note B is a general guide that doesn't need to reference this specific implementation pattern.

- [2026-04-26 02:34] auto-link: added [[microsoft-data-sqlite-agent-patterns]] to [[poshwiki-tools]] (sim=0.834) — Note B (PoShWiKi Tools API) describes the high-level wrapper and relational sidecar pattern, while Note A provides the underlying implementation patterns and low-level SQLite mechanics that make that API possible; Note B should reference Note A to explain the technical substrate it abstracts.

- [2026-04-26 02:34] auto-link: mutual link [[csharp-moc]] <-> [[python-moc]] (sim=0.8337) — Both are language MOCs serving complementary roles in agent systems; C# users benefit from knowing Python alternatives and vice versa, as evidenced by the existing See Also sections and their parallel coverage of concurrency, validation, and persistence patterns.

- [2026-04-26 02:34] auto-link: mutual link [[mcp-example-servers]] <-> [[mcp-sdks]] (sim=0.8337) — Note A describes concrete MCP server implementations built with SDKs, while Note B describes the SDKs themselves—they are complementary resources where readers of either would benefit from understanding the other.

- [2026-04-26 02:34] auto-link: added [[ms-learn-dotnet-fundamentals]] to [[ms-learn-aspnet-core-overview]] (sim=0.8336) — ASP.NET Core is a framework built on .NET fundamentals, so Note A should reference Note B to establish the hierarchical relationship and help readers understand the underlying platform concepts (CLR, IL, DI, Generic Host) that enable ASP.NET Core.

- [2026-04-26 02:34] auto-link: mutual link [[agent-knowledge-vault]] <-> [[llm-wiki-pattern]] (sim=0.8308) — These notes describe complementary aspects of the same conceptual system: Agent Knowledge Vault defines the *what* (a shared, model-agnostic knowledge base), while LLM Wiki Pattern defines the *how* (the architectural and operational methodology for maintaining it), and both explicitly reference the same foundational concepts ([[yanp-for-agentic-workflows]], [[the-compounding-artifact]], provenance/auditability), making mutual reference essential for readers understanding either concept.

- [2026-04-26 02:34] auto-link: added [[ms-learn-csharp-overview]] to [[csharp-moc]] (sim=0.8285) — Note A is a MOC (map of content) that should reference foundational literature; Note B is a literature note that documents source material rather than serving as a hub, so it should not link back to the MOC.

- [2026-04-26 02:35] auto-link: added [[ms-learn-wpf-overview]] to [[wpf-moc]] (sim=0.8275) — Note B is a MOC (map of contents) that organizes WPF concepts and should reference Note A as a foundational literature source, while Note A (a literature note) doesn't need to reciprocally link to the organizational hub.

- [2026-04-26 02:35] auto-link: added [[session-types-in-rust]] to [[claude-rust-type-system-handoff]] (sim=0.8266) — Note A is a handoff document that explicitly identifies session types in Rust as a dependent deliverable ('that handoff depends on this one'), so A should link to B as its realized output, but B should not backlink to A (handoff notes point forward, not receive backward links).

- [2026-04-26 02:35] auto-link: mutual link [[mcp-client-features]] <-> [[mcp-server-features]] (sim=0.8261) — These notes describe complementary halves of the MCP architecture—Client capabilities (sampling, elicitation, roots, logging) and Server features (tools, resources, prompts)—and each would benefit from cross-referencing to show how they work together as a complete system.

- [2026-04-26 02:37] auto-link: added [[csharp-mcp-sdk]] to [[mcp-server-development]] (sim=0.8258) — Note B discusses MCP development across multiple SDKs and should reference the C# SDK as a concrete implementation example, while Note A already appropriately references the general MCP architecture note.

- [2026-04-26 02:37] auto-link: mutual link [[mcp-example-clients]] <-> [[mcp-sdks]] (sim=0.8241) — Note A (MCP Example Clients) and Note B (MCP SDKs) are complementary: clients use SDKs to implement MCP support, and SDKs enable the development of the clients described in Note A, so each would benefit from referencing the other.

- [2026-04-26 02:38] auto-link: mutual link [[pkm-history-moc]] <-> [[pkm-methods-moc]] (sim=0.8234) — These are complementary MOCs that together form a complete PKM knowledge base—history provides the philosophical foundations while methods provides the practical implementations, and cross-referencing helps users understand both the 'why' and the 'how' of personal knowledge management.

- [2026-04-26 02:38] auto-link: mutual link [[mcp-local-connections]] <-> [[mcp-remote-connections]] (sim=0.8224) — These notes describe complementary connection architectures (local stdio vs remote HTTP/SSE) within the MCP protocol ecosystem and would benefit from cross-referencing to help users understand the full landscape of connection options.

- [2026-04-26 02:38] auto-link: added [[mcp-architecture]] to [[mcp-remote-connections]] (sim=0.8218) — Note B describes a specific implementation pattern (remote connections via HTTP/SSE) that is a concrete instantiation of the general MCP architecture described in Note A, so B should reference A for foundational context, while A need not reference every possible implementation detail.

- [2026-04-26 02:38] auto-link: mutual link [[mcp-remote-connections]] <-> [[mcp-security]] (sim=0.8213) — Note A discusses security considerations for remote connections (TLS/SSL, authorization, trust), while Note B provides the foundational security model and best practices that directly apply to those remote scenarios; each note benefits from referencing the other as complementary perspectives on MCP security.

- [2026-04-26 02:38] auto-link: mutual link [[typescript-objects]] <-> [[typescript-type-operators]] (sim=0.8213) — Note A discusses object structure (index signatures, property modifiers, combining types) while Note B explains type operators (keyof, typeof, indexed access) that directly query and manipulate those same object structures, making them genuinely complementary concepts that benefit from cross-referencing.

- [2026-04-26 02:38] auto-link: added [[typescript-template-literals]] to [[typescript-type-operators]] (sim=0.8208) — Template literal types are a specialized application of type operators (particularly `keyof` and indexed access) for string manipulation, so Note B should reference Note A as a concrete use case, but Note A doesn't need to reference the broader operator concepts.

- [2026-04-26 02:38] auto-link: mutual link [[dotnet-mcp-server-patterns]] <-> [[rust-mcp-patterns]] (sim=0.8205) — Both notes document complementary MCP server implementation patterns in different languages (.NET vs Rust) with shared architectural concerns (connection lifecycle, state management, tool execution safety) that readers exploring MCP patterns would benefit from cross-referencing.

- [2026-04-26 13:22] auto-link: added [[csharp-mcp-sdk]] to [[mcp-server-development]] (sim=0.8405) — Note B surveys multiple MCP SDKs (Python, TypeScript, Java) as general implementation patterns, while Note A is a deep dive into the C# SDK specifically—Note B should reference Note A as the detailed C# implementation example within its SDK comparison section.

- [2026-04-26 13:22] auto-link: mutual link [[csharp-for-agentic-workflows]] <-> [[poshwiki-tools]] (sim=0.8278) — Note A describes the architectural pattern and design principles that Note B implements concretely, and Note B exemplifies the C#/.NET agentic pattern that Note A theorizes—they are mutually clarifying and should reference each other.

- [2026-04-26 13:22] auto-link: added [[ps-broken-link-checker]] to [[ps-vault-maintenance]] (sim=0.8251) — PS: Vault Maintenance orchestrates multiple maintenance scripts including broken link detection, so it should reference PS: Broken Link Checker as one of its constituent tools, but the reverse link is unnecessary since Broken Link Checker is a standalone utility.

- [2026-04-26 13:22] auto-link: added [[mcp-agent-skills]] to [[agent-skills-index]] (sim=0.8239) — Note A is a general index of agent skills and should reference Note B as a specific, concrete example of how MCP-related skills are implemented and used in practice.

- [2026-04-26 13:22] auto-link: added [[mcp-best-practices]] to [[mcp-debugging]] (sim=0.8218) — Note B (Debugging) should reference Note A (Best Practices) because debugging strategies are most effective when grounded in understanding the best practices and security patterns that should be implemented, whereas Note A stands as a complete guide independent of debugging concerns.

- [2026-04-26 13:22] auto-link: added [[ms-learn-dotnet-fundamentals]] to [[csharp-basics]] (sim=0.8208) — Note A (C# Basics) covers language fundamentals and references the .NET platform, making it natural to point to Note B as a deeper, authoritative source on .NET fundamentals, while Note B (a literature note) should not backlink to general language basics.

- [2026-04-26 13:23] auto-link: mutual link [[agentic-frameworks-moc]] <-> [[python-moc]] (sim=0.8183) — Note A explicitly depends on Python tooling (Pydantic, FastAPI, decorators, asyncio) for implementing agentic frameworks, while Note B explicitly lists agent-tools as a related concept, making them genuinely complementary rather than coincidentally similar.

- [2026-04-26 13:23] auto-link: mutual link [[mcp-agent-skills]] <-> [[mcp-best-practices]] (sim=0.8173) — Note A describes the skills framework for building MCP servers, while Note B provides the best practices and patterns those servers should follow—they are complementary guides for MCP development where each enriches understanding of the other.

- [2026-04-26 13:23] auto-link: mutual link [[rust-concurrency]] <-> [[rust]] (sim=0.8157) — Note B introduces Rust's 'Fearless Concurrency' as a key feature and should link to Note A for detailed implementation, while Note A should link to Note B as its parent concept to provide broader context.

- [2026-04-26 13:23] auto-link: added [[typescript-narrowing]] to [[typescript-type-operators]] (sim=0.8155) — Note B's explanation of the `typeof` operator in type context should reference Note A's discussion of `typeof` as a type guard, since they describe different but related uses of the same operator that would benefit from cross-reference.

- [2026-04-26 13:23] auto-link: mutual link [[dotnet-moc]] <-> [[python-moc]] (sim=0.8155) — Both notes are ecosystem MOCs that serve parallel organizational purposes for their respective language stacks, and each explicitly lists the other in their 'See Also' section, indicating recognized mutual relevance for cross-ecosystem agent development patterns.

- [2026-04-26 13:23] auto-link: mutual link [[typescript-objects]] <-> [[typescript-utility-types]] (sim=0.8147) — Note A covers foundational object type concepts (property modifiers, index signatures, combining types) while Note B builds on these foundations with utility types that transform objects; they are genuinely complementary and readers of either would benefit from knowing about the other.

- [2026-04-26 13:23] auto-link: mutual link [[agent-actions]] <-> [[agent-thought-cycle]] (sim=0.8142) — These notes describe complementary components of the same agent architecture: Note A explains what Actions are (the execution mechanism), while Note B explains the Thought-Action-Observation cycle (the workflow that triggers actions), and each would benefit from referencing the other to provide complete context.

- [2026-04-26 13:23] auto-link: added [[mcp-primitives]] to [[agent-tools]] (sim=0.8138) — Note A discusses MCP as a unifying standard for tools but lacks detail on MCP's broader architecture and primitives; Note B provides that essential context, while Note B's tools section doesn't need to reference the general agent-tools concept.

- [2026-04-26 13:23] auto-link: added [[csharp-mcp-sdk]] to [[mcp-sdks]] (sim=0.8135) — Note B is a catalog/overview of MCP SDKs that should reference the specific C# SDK note for readers seeking detailed implementation guidance, while Note A already references the foundational mcp-architecture and doesn't need to backlink to a general catalog.

- [2026-04-26 13:23] auto-link: added [[ms-learn-dotnet-fundamentals]] to [[dotnet-moc]] (sim=0.8134) — Note A is a MOC (map of contents) that should reference foundational literature; Note B is a literature note on .NET fundamentals that doesn't need to link back to a hub that organizes more specialized topics.

- [2026-04-26 13:23] auto-link: mutual link [[agent-skills-index]] <-> [[agentic-frameworks-moc]] (sim=0.8134) — Note A (Agent Skills Index) documents the active procedural capabilities agents use, while Note B (Agentic Frameworks MOC) covers the theoretical foundations and frameworks that enable those capabilities—they are complementary halves of a complete agent architecture and should cross-reference each other.

- [2026-04-26 13:24] auto-link: mutual link [[code-agents]] <-> [[smolagents]] (sim=0.8132) — Note A defines Code Agents as a concept and explicitly mentions smolagents as a mandatory tool for security, while Note B is a concrete implementation of that concept, making them genuinely complementary and each strengthening the other through bidirectional reference.

- [2026-04-26 13:24] auto-link: mutual link [[powershell-moc]] <-> [[python-moc]] (sim=0.8125) — Both MOCs describe complementary automation/development ecosystems that explicitly share infrastructure (SQLite, audio-overview-workflow, schema-driven patterns) and should cross-reference each other for users navigating polyglot agent tooling.

- [2026-04-26 13:24] auto-link: mutual link [[typescript-functions]] <-> [[typescript-objects]] (sim=0.8122) — These notes are complementary parts of TypeScript's type system: functions describe callable signatures and behavior while objects describe data structures, and both use overlapping concepts (generics, optional parameters, type constraints) that benefit from cross-referencing.

- [2026-04-26 13:24] auto-link: mutual link [[csharp-async-await]] <-> [[python-asyncio]] (sim=0.8118) — Both notes cover analogous asynchronous programming patterns (async/await in C# vs. asyncio in Python) with parallel concepts (Task vs. coroutine, await keyword, event-loop coordination) and both emphasize agent workflow applications, making them genuine cross-language complements.

- [2026-04-26 13:24] auto-link: added [[ps-vault-stats]] to [[ps-vault-maintenance]] (sim=0.8117) — ps-vault-maintenance orchestrates multiple maintenance scripts and should reference ps-vault-stats as a complementary observability tool that provides metrics on vault health, while ps-vault-stats independently tracks metrics without needing to reference the maintenance orchestrator.

- [2026-04-26 13:24] auto-link: added [[ms-learn-dotnet-fundamentals]] to [[ms-learn-csharp-overview]] (sim=0.8115) — Note A (C# Overview) describes a language that runs on the .NET runtime, making a reference to Note B (.NET Fundamentals) essential for understanding the execution environment, while Note B is a broader platform overview that doesn't require C#-specific details.

- [2026-04-26 13:24] auto-link: mutual link [[community-protocol-trust-substrate]] <-> [[dotnet-agent-integration]] (sim=0.8114) — Note A's trust-by-construction substrate theory and Tier-0 Rust/MCP foundation directly underpins Note B's tier model and .NET integration strategy, making them mutually reinforcing frameworks for the same agentic architecture.

- [2026-04-26 13:24] auto-link: added [[typescript-objects]] to [[typescript-mapped-types]] (sim=0.8112) — Mapped types are an advanced pattern built on top of object types and property modifiers, so Note A should reference Note B as foundational context, but Note B is general-purpose and doesn't need to reference the specialized mapped types concept.

- [2026-04-26 13:24] auto-link: mutual link [[mcp-client-development]] <-> [[mcp-debugging]] (sim=0.8098) — Note A describes MCP client implementation patterns while Note B addresses debugging those clients; they are complementary guides where developers implementing clients (A) need debugging strategies (B) and debuggers need to understand client architecture (A).

- [2026-04-26 13:24] auto-link: added [[workbench-codex-runner-handoff]] to [[codex-polyglot-adr-handoff]] (sim=0.8097) — Note A explicitly identifies `00_Raw/workbench/` as an open question about tier classification, and Note B documents the resolution of that artifact's role in the hardened Codex environment, making B a necessary reference for completing A's verification.

- [2026-04-26 13:24] auto-link: mutual link [[community-living-knowledge-system]] <-> [[community-polyglot-agent-platform]] (sim=0.8096) — Note A describes the knowledge system architecture and execution model that Note B's polyglot platform must implement across its language tiers; conversely, Note B demonstrates the concrete technical realization of Note A's abstract principle that 'a note is code' through language-specific operational constraints.

- [2026-04-26 13:25] auto-link: mutual link [[mcp-client-development]] <-> [[mcp-remote-connections]] (sim=0.8094) — Note A describes client development patterns for local/stdio connections while Note B covers remote HTTP/SSE connections; together they represent complementary transport mechanisms that MCP clients must support, and each would benefit from cross-referencing the other's transport approach.

- [2026-04-26 13:25] auto-link: mutual link [[community-protocol-trust-substrate]] <-> [[mcp-moc]] (sim=0.8093) — Note A develops an emergent theory about MCP's trust architecture that grounds itself in MCP fundamentals, while Note B provides the comprehensive structural reference that Note A's theoretical claims depend on; each note strengthens the other by creating a bidirectional pathway between conceptual abstraction (A) and practical taxonomy (B).

## [2026-04-24] schema | Updated GEMINI.md to formalize Zettelkasten note types (Fleeting, Literature, Permanent) in the workflow.

## [2026-04-24] ingest | Final cleanup of PKM ideas. Added [[wiki-pattern-tooling]], [[collective-iq]], [[pkm-software-landscape]], and [[wiki-as-codebase]].

## [2026-04-24] research | Expanded PowerShell thread with [[ps-custom-objects]], [[ps-calculated-properties]], and [[ps-classes]].

## [2026-04-24] research | Started PowerShell learning thread with [[powershell-objects]].

## [2026-04-23] Agentic YANP Exploration
* **Action**: Created synthesis page for YANP's role in agentic workflows.
* **Created**: [[yanp-for-agentic-workflows]]
* **Action**: Updated [[yanp-for-agentic-workflows]] status to active.

## [2026-04-23] Plain+ Ingestion
* **Action**: Ingested the Plain+ Design Specification.
* **Created**: [[plain-plus-design]], [[anti-ai-aesthetic]].
* **Reference**: Added `00_Raw/reference/plain-plus-design.md`.

## [2026-04-23] YAML Cheat Sheet
* **Action**: Synthesized [[yaml-for-yanp]] from raw specification.
* **Created**: [[yaml-for-yanp]]

## [2026-04-23] Reference Seeding
* **Action**: Created `00_Raw/reference/` and added `yaml-spec-1.2.md`.
* **Purpose**: Provide authoritative source for YANP frontmatter validation.

## [2026-04-23] YANP Refactor
* **Action**: Refactored the entire vault to comply with the **Yet Another Note Protocol (YANP)**.
* **Changes**:
    * Updated `GEMINI.md` to enforce YANP mandates.
    * Renamed all notes to lowercase kebab-case.
    * Injected YAML frontmatter into all notes in `01_Wiki/`.
    * Updated all internal wikilinks to use kebab-case file stems for maximum stability.
* **Files Migrated**:
    * `llm-wiki-pattern.md`
    * `memex.md`
    * `zettelkasten.md`
    * `the-compounding-artifact.md`

## [2025-05-14] community-reports | Synthesized 6 Level-1 Community Reports: [[pkm-history]], [[agentic-protocols]], [[dotnet-csharp]], [[vault-systems]], [[frameworks-eval]], and [[lattice-interop]].

- [2026-04-27 01:02] auto-link: added [[lit-adk-documentation]] to [[agent-development-kit]] (sim=0.9003) — Note A is a permanent concept note that should cite its source literature, and Note B is explicitly the literature/documentation source that Note A was synthesized from, making a one-directional reference from A to B appropriate.

- [2026-04-27 01:02] auto-link: added [[claude-a2a-protocol-handoff]] to [[rfc-agent-orchestration-handoff]] (sim=0.8579) — Note B (RFC handoff) explicitly references the incomplete [[a2a-protocol]] as its foundation and extends it with orchestration patterns, so B should link back to A as the prerequisite work it builds upon, while A (as a task handoff) should not backlink to downstream RFCs.

- [2026-04-27 01:02] auto-link: mutual link [[adk-artifact-service]] <-> [[adk-session-service]] (sim=0.8551) — Both services are core ADK infrastructure components that work together in agent lifecycle management—Session Service manages conversation history and state while Artifact Service manages binary data persistence—and agents commonly use both services together through their context objects.

- [2026-04-27 01:02] auto-link: mutual link [[orchestration-tradeoffs]] <-> [[lit-openai-swarm]] (sim=0.8516) — Note A analyzes OpenAI Swarm vs. Google ADK as a philosophical comparison, while Note B provides the foundational literature and mechanics of these systems; they are complementary with A providing evaluation context and B providing source material.

- [2026-04-27 01:27] auto-link: added [[lit-mcp-architecture]] to [[mcp-architecture]] (sim=0.9223) — Note A is a permanent, authoritative explanation of MCP architecture that should cite its literature source (Note B), establishing provenance and allowing readers to consult the original Anthropic documentation.

- [2026-04-27 01:27] auto-link: added [[pattern-progressive-handoff]] to [[rfc-agent-orchestration-handoff]] (sim=0.8571) — Note A is an RFC proposing unification of agent orchestration protocols and explicitly needs to reference concrete pattern implementations like progressive handoff to ground its design objectives.

- [2026-04-27 01:27] auto-link: added [[mcp-server-features]] to [[lit-mcp-architecture]] (sim=0.8566) — Note B is a literature/source note that provides foundational architecture context, and should reference Note A which offers a more detailed, practical breakdown of the server-exposed primitives that Note B only summarizes in tabular form.

- [2026-04-27 01:27] auto-link: mutual link [[rust]] <-> [[lit-rust-programming-language]] (sim=0.8505) — Note A is the conceptual entry point for Rust that should cite its primary source material, while Note B is the literature note that should link back to its subject concept, creating a bidirectional reference between concept and source.


- [2026-04-27] Gemini Cleanup: Reconciled 01_Wiki, indexed ADK notes and Community Reports, synced embeddings. Ref: [[codex-gemini-cleanup-handoff-2026-04-27]]

- [2026-04-27 02:40] auto-link: mutual link [[claude-synthesis-handoff]] and [[claude-blueprint-handoff]] (sim=0.8947) - These are sequential handoff notes describing complementary phases (Synthesis → Blueprint) of the same vault project, where each phase explicitly builds on the previous one's deliverables, making bidirectional referencing valuable for understanding the project's progression.
- [2026-04-27 02:40] auto-link: mutual link [[claude-synthesis-handoff-2026-04-27]] and [[claude-blueprint-handoff-2026-04-27]] (sim=0.8943) - Both are 2026-04-27 handoff sessions delivering complementary work (Synthesis: literature + patterns + community report; Blueprint: memory MCP + Rust patterns), and each explicitly targets the next Claude instance, so cross-referencing provides complete session context.
- [2026-04-27 02:41] auto-link: mutual link [[claude-synthesis-handoff]] and [[claude-gardening-visuals-handoff]] (sim=0.8789) - Both handoff notes address complementary aspects of the same vault evolution (synthesis/architecture in A, gardening/visuals in B), and each mission benefits from cross-referencing the other's deliverables for holistic knowledge expansion.
- [2026-04-27 02:41] auto-link: mutual link [[claude-blueprint-handoff]] and [[claude-gardening-visuals-handoff]] (sim=0.8685) - Both handoff notes are complementary phases of the same Vulture Nest project (Blueprint Phase vs. Gardening/Visuals Phase) and should cross-reference each other to show their sequential and interdependent relationship in the overall architecture work.
- [2026-04-27 02:41] auto-link: added [[lit-python-standard-library]] to [[python-standard-library-hubs]] (sim=0.8499) - Note A is a curated hub focused on three specific stdlib modules for agents; Note B is comprehensive reference documentation that Note A should cite as its authoritative source material, but Note B (being a literature/reference note) should not reciprocally link to the more specialized hub.
- [2026-04-27 02:41] auto-link: added [[codex-build-sprint-handoff]] to [[claude-blueprint-handoff-2026-04-27]] (sim=0.8485) - Note A documents completed blueprint specs that Note B uses as prerequisites for its sequenced build sprint tasks.
- [2026-04-27 02:41] auto-link: added [[claude-capability-lattice-handoff]] to [[claude-blueprint-handoff]] (sim=0.8447) - Note B explicitly lists [[capability-lattice-spec]] as a dependency for implementing Tier-0 Rust patterns, making a backlink from B to A (the handoff that produces that spec) valuable for traceability, but A should not reference B since A precedes it in the workflow sequence.
- [2026-04-27 02:41] auto-link: added [[lit-rust-programming-language]] to [[rust-moc]] (sim=0.8439) - The MOC is a structural index that benefits from citing its primary authoritative source, while the literature note is self-contained and doesn't need to backref the index.
- [2026-04-27 02:41] auto-link: mutual link [[codex-build-sprint-handoff]] and [[gemini-build-sprint-handoff]] (sim=0.8431) - Both are parallel build sprint handoffs executed on the same date for different systems (Codex vs Gemini); they represent coordinated work streams that would benefit from mutual cross-reference for context and sequencing awareness.
- [2026-04-27 02:41] auto-link: added [[lit-mcp-architecture]] to [[mcp-client-development]] (sim=0.8421) - Note A discusses implementation patterns for MCP clients and should reference Note B's foundational architecture overview to ground those patterns in MCP's design principles, while Note B is a literature source that doesn't need to reference downstream implementations.
- [2026-04-27 02:41] auto-link: added [[lit-typescript-handbook]] to [[typescript-moc]] (sim=0.8408) - Note A is a navigational MOC that should reference its canonical source material, while Note B is a literature note that naturally stands alone as a reference document.
- [2026-04-27 02:41] auto-link: added [[lit-python-standard-library]] to [[python-moc]] (sim=0.8399) - Note A's 'Standard Library Hubs' section explicitly references [[python-standard-library-hubs]] as a concept, and Note B provides the authoritative literature source for understanding those stdlib modules in agent contexts, making it a natural target for Note A to point to without cluttering Note B with a reciprocal link.
- [2026-04-27 02:42] auto-link: mutual link [[claude-blueprint-handoff]] and [[codex-build-sprint-handoff]] (sim=0.8390) - Note A defines the blueprint specifications that Note B sequences for implementation, and Note B references those specs as prerequisites—they are complementary halves of a handoff cycle where A→B dependency is explicit and B→A context is valuable.
- [2026-04-27 02:42] auto-link: added [[claude-capability-lattice-handoff]] to [[claude-blueprint-handoff-2026-04-27]] (sim=0.8385) - Note B documents completed blueprint work that directly fulfills the capability lattice specification handoff initiated in Note A, making it a natural downstream reference for context on what was delivered.
- [2026-04-27 02:42] auto-link: mutual link [[adk-multi-agent-orchestration]] and [[multi-agent-patterns-moc]] (sim=0.8369) - Note A provides concrete ADK implementation details of patterns that Note B abstracts and categorizes (agent-as-tool, dynamic delegation, state transfer), making each a valuable reference for the other—Note A illustrates specific patterns while Note B contextualizes them within broader architectural taxonomy.
- [2026-04-27 02:42] auto-link: added [[claude-a2a-protocol-handoff]] to [[claude-blueprint-handoff-2026-04-27]] (sim=0.8355) - Note B's Tier-2 agent layer and A2A protocol context directly depend on the A2A protocol scaffold that Note A defines as its deliverable, making a backref from B to A valuable for tracing architectural dependencies.
- [2026-04-27 02:42] auto-link: added [[claude-synthesis-handoff]] to [[claude-blueprint-handoff-2026-04-27]] (sim=0.8352) - Note B (Blueprint Phase Complete) documents concrete delivery of specs that directly support Note A's Three Pillars mission—particularly the Memory MCP and Rust patterns feed into Pillar 3 (Unified Agentic Patterns), so B should reference A as the synthesis roadmap it contributes to.
- [2026-04-27 02:42] auto-link: added [[lit-mcp-architecture]] to [[mcp-security]] (sim=0.8349) - Note A on MCP Security should reference Note B as its architectural foundation, since security mechanisms operate within the client-server architecture that Note B documents.
- [2026-04-27 02:42] auto-link: added [[lit-rust-programming-language]] to [[rust-concurrency]] (sim=0.8346) - Note A cites the Rust Programming Language book as its source (already referenced in its metadata), so adding an explicit wikilink to Note B (the literature note) strengthens traceability and attribution without cluttering Note B with a backlink to every topic it covers.
- [2026-04-27 02:42] auto-link: added [[claude-session-types-handoff]] to [[claude-blueprint-handoff-2026-04-27]] (sim=0.8344) - Note B documents completed blueprint work and should reference Note A as the identified highest-priority gap that contextualizes why these particular specs (memory MCP and Rust patterns) were prioritized over session types in this phase.
- [2026-04-27 02:42] auto-link: added [[lit-mcp-architecture]] to [[mcp-primitives]] (sim=0.8324) - Note A explains MCP primitives conceptually while Note B is the authoritative source documentation, so A should reference B as its foundational source material.
- [2026-04-27 02:42] auto-link: added [[lit-mcp-architecture]] to [[mcp-server-development]] (sim=0.8320) - Note A (practical server development) should reference Note B (foundational architecture documentation) to ground implementation details in the authoritative protocol specification, but Note B is a literature reference that doesn't need reciprocal links to implementation guides.
- [2026-04-27 02:43] auto-link: added [[knowledge-gardening-principles]] to [[spec-knowledge-gardening]] (sim=0.8294) - Note B (the spec) should reference Note A (the principles) to ground its operational protocol in the foundational philosophy, particularly when discussing orphan remediation which directly implements the gap-filling principle.
- [2026-04-27 02:43] auto-link: added [[claude-synthesis-handoff-2026-04-27]] to [[claude-blueprint-handoff]] (sim=0.8293) - Note B (Blueprint Phase) is a direct continuation of Note A's completed synthesis work and should reference it as the prerequisite foundation, while Note A as a completed handoff artifact does not need to reference forward plans.
- [2026-04-27 02:43] auto-link: added [[gemini-build-sprint-handoff]] to [[claude-synthesis-handoff-2026-04-27]] (sim=0.8275) - Note A documents the synthesis work completed; Note B is the immediate actionable handoff to Gemini that depends on those 13 notes being created, so A should reference B as the next phase.
- [2026-04-27 02:43] auto-link: added [[typescript-everyday-types]] to [[lit-typescript-handbook]] (sim=0.8274) - Note B is a literature/source note that should reference the permanent note A it directly covers, enabling readers of the handbook summary to access the detailed treatment of everyday types.
- [2026-04-27 02:43] auto-link: mutual link [[adk-artifact-service]] and [[adk-long-term-memory]] (sim=0.8270) - Both notes describe complementary ADK services with parallel architectural patterns (abstraction, multiple implementations, context-based access, configuration at Runner initialization), and agents naturally use artifacts and memory together for stateful, context-aware behavior.
- [2026-04-27 02:43] auto-link: mutual link [[mcp-transport]] and [[lit-mcp-architecture]] (sim=0.8267) - Note A provides implementation details of transport mechanisms that are foundational to the two-layer architecture described in Note B, while Note B provides the overarching architectural context that explains why transport abstraction matters in MCP.
- [2026-04-27 02:43] auto-link: mutual link [[adk-multi-agent-orchestration]] and [[pattern-dynamic-delegation]] (sim=0.8257) - Note A describes ADK's multi-agent composition mechanisms (including AgentTool as a delegation primitive), while Note B analyzes dynamic delegation as a cross-framework pattern with ADK as a primary implementation example — they are mutually reinforcing and each benefits from citing the other.
- [2026-04-27 02:43] auto-link: mutual link [[pattern-agent-as-tool]] and [[pattern-progressive-handoff]] (sim=0.8247) - These patterns represent complementary agent composition strategies—Agent as Tool encapsulates a sub-agent as an opaque callable within a parent's tool roster, while Progressive Handoff transfers complete task ownership between agents—and each pattern benefits from acknowledging the other as a distinct alternative approach.
- [2026-04-27 02:43] auto-link: added [[lit-mcp-architecture]] to [[mcp-remote-connections]] (sim=0.8243) - Note A discusses remote connections as a specific implementation pattern within MCP, and should reference Note B's foundational architecture overview to ground readers in the protocol's broader design, but Note B is a general literature reference that does not need to link to every specific connection type.
- [2026-04-27 02:44] auto-link: added [[lit-mcp-architecture]] to [[mcp-best-practices]] (sim=0.8242) - Note A (best practices) builds on and assumes knowledge of the foundational MCP architecture documented in Note B, making B a natural prerequisite reference for A.
- [2026-04-27 02:44] auto-link: mutual link [[claude-synthesis-handoff]] and [[gemini-build-sprint-handoff]] (sim=0.8233) - These are complementary handoff notes from the same date describing sequential work phases: Claude's synthesis and architecture planning (Pillar 1-3) directly enables Gemini's build sprint execution (embedding sync, graph integration, clustering), making bidirectional reference essential for continuity.
- [2026-04-27 02:44] auto-link: added [[claude-blueprint-handoff-2026-04-27]] to [[gemini-build-sprint-handoff]] (sim=0.8229) - Note B (Gemini's build sprint) needs to reference Note A (Claude's completed blueprint handoff) because the 17 new notes that Gemini is ingesting were created by Claude in the blueprint phase, making Note A the source context for Note B's integration work.
- [2026-04-27 02:44] auto-link: added [[spec-visual-vault-language]] to [[claude-gardening-visuals-handoff]] (sim=0.8201) - Note A is a handoff document that assigns the creation of spec-visual-vault-language as a task, so it should reference the completed Note B as its deliverable; Note B should not link back as it is the standalone specification being handed off to.
- [2026-04-28 07:35:10] Ingested 2510.01171v3.pdf into [[lit-verbalized-sampling-paper]]. Implemented Mode-Anchored Departure (Approach B) focus.

- [2026-04-29 23:08] auto-link: added [[codex-build-sprint-handoff]] to [[codex-orchestrator-build-handoff-2026-04-29]] (sim=0.8744) - Note B (orchestrator handoff, dated 2026-04-29) is a sequential follow-up to Note A (build sprint handoff, dated 2026-04-27) and should reference it as context for the prior gardening audit phase and task sequencing.

- [2026-04-29 23:09] auto-link: mutual link [[verbalized-sampling]] and [[lit-verbalized-sampling-paper]] (sim=0.8732) - Note A is a conceptual permanent note about Verbalized Sampling, while Note B is the literature note documenting the primary paper that introduced the technique; they are directly complementary and each strengthens understanding of the other.

- [2026-04-29 23:09] auto-link: added [[claude-orchestrator-synthesis-handoff-2026-04-29]] to [[claude-synthesis-handoff]] (sim=0.8695) - Note A (2026-04-27) outlines the three-pillar strategy and vault expansion mission, while Note B (2026-04-29) provides the concrete implementation directives for Pillar 3 (synthesis) and the epistemic gates; Note A should reference B as the detailed handoff that operationalizes its strategic vision.

- [2026-04-29 23:09] auto-link: mutual link [[gemini-build-sprint-handoff]] and [[gemini-roadmap-sprint-handoff-2026-04-27]] (sim=0.8682) - Both are complementary handoff notes from the same date describing sequential work (Build Sprint → Roadmap Sprint) that explicitly reference waiting for the other's completion, making bidirectional links essential for understanding the full handoff context.

- [2026-04-29 23:09] auto-link: mutual link [[gemini-build-sprint-handoff]] and [[codex-roadmap-sprint-handoff-2026-04-27]] (sim=0.8649) - Both are dated handoff notes from the same session (2026-04-27) describing sequential tasks for different agents (Gemini and Codex) working on the same wiki system, so each provides context for the other's work.

- [2026-04-29 23:09] auto-link: mutual link [[claude-orchestrator-synthesis-handoff-2026-04-29]] and [[codex-orchestrator-build-handoff-2026-04-29]] (sim=0.8589) - These are complementary handoff notes describing interdependent work streams (Synthesis Intelligence and Infrastructure) that explicitly depend on each other's completion, with Note A's 'Next Seam' waiting for Note B's infrastructure and Note B's 'Next Seam' handing off to Note A.

- [2026-04-29 23:09] auto-link: mutual link [[codex-gemini-cleanup-handoff-2026-04-27]] and [[gemini-roadmap-sprint-handoff-2026-04-27]] (sim=0.8552) - These are complementary handoff notes from the same sprint date describing different ownership lanes (Codex's engineering cleanup vs. Gemini's structural/protocol work) that together form a complete handoff boundary, so each should reference the other for full context.


## Orphan Wiring Verification
- [[agentic-protocols]]
- [[code-agents]]
- [[graph-orchestration]]
- [[mcp-authorization]]
- [[mcp-best-practices]]


## [2026-04-30] Gemini — Index Maintenance & Status Sync
* **Action**: Updated [[index]] to include [[spec-agentic-source-orchestrator]] and the 2026-04-29 implementation handoffs.
* **Status**: Reconstructed current vault state for the user session. All 2026-04-29 deliverables are now indexed and discoverable.
* **Next**: Proceed with [[codex-orchestrator-build-handoff-2026-04-29]] infrastructure tasks.

## [2026-04-30] Codex — Orchestrator Infrastructure Scaffold
* **Built**: Added `02_System/pipeline-policy.yaml` and a fail-closed loader at `02_System/vulture-ingest/policy.py`.
* **Built**: Added `02_System/vulture-ingest/schema.sql` with `source_pages`, `source_chunks`, extensions, HNSW index, and `match_documents()`.
* **Built**: Scaffolded `02_System/vulture-ingest/server.py` with `propose_source_intake`, `orchestrate_ingestion`, and `execute_source_crawl`, each enforcing denied-domain and quota policy before execution.
* **Verified**: Added `02_System/test_vulture_ingest.py` to cover missing-policy failure, invalid policy rejection, denied-domain blocking, new-domain HITL gating, and dry-run crawl policy enforcement.
* **Seam**: Infrastructure scaffold is in place; actual Supabase provisioning and live Firecrawl execution still depend on runtime credentials and network access. Next step is integrated verification and then Claude's synthesis-layer work against this tool surface.
