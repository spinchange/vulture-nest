---
date: 2026-05-01
author: ChatGPT
toc: true
---

# Project Definition Worksheet

Use this worksheet at the start of a software project to define what is being built, why it matters, what version 1 must do, and what shape the build should take.  

Fill this out before deep implementation. Brevity is fine. Clarity matters more than completeness.

---

# 1. Project Identity

## Project Name
**Working name:**  
[Project name]

**Alternate names / rejected names:**  
- 
- 
- 

## One-Sentence Definition
Complete this sentence:

> This is a __________ that helps __________ do __________ by __________.

**Draft definition:**  
[Write one sentence]

## Project Type
Select or fill in:

- [ ] Script
- [ ] CLI tool
- [ ] TUI app
- [ ] Desktop app
- [ ] Web app
- [ ] Local web app
- [ ] Service / daemon
- [ ] Library
- [ ] Automation
- [ ] Agent runner
- [ ] Document system
- [ ] Other: __________

## Intended Lifespan
- [ ] One-off
- [ ] Short-term utility
- [ ] Durable personal tool
- [ ] Team/internal system
- [ ] Foundation for a larger product

---

# 2. Problem and Purpose

## What problem does this solve?
Describe the real problem, not just the software idea.

[Write a short paragraph]

## What friction exists now?
What is annoying, slow, fragmented, repetitive, fragile, or unclear today?

- 
- 
- 

## Why does this project deserve to exist?
What makes it worth building instead of continuing with the current way?

[Write a short paragraph]

## What changes after this exists?
What will the user be able to do that they cannot do now, or cannot do well now?

- 
- 
- 

---

# 3. User and Environment

## Primary User
Who is the first and most important user?

[Describe the user]

## User Profile
- Technical comfort level:  
- Patience level:  
- Frequency of use:  
- Main working environment:  
- Main device/platform:  

## What does the user already know?
What assumptions can the software safely make?

- 
- 
- 

## What should the software not assume?
What should it avoid requiring?

- 
- 
- 

---

# 4. Job to Be Done

## Core Jobs
The software must let the user:

1.  
2.  
3.  
4.  
5.  

## Primary User Outcome
When the user finishes a successful session, what should they have accomplished?

[Write one sentence]

## Moment of Value
What is the first moment where the user will think, “Yes, this is working”?

[Describe that moment]

---

# 5. Constraints and Non-Negotiables

## Hard Constraints
This project must:

- run on __________
- store data in __________
- work with / without internet: __________
- support __________
- avoid __________
- keep data __________
- be installable via __________
- be editable/maintainable by someone with __________ skill

## Operational Constraints
- Budget constraints:
- Time constraints:
- Dependency constraints:
- Security/privacy constraints:
- Portability constraints:
- Performance constraints:

## Personal Constraints
What constraints come from the builder rather than the machine?

Examples:
- limited time
- learning while building
- dislike of heavy setup
- needs boring, inspectable tooling
- prefers local-first systems

[List yours]

---

# 6. Scope Control

## Must-Haves for Version 1
These are essential.

- 
- 
- 
- 
- 

## Nice-to-Haves
These would improve the project but are not required for version 1.

- 
- 
- 
- 
- 

## Explicitly Out of Scope
What should version 1 *not* try to do?

- 
- 
- 
- 
- 

## Scope Trap Warning
What tempting additions are most likely to derail the project?

- 
- 
- 

---

# 7. MVP Definition

## MVP Statement
Complete this sentence:

> Version 1 will allow the user to __________, __________, and __________. It will not yet include __________, __________, or __________.

**Draft MVP statement:**  
[Write one paragraph]

## Smallest Honest Version
What is the smallest version that is genuinely real and useful?

[Write a short paragraph]

## Why this MVP is enough
Why is this version a true proof of concept rather than a fake demo?

[Write a short paragraph]

---

# 8. System Shape

## What kind of system is this really?
Choose the closest fit:

- [ ] CRUD app
- [ ] Parser / transformer
- [ ] Search / retrieval tool
- [ ] Document workflow
- [ ] Automation runner
- [ ] Agent orchestration layer
- [ ] Data dashboard
- [ ] Note or knowledge system
- [ ] Wrapper over existing tools
- [ ] Event-driven system
- [ ] Other: __________

