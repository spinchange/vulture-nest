---
title: 'Spec: Visual Vault Language'
author: claude-sonnet-4-6
date: '2026-04-27'
status: active
type: permanent
aliases:
  - visual-vault-language
  - mermaid-standards
  - diagrams-as-code
---

# Spec: Visual Vault Language

**Purpose:** Define a standard for representing the Vulture Nest's architecture visually using Mermaid.js — the text-based diagramming format natively rendered by Obsidian. A shared visual language lets agents generate diagrams that humans can read, and humans can edit diagrams that agents can parse back into structured knowledge.

All diagrams in the vault are **first-class content**, not decorations. They should encode information not easily expressed in prose and should be kept in sync with the notes they illustrate.

---

## 1. General Standards

### 1.1 Placement
- Diagrams live inline in the note they illustrate, under the H2 section they describe.
- A note should have at most **one diagram per H2 section** — if more are needed, split the section.
- Standalone diagram notes (e.g., a complex architecture overview) use `type: spec` and title prefix `Diagram:`.

### 1.2 Comment Header
Every diagram block must open with a Mermaid comment identifying its type and purpose:

````markdown
```mermaid
%% [diagram-type]: Brief description of what this diagram shows
```
````

Valid `diagram-type` values: `flowchart`, `stateDiagram`, `sequenceDiagram`, `lattice`, `classDiagram`.

### 1.3 Consistent Class Styling
All diagrams share this standard class palette. Include the relevant `classDef` lines at the bottom of every Mermaid block that uses them:

```
classDef agent      fill:#3b5998,color:#fff,stroke:#2a4070
classDef tool       fill:#1a6b3c,color:#fff,stroke:#114d2b
classDef external   fill:#7a4500,color:#fff,stroke:#5a3300
classDef human      fill:#6b2d8b,color:#fff,stroke:#4d1f66
classDef store      fill:#1a3a5c,color:#fff,stroke:#0f2440
classDef error      fill:#8b1a1a,color:#fff,stroke:#5c1010
classDef terminal   fill:#555,color:#fff,stroke:#333
```

| Class | Use for |
|---|---|
| `agent` | LLM agents, orchestrators, specialist agents |
| `tool` | MCP tools, function tools, API endpoints |
| `external` | External services, third-party APIs |
| `human` | Human actors in HITL patterns |
| `store` | Databases, memory stores, file systems |
| `error` | Error states, failure paths |
| `terminal` | Terminal states in state machines |

---

## 2. Pattern: Relationship Mapping (Flowcharts)

Use `flowchart LR` (left-to-right) for agent orchestration and tool call diagrams. Use `flowchart TB` (top-to-bottom) for hierarchy and tier architecture diagrams.

### 2.1 Agent Orchestration (LR)

Shows which agents call which other agents or tools, and the nature of each interaction.

**Edge label vocabulary:**

| Label | Meaning |
|---|---|
| `delegates` | [[pattern-dynamic-delegation]] — A calls B, waits, retains ownership |
| `hands off` | [[pattern-progressive-handoff]] — A transfers ownership to B |
| `reads` / `writes` | Data access to a store |
| `calls` | Tool invocation (not agent) |
| `fans out` | [[pattern-parallel-fan-out]] — simultaneous dispatch |
| `escalates` | [[pattern-human-in-the-loop]] — pause for human input |

**Example — Memory MCP delegation chain:**
````markdown
```mermaid
%% flowchart: Memory MCP delegation chain from coordinator to memory store
flowchart LR
    U((User)):::human --> CO[Coordinator]:::agent
    CO -->|delegates| RA[ResearchAgent]:::agent
    CO -->|delegates| MA[MemoryAgent]:::agent
    RA -->|calls| SW[search_memories]:::tool
    MA -->|calls| CM[commit_memory]:::tool
    SW --> DB[(MemoryDB\nSQLite)]:::store
    CM --> DB

    classDef agent    fill:#3b5998,color:#fff,stroke:#2a4070
    classDef tool     fill:#1a6b3c,color:#fff,stroke:#114d2b
    classDef human    fill:#6b2d8b,color:#fff,stroke:#4d1f66
    classDef store    fill:#1a3a5c,color:#fff,stroke:#0f2440
```
````

