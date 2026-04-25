# Judge Rubric Template (Multi-Agent Evaluation)

> **Goal:** Standardized scoring for agentic contributions to the vulture-nest.
> **Pass Criteria:** [Structural Integrity = 100%] AND [Weighted Total ≥ 85/100]

## Dimension 1: Structural Integrity (BINARY)
*This dimension is handled by automation (audit-yanp.ps1). Any 'Fail' here blocks the entire contribution.*

| Criteria | Status | Notes |
| :--- | :--- | :--- |
| **YANP Filename** | [Pass/Fail] | lowercase-kebab-case.md |
| **Valid Frontmatter** | [Pass/Fail] | Contains: title, author, date, status, type |
| **Unique Stem** | [Pass/Fail] | No naming collisions in the vault |

## Dimension 2: Semantic Density (Weight: 40%)
*Handled by the LLM Judge.*

- **[0-10]** Atomic focus: Does the note stick to one concept?
- **[0-10]** Information-to-Token Ratio: Is it high-signal, or is there conversational filler?
- **[0-10]** Synthesized Logic: Does it add new insight, or is it a raw copy-paste?
- **[0-10]** Technical Accuracy: Is the code or logic correct for the stated domain?

**Score:** __ / 40

## Dimension 3: Graph Integration (Weight: 30%)
*Handled by the LLM Judge.*

- **[0-15]** Inward Links: Does it correctly link to at least 2 existing notes?
- **[0-15]** Outward Hooks: Does it provide hooks for future notes (redlinks or logic gaps)?

**Score:** __ / 30

## Dimension 4: Protocol Adherence (Weight: 20%)
*Handled by the LLM Judge.*

- **[0-10]** Visitor Directives: Did the agent follow the `visitor-directives.md` for this task?
- **[0-10]** Language Style: Does it match the established senior-engineer tone?

**Score:** __ / 20

## Dimension 5: Tool Usage (Weight: 10%)
*Handled by the LLM Judge.*

- **[0-10]** Efficiency: Did the agent use the correct tools (e.g., `replace` for surgical edits vs `write_file`)?

**Score:** __ / 10

---
### Final Evaluation
- **Total Weighted Score:** __ / 100
- **Verdict:** [ACCEPTED | REVISIONS REQUIRED | REJECTED]
