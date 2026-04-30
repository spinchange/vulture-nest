from __future__ import annotations

from dataclasses import dataclass
from enum import Enum
from typing import Any


class ConflictType(str, Enum):
    DIRECT_CONTRADICTION = "direct_contradiction"
    VERSION_SKEW = "version_skew"
    SCOPE_OVERLAP = "scope_overlap"


RESOLUTION_PATHS = ("Update", "Narrow", "Parallelize", "Escalate")

# Conflict Report schema: the arbitrator LLM must produce JSON matching this shape.
CONFLICT_REPORT_SCHEMA = {
    "type": "object",
    "required": ["conflict_type", "resolution", "rationale", "auth_required"],
    "properties": {
        "conflict_type": {"type": "string", "enum": [c.value for c in ConflictType]},
        "resolution": {"type": "string", "enum": list(RESOLUTION_PATHS)},
        "rationale": {"type": "string"},
        "scope_qualifier": {"type": ["string", "null"]},
        "condition_a": {"type": ["string", "null"]},
        "condition_b": {"type": ["string", "null"]},
        "auth_required": {"type": "boolean"},
        "auth_reason": {"type": ["string", "null"]},
    },
}

_SYSTEM_PREAMBLE = (
    "You are the Arbitrator in the Vulture Nest knowledge pipeline. "
    "Your role is to resolve conflicts between incoming synthesis claims and existing permanent notes. "
    "You must choose exactly one resolution path and produce a structured Conflict Report as JSON. "
    "Do not include any text outside the JSON block."
)

_TEMPLATES: dict[ConflictType, str] = {
    ConflictType.DIRECT_CONTRADICTION: """\
{preamble}

## Conflict Type: Direct Contradiction

An incoming synthesis claim directly contradicts a claim in an existing permanent note.

### Incoming Claim
{incoming_claim}

### Conflicting Existing Note
- **Note stem:** {existing_note_stem}
- **Existing claim:** {existing_claim}

### Evidence Comparison
Incoming evidence (similarity: {incoming_similarity:.2f}, retrieved: {incoming_retrieved_at}):
> {incoming_evidence}

Existing note evidence (retrieved: {existing_retrieved_at}):
> {existing_evidence}

## Resolution Paths
- **Update** — The incoming claim is fresher or more authoritative. Supersede the existing claim.
- **Narrow** — The existing claim is too general. Add a scope qualifier to both so they coexist.
- **Parallelize** — Both are true under different conditions. Create conditioned variant notes.
- **Escalate** — High-stakes contradiction; insufficient evidence to decide. Trigger AUTH_REQUIRED.

## Output
Produce a Conflict Report as JSON only:
```json
{{
  "conflict_type": "direct_contradiction",
  "resolution": "<Update|Narrow|Parallelize|Escalate>",
  "rationale": "<one paragraph explaining your choice>",
  "scope_qualifier": "<qualifier string if Narrow, else null>",
  "condition_a": "<condition for claim A if Parallelize, else null>",
  "condition_b": "<condition for claim B if Parallelize, else null>",
  "auth_required": <true if Escalate, else false>,
  "auth_reason": "<escalation reason if auth_required, else null>"
}}
```
""",

    ConflictType.VERSION_SKEW: """\
{preamble}

## Conflict Type: Version Skew

An incoming claim may conflict with an existing note due to version or temporal context differences.

### Incoming Claim
{incoming_claim}

### Existing Note
- **Note stem:** {existing_note_stem}
- **Existing claim:** {existing_claim}

### Version Context
- Incoming source version: {incoming_version}
- Existing note version context: {existing_version}

## Resolution Paths
- **Update** — The incoming version supersedes the old claim. Archive the existing version reference.
- **Narrow** — Both are valid; add version scope qualifiers (e.g., "As of v2.x:") to each claim.
- **Parallelize** — Both are true and should coexist as version-conditioned sibling notes.
- **Escalate** — Version lineage is unclear; a human must determine the authoritative source.

## Output
Produce a Conflict Report as JSON only:
```json
{{
  "conflict_type": "version_skew",
  "resolution": "<Update|Narrow|Parallelize|Escalate>",
  "rationale": "<one paragraph explaining your choice>",
  "scope_qualifier": "<version qualifier string if Narrow, else null>",
  "condition_a": "<version condition for claim A if Parallelize, else null>",
  "condition_b": "<version condition for claim B if Parallelize, else null>",
  "auth_required": <true if Escalate, else false>,
  "auth_reason": "<escalation reason if auth_required, else null>"
}}
```
""",

    ConflictType.SCOPE_OVERLAP: """\
{preamble}

## Conflict Type: Scope Overlap

An incoming claim overlaps with an existing permanent note without directly contradicting it.
The overlap may indicate redundancy, a more specific variant, or a complementary angle.

### Incoming Claim
{incoming_claim}

### Existing Note
- **Note stem:** {existing_note_stem}
- **Existing claim:** {existing_claim}

### Overlap Description
{overlap_description}

## Resolution Paths
- **Update** — The incoming claim subsumes the existing one and is more complete. Replace it.
- **Narrow** — Restrict the existing note's scope so both coexist without ambiguity.
- **Parallelize** — Both address the same topic from different valid angles. Keep both with cross-links.
- **Escalate** — Scope boundary is contested; a human must adjudicate which angle is canonical.

## Output
Produce a Conflict Report as JSON only:
```json
{{
  "conflict_type": "scope_overlap",
  "resolution": "<Update|Narrow|Parallelize|Escalate>",
  "rationale": "<one paragraph explaining your choice>",
  "scope_qualifier": "<restriction to apply to existing note if Narrow, else null>",
  "condition_a": "<what claim A uniquely covers if Parallelize, else null>",
  "condition_b": "<what claim B uniquely covers if Parallelize, else null>",
  "auth_required": <true if Escalate, else false>,
  "auth_reason": "<escalation reason if auth_required, else null>"
}}
```
""",
}


