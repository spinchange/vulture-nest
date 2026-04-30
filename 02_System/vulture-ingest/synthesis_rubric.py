from __future__ import annotations

import re
from dataclasses import dataclass, field
from typing import Any


_SCOPE_PATTERNS = [
    re.compile(r"^#+\s+scope\s+statement", re.IGNORECASE | re.MULTILINE),
    re.compile(r"\*\*scope\s+statement\*\*", re.IGNORECASE),
    re.compile(r"scope\s+statement\s*:", re.IGNORECASE),
    re.compile(r"^#+\s+scope", re.IGNORECASE | re.MULTILINE),
]

# Phrases that suggest a note is drifting across multiple concepts
_BOUNDARY_PHRASES = [
    "another aspect",
    "on a different topic",
    "also covers",
    "this note also",
    "second concept",
    "additionally, this",
    "furthermore, this note",
    "unrelated to the above",
]

_MAX_SECTIONS = 5
_MAX_WORDS = 800
_MIN_WORDS = 50
_ATOMICITY_DEDUCTION_PER_BOUNDARY = 0.15


@dataclass
class RubricResult:
    passed: bool
    word_count: int
    section_count: int
    has_scope_statement: bool
    atomicity_score: float  # 0.0–1.0; 1.0 = fully atomic
    issues: list[str] = field(default_factory=list)
    suggestions: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {
            "passed": self.passed,
            "word_count": self.word_count,
            "section_count": self.section_count,
            "has_scope_statement": self.has_scope_statement,
            "atomicity_score": round(self.atomicity_score, 2),
            "issues": self.issues,
            "suggestions": self.suggestions,
        }


def check_synthesis_scope(draft_text: str) -> RubricResult:
    """Evaluate a synthesis draft for atomicity and scope statement presence.

    Returns a RubricResult with a pass/fail verdict, atomicity score, and
    actionable suggestions for any issues found.
    """
    issues: list[str] = []
    suggestions: list[str] = []
    deductions = 0.0

    word_count = len(draft_text.split())
    sections = re.findall(r"^#+\s+.+", draft_text, re.MULTILINE)
    section_count = len(sections)
    has_scope = any(p.search(draft_text) for p in _SCOPE_PATTERNS)

    if word_count < _MIN_WORDS:
        issues.append(f"Draft is too short ({word_count} words; minimum {_MIN_WORDS}).")
        suggestions.append("Expand with additional evidence-backed detail before promoting.")
        deductions += 0.3

    elif word_count > _MAX_WORDS:
        issues.append(f"Draft is too long ({word_count} words; maximum {_MAX_WORDS}).")
        suggestions.append(
            "Consider splitting into multiple atomic notes — each covering exactly one concept."
        )
        deductions += 0.2

    if section_count > _MAX_SECTIONS:
        issues.append(f"Too many sections ({section_count}; maximum {_MAX_SECTIONS}).")
        suggestions.append(
            "Each YANP permanent note should cover one concept. "
            "Extract sub-sections into child notes and link them."
        )
        deductions += 0.25

    if not has_scope:
        issues.append("No scope statement found.")
        suggestions.append(
            "Add a '## Scope Statement' section that names the single concept this note covers "
            "and explicitly excludes adjacent topics."
        )
        deductions += 0.2

    lower = draft_text.lower()
    hit_phrases = [p for p in _BOUNDARY_PHRASES if p in lower]
    if hit_phrases:
        issues.append(
            f"Possible concept-boundary crossing detected "
            f"({len(hit_phrases)} phrase(s): {hit_phrases})."
        )
        suggestions.append(
            "Review whether this note addresses more than one concept. "
            "Split at the boundary and cross-link the resulting notes."
        )
        deductions += _ATOMICITY_DEDUCTION_PER_BOUNDARY * len(hit_phrases)

    atomicity_score = max(0.0, 1.0 - deductions)
    return RubricResult(
        passed=len(issues) == 0,
        word_count=word_count,
        section_count=section_count,
        has_scope_statement=has_scope,
        atomicity_score=atomicity_score,
        issues=issues,
        suggestions=suggestions,
    )