**Rendered:**
```mermaid
%% flowchart: Memory MCP delegation chain from coordinator to memory store
flowchart LR
    U((User)):::human --> CO[Coordinator]:::agent
    CO -->|delegates| RA[ResearchAgent]:::agent
    CO -->|delegates| MA[MemoryAgent]:::agent
    RA -->|calls| SW[search_memories]:::tool
    MA -->|calls| CM[commit_memory]:::tool
    SW --> DB[(MemoryDB\nSQLite)]:::store
    CM --> DB

    classDef agent    fill:#3b5998,color:#fff,stroke:#2a4070
    classDef tool     fill:#1a6b3c,color:#fff,stroke:#114d2b
    classDef human    fill:#6b2d8b,color:#fff,stroke:#4d1f66
    classDef store    fill:#1a3a5c,color:#fff,stroke:#0f2440
```

### 2.2 Tier Architecture (TB)

Shows the layered architecture of the system, reading top-to-bottom from most abstract to most concrete.

**Example — Three-tier Rust/Python/Agent stack:**
````markdown
```mermaid
%% flowchart: Three-tier agent stack (Rust Tier-0 → Python Tier-1 → Agent Tier-2)
flowchart TB
    T0["Tier-0\nRust Safe Core\n(Capability Gate)"]:::agent
    T1["Tier-1\nPython Orchestrator\n(ADK / Swarm)"]:::agent
    T2A["Tier-2\nSpecialist A\n(A2A)"]:::agent
    T2B["Tier-2\nSpecialist B\n(A2A)"]:::agent
    MCP["Memory MCP\nServer"]:::tool

    T0 -->|"ValidatedEnvelope\n(serde JSON)"| T1
    T1 -->|"delegates"| T2A
    T1 -->|"delegates"| T2B
    T1 -->|"commit/search"| MCP

    classDef agent fill:#3b5998,color:#fff,stroke:#2a4070
    classDef tool  fill:#1a6b3c,color:#fff,stroke:#114d2b
```
````

---

## 3. Pattern: State Machines

Use `stateDiagram-v2` for lifecycle diagrams. Always show all terminal states and all non-happy-path transitions.

### 3.1 Rules

- Start state: `[*] --> FirstState`
- Terminal states: `SomeState --> [*]`; apply `:::terminal` class
- Error paths: use `:::error` class on FAILED / REJECTED states
- Include the triggering condition on every transition arrow: `StateA --> StateB: trigger`
- Keep state names in SCREAMING_SNAKE_CASE to match protocol definitions

### 3.2 Example — A2A Task Lifecycle

````markdown
```mermaid
%% stateDiagram: A2A Task lifecycle including all terminal and escalation states
stateDiagram-v2
    [*] --> SUBMITTED : SendMessage
    SUBMITTED --> WORKING : agent accepts

    WORKING --> COMPLETED : task done
    WORKING --> FAILED : unrecoverable error
    WORKING --> CANCELED : CancelTask received
    WORKING --> REJECTED : agent refuses task

    WORKING --> INPUT_REQUIRED : agent needs data
    INPUT_REQUIRED --> WORKING : client sends follow-up

    WORKING --> AUTH_REQUIRED : credential needed
    AUTH_REQUIRED --> WORKING : client provides credential

    WORKING --> TRANSFERRED : handoff initiated
    TRANSFERRED --> [*] : terminal — continues on target agent

    COMPLETED --> [*]
    FAILED --> [*]
    CANCELED --> [*]
    REJECTED --> [*]
```
````

**Rendered:**
```mermaid
%% stateDiagram: A2A Task lifecycle including all terminal and escalation states
stateDiagram-v2
    [*] --> SUBMITTED : SendMessage
    SUBMITTED --> WORKING : agent accepts

    WORKING --> COMPLETED : task done
    WORKING --> FAILED : unrecoverable error
    WORKING --> CANCELED : CancelTask received
    WORKING --> REJECTED : agent refuses task

    WORKING --> INPUT_REQUIRED : agent needs data
    INPUT_REQUIRED --> WORKING : client sends follow-up

    WORKING --> AUTH_REQUIRED : credential needed
    AUTH_REQUIRED --> WORKING : client provides credential

    WORKING --> TRANSFERRED : handoff initiated
    TRANSFERRED --> [*] : terminal — continues on target agent

    COMPLETED --> [*]
    FAILED --> [*]
    CANCELED --> [*]
    REJECTED --> [*]
```

