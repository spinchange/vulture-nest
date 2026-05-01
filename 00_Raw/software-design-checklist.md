# Software Design Checklist

## 1. Name the thing correctly

Before anything else, ask:

* What am I actually making?
* Is this a script, app, service, library, automation, prototype, or product seed?
* Is it a one-user tool, a team tool, or a public-facing product?
* Is this meant to be disposable, durable, or foundational?

**Output:** a one-sentence definition.

**Template:**
“This is a ___ that helps ___ do ___ by ___.”

Example:
“This is a local terminal app that helps a user browse and search personal notes by presenting them as a keyboard-driven document space.”

---

## 2. Define the job to be done

Ask:

* What problem is this solving?
* What pain or friction exists now?
* What will the user be able to do after this exists that they cannot do now?
* What would make the user say, “Yes, this is working”?

**Output:** 3–5 concrete jobs.

**Template:**
The software must let the user:

* ---
* ---
* ---

---

## 3. Identify the primary user

Ask:

* Who is this for first?
* What is their technical level?
* How patient are they?
* What do they already know?
* What environment are they in?

**Output:** one primary user profile.

**Template:**
“The first user is someone who is ___, working on ___, and needs ___ without having to ___.”

---

## 4. Capture non-negotiable constraints

Ask:

* What platform must it run on?
* Must it work offline?
* Must it be portable?
* Must it avoid dependencies?
* Must it be cheap or free to operate?
* Must it be hackable by a non-expert?
* Are there security, privacy, or auditability needs?

**Output:** a hard-constraints list.

**Template:**
This project must:

* run on ___
* store data in ___
* avoid ___
* support ___
* not require ___

---

## 5. Separate must-haves from nice-to-haves

Ask:

* What is essential for version 1?
* What is merely attractive?
* What would be painful to leave out?
* What can wait safely?

**Output:** two buckets.

**Template:**
**Must-have**

* ---
* ---
* ---

**Nice-to-have**

* ---
* ---
* ---

If a feature does not support the core job, it probably belongs in nice-to-have.

---

## 6. State the MVP in one paragraph

Ask:

* What is the smallest version that is real?
* What version proves the concept honestly?
* What version teaches the most?
* What version could actually be finished?

**Output:** one short MVP paragraph.

**Template:**
“MVP version 1 will allow the user to ___, ___, and ___. It will not yet include ___, ___, or ___.”

---

## 7. Define success and failure

Ask:

* What would success look like after one day, one week, one month?
* What would make this clearly not good enough?
* What user actions prove value?

**Output:** measurable success signals.

**Template:**
Success means:

* the user can ___ in under ___
* the app can handle ___ without ___
* the user returns to it for ___

Failure means:

* ---
* ---
* ---

---

## 8. Choose the system type

Classify the project.

Ask:

* Is this mainly CRUD?
* Is it event-driven?
* Is it a document tool?
* Is it a parser/renderer?
* Is it a local database app?
* Is it an agent runner?
* Is it a wrapper around existing tools?
* Is it UI-heavy or logic-heavy?

**Output:** system category.

This matters because system shape predicts architecture.

---

## 9. List the main components

Ask:

* What are the core moving pieces?
* What inputs come in?
* What state must be tracked?
* What logic transforms that state?
* What outputs go back to the user?

**Output:** component list.

**Template:**
Core components:

* input layer
* command/interaction model
* state model
* business logic
* persistence/storage
* rendering/output
* configuration
* logging/error handling

---

## 10. Design the data model first

Ask:

* What are the main entities?
* What fields do they have?
* What relationships exist?
* What changes over time?
* What must be stored versus derived?

**Output:** simple entity list or schema sketch.

**Template:**
Main entities:

* Project
* Note
* Entry
* Task
* Session
* Event

For each one:

* required fields
* optional fields
* IDs
* timestamps
* relationships

A surprising number of software problems are really data-model problems in disguise.

---

## 11. Map the key user flows

Ask:

* What are the top 3 things the user will do?
* What does each flow look like step by step?
* Where can each flow fail?
* What feedback does the user get?

**Output:** 3–5 core flows.

**Template:**
Flow: create item

1. user does ___
2. system validates ___
3. system stores ___
4. system displays ___

Flow: search item

1. user enters ___
2. system checks ___
3. system returns ___

---

## 12. Choose storage intentionally

Ask:

* Flat files, SQLite, JSON, markdown, local DB, remote DB?
* Does the user need portability?
* Does the user need direct inspectability?
* Does the project need concurrency?
* Does it need schema migrations later?

**Output:** storage choice plus why.

**Rule of thumb:**

* Flat files for simple, inspectable, local-first tools
* SQLite for structured local apps
* Postgres or equivalent when multi-user or server-backed needs are real

---

## 13. Choose the runtime and stack based on reality

Ask:

* What language best fits the job?
* What language best fits the builder?
* What stack adds the least accidental complexity?
* Is UI the hard part or logic the hard part?

**Output:** stack choice with justification.

**Template:**
“We are using ___ because it gives us ___ while keeping ___ manageable.”

Examples:

* PowerShell for Windows-native automation
* Go for single-binary TUI tools
* Python for quick prototypes or data tools
* local web app for rich UI without native desktop complexity
* Rust when safety/performance/distribution matter and complexity is justified

---

## 14. Decide the interface model

Ask:

* CLI, TUI, web UI, desktop app, API, chatbot, or background process?
* Does the user need discoverability or speed?
* Is keyboard-first important?
* Is this for daily use or occasional use?