## Architectural Character
Which of these best describes the project?

- [ ] Mostly UI-heavy
- [ ] Mostly logic-heavy
- [ ] Mostly data-model-heavy
- [ ] Mostly integration-heavy
- [ ] Mostly workflow-heavy
- [ ] Mostly infra/setup-heavy

## Core Components
List the major moving pieces.

- Input layer:
- Command or interaction model:
- State model:
- Business logic:
- Storage/persistence:
- Output/rendering:
- Configuration:
- Logging/error handling:
- External integrations:
- Other:

---

# 9. Data Model

## Main Entities
What are the primary nouns in the system?

- 
- 
- 
- 
- 

## For Each Entity, Define:
### Entity Name
**Purpose:**  
[What it is]

**Required fields:**  
- 
- 
- 

**Optional fields:**  
- 
- 
- 

**Relationships:**  
- belongs to:
- links to:
- creates:
- depends on:

**Changes over time:**  
[What is mutable?]

(Repeat as needed)

## Source of Truth
What is the canonical source of data?

[Write one answer]

## Stored vs Derived
What must be stored permanently, and what can be computed on demand?

**Stored:**  
- 
- 
- 

**Derived:**  
- 
- 
- 

---

# 10. Core User Flows

Describe the most important things the user will do.

## Flow 1: [Name]
1. User does:
2. System responds by:
3. Data changes:
4. Output shown:
5. Failure modes:

## Flow 2: [Name]
1. User does:
2. System responds by:
3. Data changes:
4. Output shown:
5. Failure modes:

## Flow 3: [Name]
1. User does:
2. System responds by:
3. Data changes:
4. Output shown:
5. Failure modes:

(Add more if needed)

---

# 11. Interface Decision

## Primary Interface
- [ ] CLI
- [ ] TUI
- [ ] GUI desktop
- [ ] Web UI
- [ ] Local web UI
- [ ] API
- [ ] Chat interface
- [ ] Background process
- [ ] Other: __________

## Why this interface fits
Complete this sentence:

> The interface is __________ because the user needs __________ more than __________.

**Answer:**  
[Write one paragraph]

## Interaction Style
- [ ] Keyboard-first
- [ ] Mouse-first
- [ ] Form-based
- [ ] Command-based
- [ ] Search-centric
- [ ] Browse-centric
- [ ] Mixed

## UX Priorities
Rank or list the most important UX qualities:

- speed
- discoverability
- clarity
- low setup friction
- error tolerance
- power-user efficiency
- visual polish
- inspectability
- portability

**Top priorities:**  
1.  
2.  
3.  

---

# 12. Storage and Persistence

## Storage Choice
- [ ] Flat files
- [ ] Markdown files
- [ ] JSON
- [ ] YAML
- [ ] SQLite
- [ ] Postgres
- [ ] Embedded DB
- [ ] Cloud storage
- [ ] Mixed
- [ ] Other: __________

## Why this storage choice fits
[Write a short paragraph]

## Storage Requirements
- Human-readable?
- Easily backed up?
- Git-friendly?
- Multi-user?
- Offline?
- Queryable?
- Auditable?
- Migration-friendly?

## Backup / Recovery Expectations
How should the user recover from mistakes or corruption?

[Write notes]

---

# 13. Stack Decision

## Proposed Stack
**Language:**  
[Language]

**Framework/runtime:**  
[Runtime/framework]

**Storage:**  
[Storage]

**UI approach:**  
[UI approach]

**Packaging/distribution:**  
[How delivered]

## Why this stack is appropriate
Answer in terms of the project and the builder, not just trendiness.

[Write one paragraph]

## Stack Rejection Notes
What plausible stacks did you reject, and why?

- Rejected:
  - because:
- Rejected:
  - because:
- Rejected:
  - because:

---

# 14. Safety, Error Handling, and Trust

## What can go wrong?
List likely failures.

- 
- 
- 
- 

## What must never happen?
List unacceptable failures.

- silent data loss
- destructive action without warning
- corrupted state without notice
- misleading output

Add project-specific items:
- 
- 
- 

## Error-Handling Rules
When something fails, the software should:

- 
- 
- 
- 

## Destructive Actions
What actions need preview, confirmation, undo, or dry-run?