### 3.3 Example — MCP Connection Lifecycle

````markdown
```mermaid
%% stateDiagram: MCP connection lifecycle (initialize → active → closed)
stateDiagram-v2
    [*] --> CONNECTING : transport established
    CONNECTING --> INITIALIZING : client sends initialize
    INITIALIZING --> ACTIVE : server responds + client sends initialized
    ACTIVE --> ACTIVE : request / response / notification
    ACTIVE --> CLOSED : transport closed
    CONNECTING --> CLOSED : connection refused
    CLOSED --> [*]
```
````

---

## 4. Pattern: Lattice Visualization

Use `flowchart TB` for lattice diagrams. The lattice reads top-to-bottom: **⊤ (all capabilities)** at the top, **⊥ (empty)** at the bottom. Intermediate nodes are capability sets; edges represent the subset relation (down = narrower).

### 4.1 Rules

- Top node is always `TOP["⊤\n(all capabilities)"]`
- Bottom node is always `BOT["⊥\n(empty set)"]`
- Each intermediate node label lists the capability set members
- Edges flow downward (TB) — upper node is a superset of lower node
- The **meet** (∩) of two sibling nodes is their shared lower bound
- Annotate meet/join operations with edge labels when showing a specific delegation

### 4.2 Example — Delegation Meet Operation

Shows how `Effective(A → B) = Caps(B) ∩ Scope(A)`:

````markdown
```mermaid
%% lattice: Capability meet for delegation — Effective = Caps(B) ∩ Scope(A)
flowchart TB
    TOP["⊤\nAll Capabilities"]
    TOP --> SA["Scope(A)\nReadVault\nWriteVault\nCommitMemory"]:::agent
    TOP --> CB["Caps(B)\nReadVault\nSearchMemory\nCommitMemory"]:::agent
    SA  --> MEET["Effective(A→B)\nReadVault\nCommitMemory\n(safe delegation ceiling)"]:::tool
    CB  --> MEET
    MEET --> BOT["⊥\n(empty)"]:::terminal

    classDef agent    fill:#3b5998,color:#fff,stroke:#2a4070
    classDef tool     fill:#1a6b3c,color:#fff,stroke:#114d2b
    classDef terminal fill:#555,color:#fff,stroke:#333
```
````

**Rendered:**
```mermaid
%% lattice: Capability meet for delegation — Effective = Caps(B) ∩ Scope(A)
flowchart TB
    TOP["⊤\nAll Capabilities"]
    TOP --> SA["Scope(A)\nReadVault\nWriteVault\nCommitMemory"]:::agent
    TOP --> CB["Caps(B)\nReadVault\nSearchMemory\nCommitMemory"]:::agent
    SA  --> MEET["Effective(A→B)\nReadVault\nCommitMemory\n(safe delegation ceiling)"]:::tool
    CB  --> MEET
    MEET --> BOT["⊥\n(empty)"]:::terminal

    classDef agent    fill:#3b5998,color:#fff,stroke:#2a4070
    classDef tool     fill:#1a6b3c,color:#fff,stroke:#114d2b
    classDef terminal fill:#555,color:#fff,stroke:#333
```

### 4.3 Example — Monotone Delegation Chain

Shows that capability can only narrow through a chain of delegations:

````markdown
```mermaid
%% lattice: Monotone narrowing through delegation chain A → B → C
flowchart TB
    A["Agent A\nReadVault, WriteVault\nCommitMemory, ExecuteCode"]:::agent
    B["Agent B\nReadVault, WriteVault\nCommitMemory"]:::agent
    C["Agent C\nReadVault\nCommitMemory"]:::agent

    A -->|"delegates ∩"| B
    B -->|"delegates ∩"| C

    note1["ExecuteCode dropped:\nB doesn't have it"]
    note2["WriteVault dropped:\nC doesn't have it"]
    A --- note1
    B --- note2

    classDef agent fill:#3b5998,color:#fff,stroke:#2a4070
```
````