**Output:** interface choice.

**Template:**
“The interface is ___ because the user needs ___ more than ___.”

---

## 15. Plan error handling and safety early

Ask:

* What can go wrong?
* What should happen on invalid input?
* What operations are destructive?
* How will the user recover?
* What should be logged?

**Output:** basic failure-handling rules.

**Template:**
On error, the system should:

* preserve user data
* report what failed
* suggest the next step
* avoid partial silent corruption

If commands can be dangerous, add preview, confirm, undo, or dry-run.

---

## 16. Make architecture proportional

Ask:

* Am I overbuilding?
* Am I creating abstractions before they are needed?
* Am I using multiple services where one process would do?
* Am I introducing a framework just because it is popular?

**Output:** an intentionally restrained architecture.

**Rule:**
Prefer the simplest architecture that can survive the next 2–3 versions.

---

## 17. Write the first file/folder layout

Ask:

* What top-level structure will keep this understandable?
* Where do data, commands, UI, and logic live?
* Can a newcomer tell where things go?

**Output:** initial file tree.

Example:

```text
project/
  README.md
  docs/
  src/
    main.*
    ui/
    core/
    storage/
    models/
  test/
  examples/
  data/
```

Not sacred. Just clear.

---

## 18. Define milestones before coding too much

Ask:

* What are the natural checkpoints?
* What can be demonstrated after each milestone?
* What should be manually testable?

**Output:** milestone list.

**Template:**
Milestone 1: core data model exists
Milestone 2: create/read basic items
Milestone 3: editing and persistence
Milestone 4: search/filter
Milestone 5: polish and export/import

---

## 19. Build the happy path first

Ask:

* What is the most important workflow?
* Can I make that work end to end before polishing?
* Can I prove the loop from input to stored result to visible output?

**Output:** first vertical slice.

This is usually better than building isolated pieces that do not yet connect.

---

## 20. Delay polish, but not clarity

Ask:

* Can this be ugly but understandable for now?
* Are names clear?
* Are functions and modules doing one obvious thing?
* Could I come back in two weeks and still follow it?

**Output:** readable first draft, not clever first draft.

---

## 21. Test at the level of risk

Ask:

* What is most likely to break?
* What would be costly if wrong?
* What deserves unit tests?
* What deserves integration tests?
* What should be tested manually?

**Output:** lightweight test strategy.

**Template:**
Unit test:

* parsing
* validation
* scoring logic
* transforms

Integration test:

* create/save/load
* command execution
* search pipeline

Manual test:

* keyboard flows
* UI responsiveness
* error messages

---

## 22. Check for future pain points

Ask:

* What part will become hard to change later?
* Is the data model too rigid?
* Is the UI coupled too tightly to storage?
* Are commands and logic too entangled?
* Will adding one feature force rewrites?

**Output:** short architecture risk note.

---

## 23. Write a “what version 2 probably wants” note

Ask:

* What obvious expansions are coming?
* Which decisions should leave room for them?
* Which decisions should not optimize for them yet?

**Output:** a short future-facing note.

This helps avoid both tunnel vision and premature generalization.

---

## 24. Produce the core project artifacts

Before or during implementation, create:

* one-paragraph project definition
* project brief
* MVP statement
* architecture sketch
* data model sketch
* milestone plan
* handoff/build prompt if another model or developer will help

These keep the project coherent when energy drops.

---

## 25. Final pre-build sanity check

Ask these blunt questions:

* Is this solving a real problem?
* Is the first version small enough?
* Is the stack appropriate for the builder?
* Is the data model clear?
* Are the main flows obvious?
* Could this actually be finished?
* Am I preserving the spirit of the idea?

If too many answers are shaky, refine before building.

---

# Ultra-Compact Version

If you want the shortest usable version, it is this:

1. What am I making?
2. Who is it for?
3. What problem does it solve?
4. What must version 1 do?
5. What must it not require?
6. What data does it store?
7. What are the main user flows?
8. What stack best fits the job and builder?
9. What is the smallest honest MVP?
10. What are the next 3 milestones?

---

# Fill-in Template

You could literally copy this and fill it out:

## Project Definition

This is a __________ that helps __________ do __________ by __________.

## User

The primary user is __________.

## Problem

Right now they struggle with:

* ---
* ---
* ---

## Must-Haves

* ---
* ---
* ---

## Nice-to-Haves

* ---
* ---
* ---

## Constraints

* Must run on __________
* Must store data in __________
* Must avoid __________
* Must support __________

## MVP

Version 1 will let the user:

* ---
* ---
* ---

It will not yet include:

* ---
* ---
* ---

## Core Entities

* ---
* ---
* ---

## Core User Flows

1. ---
2. ---
3. ---

## Tech Stack

* Language: __________
* Interface: __________
* Storage: __________
* Why: __________

## Milestones

1. ---
2. ---
3. ---
4. ---

## Risks

* ---
* ---
* ---

## Success Looks Like

* ---
* ---
* ---

---

# use this checklist in three passes:

**Pass 1: concept pass**
Fill it out loosely and fast.

**Pass 2: hardening pass**
Cut scope, clarify entities, tighten MVP.

**Pass 3: build pass**
Turn it into a spec, file layout, and implementation plan.

If you want, I can turn this into a reusable **Project Definition worksheet** in your preferred style, especially one suited to your software-project workflow.
