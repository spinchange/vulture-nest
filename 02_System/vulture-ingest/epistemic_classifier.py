from __future__ import annotations

from dataclasses import dataclass, field
from datetime import datetime, timedelta, timezone
from enum import IntEnum
from typing import Any


class EpistemicTier(IntEnum):
    T0_FABRICATION = 0
    T1_WEAK = 1
    T2_UNMARKED_INFERENCE = 2
    T3_STALE = 3
    T4_CONFLICT = 4
    T5_VERIFIED = 5


TIER_LABELS: dict[EpistemicTier, str] = {
    EpistemicTier.T0_FABRICATION: "T0 — Fabrication",
    EpistemicTier.T1_WEAK: "T1 — Weak Evidence",
    EpistemicTier.T2_UNMARKED_INFERENCE: "T2 — Unmarked Inference",
    EpistemicTier.T3_STALE: "T3 — Stale Evidence",
    EpistemicTier.T4_CONFLICT: "T4 — Conflict",
    EpistemicTier.T5_VERIFIED: "T5 — Verified",
}

TIER_ACTIONS: dict[EpistemicTier, str] = {
    EpistemicTier.T0_FABRICATION: "Reject immediately.",
    EpistemicTier.T1_WEAK: "Flag for human arbitration.",
    EpistemicTier.T2_UNMARKED_INFERENCE: "Annotate as derived inference and proceed.",
    EpistemicTier.T3_STALE: "Stamp as stale; queue re-ingestion.",
    EpistemicTier.T4_CONFLICT: "Trigger Conflict Resolution protocol.",
    EpistemicTier.T5_VERIFIED: "Eligible for promotion.",
}

# Inference language that requires a [Derived] annotation
_INFERENCE_WORDS = frozenset(
    ["therefore", "thus", "implies", "implies that", "it follows", "suggests that", "we can conclude"]
)

# Negation patterns used for lightweight contradiction detection
_NEGATION_PATTERNS = (" not ", " no ", " never ", " cannot ", " doesn't ", " isn't ", " aren't ", " won't ")


@dataclass
class EvidenceChunk:
    chunk_id: str
    source_record_id: str
    similarity_score: float
    retrieved_at: str  # ISO 8601
    content: str = ""


@dataclass
class ClassificationResult:
    tier: EpistemicTier
    label: str
    action: str
    reasoning: str
    chunks_evaluated: int
    flags: list[str] = field(default_factory=list)

    def to_dict(self) -> dict[str, Any]:
        return {
            "tier": int(self.tier),
            "label": self.label,
            "action": self.action,
            "reasoning": self.reasoning,
            "chunks_evaluated": self.chunks_evaluated,
            "flags": self.flags,
        }


def _parse_timestamp(ts: str) -> datetime:
    try:
        dt = datetime.fromisoformat(ts.replace("Z", "+00:00"))
        if dt.tzinfo is None:
            dt = dt.replace(tzinfo=timezone.utc)
        return dt
    except (ValueError, AttributeError):
        return datetime.now(timezone.utc)