---

## 5. Pattern: Sequence Diagrams (Protocol Handshakes)

Use `sequenceDiagram` for multi-party protocol interactions where order and timing matter. Essential for MCP lifecycle and A2A task flows.

### 5.1 Rules

- Participants listed left-to-right in order of initiation
- Use `activate` / `deactivate` to show blocking waits
- Mark async responses with `-->>` (dashed arrow)
- Use `Note over` for important protocol facts
- Keep to ≤ 8 participants; split complex flows across multiple diagrams

### 5.2 Example — MCP Initialize Handshake

````markdown
```mermaid
%% sequenceDiagram: MCP initialization and first tool call
sequenceDiagram
    participant Host as MCP Host
    participant Client as MCP Client
    participant Server as MCP Server

    Host->>Client: create client for Server
    activate Client
    Client->>Server: initialize {protocolVersion, capabilities}
    activate Server
    Server-->>Client: {protocolVersion, capabilities: {tools: {listChanged: true}}}
    deactivate Server
    Client->>Server: notifications/initialized
    Note over Client,Server: Session is now ACTIVE

    Host->>Client: list available tools
    Client->>Server: tools/list
    Server-->>Client: [{name: "search_memories", ...}]
    Client-->>Host: registered tools

    Host->>Client: call tool
    Client->>Server: tools/call {name: "search_memories", arguments: {query: "..."}}
    activate Server
    Server-->>Client: {content: [{type: "text", text: "..."}]}
    deactivate Server
    Client-->>Host: tool result
    deactivate Client
```
````

### 5.3 Example — A2A Delegation + Handoff

````markdown
```mermaid
%% sequenceDiagram: A2A delegation (A calls B, waits) then handoff (A transfers to C)
sequenceDiagram
    participant Orch as Orchestrator (A)
    participant B as SpecialistB
    participant C as SpecialistC

    Note over Orch: Task: complex research + billing

    Orch->>B: SendMessage {task: research_query}
    activate B
    B-->>Orch: task_id = "task_b_001"
    B-->>Orch: TaskStatusUpdate: WORKING
    B-->>Orch: TaskStatusUpdate: COMPLETED {artifacts: [result]}
    deactivate B

    Note over Orch: B's result incorporated. Now hand off billing to C.
    Orch->>C: SendMessage {transfer_context: {state: {...}}}
    C-->>Orch: task_id = "task_c_001"

    Orch->>Orch: own task → TRANSFERRED {task_id: "task_c_001"}
    Note over Orch: Orchestrator's task is terminal.
    Note over C: C continues with full transfer_context.
```
````

---

## 6. Agent Generation Guidelines

When an agent generates a diagram (e.g., as part of a community report or spec):

1. **Choose the type:** Flowchart for relationships/tiers, StateDiagram for lifecycles, Lattice for capability sets, Sequence for protocol flows.
2. **Apply the comment header** with diagram-type and purpose.
3. **Use the standard class palette.** Copy the `classDef` lines from this spec.
4. **Test in Obsidian** (or render via `mmdc` CLI) before committing. Mermaid syntax errors are silent in some renderers.
5. **Link the diagram's note** with a wikilink from the note it illustrates: `See diagram in [[spec-visual-vault-language]]`.
6. **Keep diagrams current.** When a note's content changes materially, update its diagrams. Stale diagrams are worse than no diagrams — they mislead.

---

## References
- [[a2a-protocol]] — source for state machine examples
- [[lit-mcp-architecture]] — source for MCP lifecycle sequence
- [[capability-lattice-spec]] — source for lattice examples
- [[rust-tier-0-patterns]] — source for tier architecture diagram
- [[pattern-dynamic-delegation]]
- [[pattern-progressive-handoff]]
- [[pattern-capability-gating]]
- [[agent-note-conventions]]
- [[system-index]]
