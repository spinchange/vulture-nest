---
title: Codex Handoff — Roadmap Sprint 2026-04-27
author: claude-sonnet-4-6
date: '2026-04-27'
status: archived
type: fleeting
targets: [codex]
aliases: [codex-roadmap-handoff-april]
---

# Codex Handoff — Roadmap Sprint

Hey Codex. Four implementation tasks from a new-computer setup session. All are PowerShell 7 (`pwsh`) — no PS5. Ordered by dependency; do them in sequence.

---

## Task 1 — Commit Untracked Files

These artifacts exist and are untracked. Commit them before doing anything else so they're safe:

```powershell
Set-Location "C:\Users\executor\Documents\vulture-nest"
git add 02_System/verbalized-sampling.ps1
git add verify_db.ps1
git add -A 02_System/prototypes/
git add .gemini/
git status  # review before committing
git commit -m "chore(tracking): capture untracked experiment artifacts and tooling"
```

Skip any file that looks like it shouldn't be committed (check `.gitignore` first — `wiki.db`, `target/`, `__pycache__/` are excluded).

---

## Task 2 — Structured Seam Schema in PoShWiKi

**Problem:** `New-WikiSeam` in `02_System/poshwiki-tools.ps1` writes a prose handoff note but nothing structured to SQLite. The next agent can't query seam state.

**Deliverable:** Add a `Seams` table to `wiki.db` and update `New-WikiSeam` to write a row.

Schema:
```sql
CREATE TABLE IF NOT EXISTS Seams (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at  TEXT NOT NULL DEFAULT (datetime('now')),
    agent       TEXT NOT NULL,         -- who wrote the seam
    target      TEXT,                  -- who it's for (nullable = any)
    goal        TEXT NOT NULL,         -- what was being worked toward
    seam        TEXT NOT NULL,         -- current state / stopping point
    next_step   TEXT NOT NULL,         -- what the next agent should do first
    note_path   TEXT                   -- path to the markdown handoff note if one exists
);
```

Update `New-WikiSeam` signature:
```powershell
function New-WikiSeam {
    param(
        [string]$Agent = "claude",
        [string]$Target,
        [string]$Goal,
        [string]$Seam,
        [string]$NextStep,
        [string]$NotePath
    )
    # existing markdown write logic (keep it)
    # + new: INSERT INTO Seams (agent, target, goal, seam, next_step, note_path)
}
```

Also add a `Get-LastSeam` function:
```powershell
function Get-LastSeam {
    param([string]$Target)  # filter by target agent
    # SELECT * FROM Seams WHERE target = $Target OR target IS NULL ORDER BY created_at DESC LIMIT 1
}
```

---

## Task 3 — Debate Log Table + New-DebateLog

**Problem:** Adversarial debates between agents produce no durable structured record.

**Deliverable:** Add a `Debates` table and `New-DebateLog` function to `poshwiki-tools.ps1`.

Schema:
```sql
CREATE TABLE IF NOT EXISTS Debates (
    id           INTEGER PRIMARY KEY AUTOINCREMENT,
    created_at   TEXT NOT NULL DEFAULT (datetime('now')),
    topic        TEXT NOT NULL,
    participants TEXT NOT NULL,   -- JSON array: '["claude","gemini"]'
    hypothesis   TEXT,
    verdict      TEXT,            -- confirmed | refuted | inconclusive | split | ongoing
    entry_path   TEXT             -- relative path to 04_Experiments/.../entry.md
);
```

Function:
```powershell
function New-DebateLog {
    param(
        [string]$Topic,
        [string[]]$Participants,
        [string]$Hypothesis,
        [string]$Verdict,
        [string]$EntryPath
    )
    # INSERT INTO Debates ...
    # return the new row id
}
```

---

## Task 4 — New-Experiment Scaffolding Script

**Deliverable:** `02_System/new-experiment.ps1`

Creates a dated experiment directory under `04_Experiments/` and writes a pre-filled `entry.md`.

```powershell
param(
    [Parameter(Mandatory)][string]$Slug,
    [ValidateSet("run","debate","evaluation")][string]$Type = "run",
    [string[]]$Participants = @("human"),
    [string]$Hypothesis = ""
)

$date = Get-Date -Format "yyyy-MM-dd"
$dir  = "04_Experiments\${date}_${Slug}"
New-Item -ItemType Directory -Path $dir -Force | Out-Null

$frontmatter = @"
---
title: $Slug
author: human
date: '$date'
status: active
type: experiment
experiment-type: $Type
participants: [$($Participants -join ', ')]
hypothesis: $Hypothesis
result: ''
verdict: ongoing
aliases: []
---

# $Slug

## Hypothesis
$Hypothesis

## Setup


## Run Log


## Results


## Outcome

"@

Set-Content -Path "$dir\entry.md" -Value $frontmatter -Encoding UTF8
Write-Host "Created: $dir\entry.md"
```

---

## Task 5 — Git Attribution Convention

**Problem:** All commits are attributed to `gemini-cli`. Human commits are invisible in the audit trail.

**Deliverable:** A PS7 function `Invoke-HumanCommit` in `02_System/poshwiki-tools.ps1` that temporarily overrides the local git author for one commit:

```powershell
function Invoke-HumanCommit {
    param([string]$Message)
    # git -c user.name="spinchange" -c user.email="cduffy@ranchcryogenics.com" commit -m "[human] $Message"
}
```

Simple. No hooks. The `[human]` prefix in the message is the queryable signal. Agents never use this function.

---

## After All Tasks

1. Run `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/run-maintenance.ps1`
2. Run `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/audit-yanp.ps1`
3. Export PoShWiKi pages: `pwsh -NoProfile -ExecutionPolicy Bypass -File 02_System/export-poshwiki-pages.ps1`
4. Commit everything with: `git commit -m "feat(tooling): structured seams, debate log, experiment scaffold, human attribution"`
5. Write your seam using `New-WikiSeam` (now with SQLite!) targeting Gemini

---

## References
- [[productivity-roadmap-2026-04-27]]
- [[experiment-capture-protocol]]
- [[gemini-roadmap-sprint-handoff-2026-04-27]]
- [[poshwiki]]
- [[visitor-directives]]
- [[gemini-build-sprint-handoff]]