@dataclass
class ConflictReport:
    conflict_type: str
    resolution: str
    rationale: str
    scope_qualifier: str | None
    condition_a: str | None
    condition_b: str | None
    auth_required: bool
    auth_reason: str | None

    def to_dict(self) -> dict[str, Any]:
        return {
            "conflict_type": self.conflict_type,
            "resolution": self.resolution,
            "rationale": self.rationale,
            "scope_qualifier": self.scope_qualifier,
            "condition_a": self.condition_a,
            "condition_b": self.condition_b,
            "auth_required": self.auth_required,
            "auth_reason": self.auth_reason,
        }

    @property
    def requires_hitl(self) -> bool:
        return self.auth_required or self.resolution == "Escalate"


def get_template(conflict_type: str, **context: Any) -> str:
    """Return a filled arbitration prompt for the given conflict type.

    Required context keys vary by conflict_type — see _TEMPLATES for each set.
    All templates accept the optional `preamble` override; if omitted, the
    canonical system preamble is injected automatically.
    """
    try:
        ct = ConflictType(conflict_type)
    except ValueError:
        valid = [c.value for c in ConflictType]
        raise ValueError(f"Unknown conflict_type '{conflict_type}'. Valid values: {valid}")

    context.setdefault("preamble", _SYSTEM_PREAMBLE)
    template = _TEMPLATES[ct]
    try:
        return template.format(**context)
    except KeyError as exc:
        raise ValueError(f"Missing required template variable: {exc}") from exc


def parse_conflict_report(raw: dict[str, Any]) -> ConflictReport:
    """Parse and validate a raw arbitrator response dict into a ConflictReport."""
    resolution = raw.get("resolution", "")
    if resolution not in RESOLUTION_PATHS:
        raise ValueError(f"Invalid resolution '{resolution}'. Must be one of: {RESOLUTION_PATHS}")

    conflict_type = raw.get("conflict_type", "")
    valid_types = [c.value for c in ConflictType]
    if conflict_type not in valid_types:
        raise ValueError(f"Invalid conflict_type '{conflict_type}'. Must be one of: {valid_types}")

    auth_required = bool(raw.get("auth_required", False))
    if resolution == "Escalate" and not auth_required:
        # Escalate always implies AUTH_REQUIRED
        auth_required = True

    return ConflictReport(
        conflict_type=conflict_type,
        resolution=resolution,
        rationale=raw.get("rationale", ""),
        scope_qualifier=raw.get("scope_qualifier"),
        condition_a=raw.get("condition_a"),
        condition_b=raw.get("condition_b"),
        auth_required=auth_required,
        auth_reason=raw.get("auth_reason"),
    )