- 
- 
- 

---

# 15. Milestones

## Milestone 1
**Name:**  
[Name]

**Goal:**  
[Goal]

**Done when:**  
- 
- 
- 

## Milestone 2
**Name:**  
[Name]

**Goal:**  
[Goal]

**Done when:**  
- 
- 
- 

## Milestone 3
**Name:**  
[Name]

**Goal:**  
[Goal]

**Done when:**  
- 
- 
- 

## Milestone 4
**Name:**  
[Name]

**Goal:**  
[Goal]

**Done when:**  
- 
- 
- 

(Add more if needed)

---

# 16. Testing and Validation

## What needs to be tested most?
- 
- 
- 

## Unit Test Candidates
- 
- 
- 

## Integration Test Candidates
- 
- 
- 

## Manual Test Scenarios
- 
- 
- 

## First Real-World Trial
What real usage scenario should prove whether this project is actually useful?

[Describe it]

---

# 17. Risks and Unknowns

## Known Risks
- 
- 
- 
- 

## Unknowns That Need Answers
- 
- 
- 
- 

## What could force a redesign later?
- 
- 
- 

## What is most likely to be harder than expected?
- UI
- parsing
- syncing
- architecture
- performance
- packaging
- dependency issues
- edge cases
- other: __________

---

# 18. Version 2 Pressure

## What will version 2 probably want?
- 
- 
- 
- 

## What decisions should leave room for that?
- 
- 
- 

## What should *not* be optimized for yet?
- 
- 
- 

---

# 19. Success Criteria

## Success means:
- the user can __________
- the system can __________
- the builder can maintain __________
- the workflow feels __________
- the project is used for __________

## Failure means:
- 
- 
- 
- 

## One-Month Check
A month after version 1, how will we know whether this deserves continued investment?

[Write a short paragraph]

---

# 20. Final Sanity Check

Answer honestly:

- Is this solving a real problem?  
  [Yes / No / Partly]

- Is version 1 small enough?  
  [Yes / No / Partly]

- Is the stack appropriate for the builder?  
  [Yes / No / Partly]

- Is the data model clear enough to begin?  
  [Yes / No / Partly]

- Are the top user flows obvious?  
  [Yes / No / Partly]

- Could this actually be finished?  
  [Yes / No / Partly]

- Does this preserve the spirit of the idea?  
  [Yes / No / Partly]

## If any answer is “No” or “Partly,” note why:
- 
- 
- 

---

# 21. Project Definition Summary

After completing the worksheet, summarize the project here.

## Summary Paragraph
[Write one paragraph]

## Project in Plain Language
Explain it so a smart non-specialist could understand it.

[Write 3–6 sentences]

## Build Recommendation
What should happen next?

- [ ] Start coding
- [ ] Refine scope
- [ ] Redesign data model
- [ ] Build a throwaway prototype
- [ ] Write technical spec
- [ ] Make milestone plan
- [ ] Get feedback first
- [ ] Other: __________

## Immediate Next 3 Steps
1.  
2.  
3.  

---

# Optional Appendix A: Agent / Collaborator Notes

## For another LLM or developer
What should a collaborator understand immediately about this project?

- 
- 
- 

## Preferred collaboration style
- [ ] Spec first
- [ ] MVP first
- [ ] Prototype first
- [ ] Test-first
- [ ] Incremental refactor
- [ ] Handoff-driven

## Notes on tone / priorities / philosophy
Examples:
- boring over clever
- inspectable over magical
- local-first over cloud-first
- deterministic over agentic
- flat files over hidden state

[List yours]

---

# Optional Appendix B: Quick Fill Version

Use this when you need a compressed intake form.

## Name
[Project name]

## One-line definition
This is a __________ that helps __________ do __________ by __________.

## User
[Primary user]

## Problem
[What problem it solves]

## Must-haves
- 
- 
- 

## Out of scope
- 
- 
- 

## MVP
[One short paragraph]

## Main entities
- 
- 
- 

## Main flows
1.  
2.  
3.  

## Stack
- Language:
- Interface:
- Storage:
- Packaging:

## Milestones
1.  
2.  
3.  

## Risks
- 
- 
- 

## Success looks like
- 
- 
- 