def classify_claim(
    claim_text: str,
    chunks: list[EvidenceChunk],
    *,
    existing_wiki_claims: list[str] | None = None,
    min_similarity: float = 0.78,
    freshness_days: int = 90,
) -> ClassificationResult:
    """Classify a single synthesis claim against the T0–T5 epistemic risk tiers."""
    flags: list[str] = []
    now = datetime.now(timezone.utc)
    stale_cutoff = now - timedelta(days=freshness_days)

    # T0 — No evidence whatsoever
    if not chunks:
        return ClassificationResult(
            tier=EpistemicTier.T0_FABRICATION,
            label=TIER_LABELS[EpistemicTier.T0_FABRICATION],
            action=TIER_ACTIONS[EpistemicTier.T0_FABRICATION],
            reasoning="No evidence chunks provided for this claim.",
            chunks_evaluated=0,
            flags=["no_evidence"],
        )

    strong_chunks = [c for c in chunks if c.similarity_score >= min_similarity]
    fresh_strong = [c for c in strong_chunks if _parse_timestamp(c.retrieved_at) >= stale_cutoff]

    # T1 — All chunks fall below similarity threshold
    if not strong_chunks:
        max_score = max(c.similarity_score for c in chunks)
        return ClassificationResult(
            tier=EpistemicTier.T1_WEAK,
            label=TIER_LABELS[EpistemicTier.T1_WEAK],
            action=TIER_ACTIONS[EpistemicTier.T1_WEAK],
            reasoning=(
                f"No chunks meet the similarity threshold ({min_similarity}). "
                f"Highest score found: {max_score:.3f}."
            ),
            chunks_evaluated=len(chunks),
            flags=["low_similarity"],
        )

    # From here we have at least one strong chunk; accumulate issues and pick lowest tier
    detected = EpistemicTier.T5_VERIFIED
    reasoning_parts: list[str] = []

    # T4 — Contradiction with existing wiki claims (lightweight negation heuristic)
    if existing_wiki_claims:
        lower_claim = claim_text.lower()
        for existing in existing_wiki_claims:
            lower_existing = existing.lower()
            claim_negated = any(p in lower_claim for p in _NEGATION_PATTERNS)
            existing_negated = any(p in lower_existing for p in _NEGATION_PATTERNS)
            if claim_negated != existing_negated:
                flags.append("potential_conflict")
                detected = min(detected, EpistemicTier.T4_CONFLICT)
                reasoning_parts.append("Potential negation mismatch with an existing wiki claim.")
                break

    # T3 — Strong evidence exists but all of it is stale
    if strong_chunks and not fresh_strong:
        oldest = min(_parse_timestamp(c.retrieved_at) for c in strong_chunks)
        days_old = (now - oldest).days
        flags.append("stale_evidence")
        detected = min(detected, EpistemicTier.T3_STALE)
        reasoning_parts.append(
            f"All {len(strong_chunks)} supporting chunk(s) are stale "
            f"(oldest: {days_old} day(s) ago, threshold: {freshness_days} days)."
        )

    # T2 — Inference language present but no [Derived] annotation
    lower_claim = claim_text.lower()
    has_inference_language = any(w in lower_claim for w in _INFERENCE_WORDS)
    has_derived_annotation = "[derived]" in lower_claim or "derived:" in lower_claim
    if has_inference_language and not has_derived_annotation:
        flags.append("missing_derived_label")
        detected = min(detected, EpistemicTier.T2_UNMARKED_INFERENCE)
        reasoning_parts.append(
            "Claim contains inference language but lacks a '[Derived]' annotation."
        )

    if detected == EpistemicTier.T5_VERIFIED:
        reasoning_parts.append(
            f"{len(fresh_strong)} fresh, high-similarity chunk(s) directly support this claim."
        )

    return ClassificationResult(
        tier=detected,
        label=TIER_LABELS[detected],
        action=TIER_ACTIONS[detected],
        reasoning=" ".join(reasoning_parts),
        chunks_evaluated=len(chunks),
        flags=flags,
    )


def classify_draft(
    claims: list[dict[str, Any]],
    *,
    min_similarity: float = 0.78,
    freshness_days: int = 90,
    existing_wiki_claims: list[str] | None = None,
) -> dict[str, Any]:
    """Classify all claims in a synthesis draft.

    Each claim dict must have:
      - "text": str — the claim statement
      - "chunks": list[dict] — evidence chunks with chunk_id, source_record_id,
        similarity_score, retrieved_at, and optional content fields
    """
    results: list[dict[str, Any]] = []
    overall = EpistemicTier.T5_VERIFIED

    for claim in claims:
        text = claim.get("text", "")
        evidence = [
            EvidenceChunk(
                chunk_id=c.get("chunk_id", ""),
                source_record_id=c.get("source_record_id", ""),
                similarity_score=float(c.get("similarity_score", 0.0)),
                retrieved_at=c.get("retrieved_at", ""),
                content=c.get("content", ""),
            )
            for c in claim.get("chunks", [])
        ]
        result = classify_claim(
            text,
            evidence,
            existing_wiki_claims=existing_wiki_claims,
            min_similarity=min_similarity,
            freshness_days=freshness_days,
        )
        overall = min(overall, result.tier)
        results.append({"claim_text": text, **result.to_dict()})

    return {
        "overall_tier": int(overall),
        "overall_label": TIER_LABELS[overall],
        "overall_action": TIER_ACTIONS[overall],
        "claim_count": len(results),
        "claim_results": results,
    }
