"""Tests for the synthesis intelligence layer: epistemic classifier,
conflict templates, synthesis rubric, and provenance generator."""
from __future__ import annotations

import importlib.util
import sys
from datetime import datetime, timedelta, timezone
from pathlib import Path

import pytest

MODULE_DIR = Path(__file__).parent / "vulture-ingest"
if str(MODULE_DIR) not in sys.path:
    sys.path.insert(0, str(MODULE_DIR))


def _load(name: str, path: Path):
    spec = importlib.util.spec_from_file_location(name, path)
    mod = importlib.util.module_from_spec(spec)
    sys.modules[name] = mod
    spec.loader.exec_module(mod)
    return mod


ec = _load("epistemic_classifier", MODULE_DIR / "epistemic_classifier.py")
ct = _load("conflict_templates", MODULE_DIR / "conflict_templates.py")
sr = _load("synthesis_rubric", MODULE_DIR / "synthesis_rubric.py")
pv = _load("provenance", MODULE_DIR / "provenance.py")


# ── Helpers ──────────────────────────────────────────────────────────────────

def _fresh_ts() -> str:
    return datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def _stale_ts(days: int = 100) -> str:
    dt = datetime.now(timezone.utc) - timedelta(days=days)
    return dt.strftime("%Y-%m-%dT%H:%M:%SZ")


def _chunk(sim: float = 0.90, ts: str | None = None) -> dict:
    return {
        "chunk_id": "chk_test",
        "source_record_id": "sr_test",
        "similarity_score": sim,
        "retrieved_at": ts or _fresh_ts(),
        "content": "Supporting evidence text.",
    }


# ── Epistemic Classifier ──────────────────────────────────────────────────────

class TestEpistemicClassifier:
    def test_t0_no_chunks(self):
        result = ec.classify_claim("Some claim.", [])
        assert result.tier == ec.EpistemicTier.T0_FABRICATION
        assert "no_evidence" in result.flags

    def test_t1_low_similarity(self):
        chunks = [ec.EvidenceChunk("c1", "sr1", 0.50, _fresh_ts())]
        result = ec.classify_claim("Some claim.", chunks, min_similarity=0.78)
        assert result.tier == ec.EpistemicTier.T1_WEAK
        assert "low_similarity" in result.flags

    def test_t2_unmarked_inference(self):
        chunks = [ec.EvidenceChunk("c1", "sr1", 0.85, _fresh_ts())]
        result = ec.classify_claim(
            "Therefore the system implies a failure mode.", chunks, min_similarity=0.78
        )
        assert result.tier == ec.EpistemicTier.T2_UNMARKED_INFERENCE
        assert "missing_derived_label" in result.flags

    def test_t2_passes_when_derived_annotated(self):
        chunks = [ec.EvidenceChunk("c1", "sr1", 0.85, _fresh_ts())]
        result = ec.classify_claim(
            "[Derived] Therefore the system implies a failure mode.", chunks, min_similarity=0.78
        )
        assert result.tier == ec.EpistemicTier.T5_VERIFIED

    def test_t3_stale_evidence(self):
        chunks = [ec.EvidenceChunk("c1", "sr1", 0.85, _stale_ts(100))]
        result = ec.classify_claim("Some claim.", chunks, min_similarity=0.78, freshness_days=90)
        assert result.tier == ec.EpistemicTier.T3_STALE
        assert "stale_evidence" in result.flags

    def test_t5_verified(self):
        chunks = [ec.EvidenceChunk("c1", "sr1", 0.92, _fresh_ts())]
        result = ec.classify_claim("Some claim.", chunks, min_similarity=0.78)
        assert result.tier == ec.EpistemicTier.T5_VERIFIED
        assert result.flags == []

    def test_classify_draft_overall_tier_is_minimum(self):
        claims = [
            {"text": "Good claim.", "chunks": [_chunk(0.90)]},
            {"text": "No evidence claim.", "chunks": []},
        ]
        result = ec.classify_draft(claims)
        assert result["overall_tier"] == int(ec.EpistemicTier.T0_FABRICATION)
        assert result["claim_count"] == 2

    def test_to_dict_serialisable(self):
        chunks = [ec.EvidenceChunk("c1", "sr1", 0.88, _fresh_ts())]
        result = ec.classify_claim("A claim.", chunks)
        d = result.to_dict()
        assert isinstance(d["tier"], int)
        assert isinstance(d["label"], str)


# ── Conflict Templates ────────────────────────────────────────────────────────

class TestConflictTemplates:
    def _ctx_direct(self) -> dict:
        return dict(
            incoming_claim="X is always true.",
            existing_note_stem="some-note",
            existing_claim="X is never true.",
            incoming_similarity=0.92,
            incoming_retrieved_at="2026-04-01",
            incoming_evidence="Evidence A",
            existing_retrieved_at="2025-01-01",
            existing_evidence="Evidence B",
        )

    def test_direct_contradiction_template_renders(self):
        prompt = ct.get_template("direct_contradiction", **self._ctx_direct())
        assert "Direct Contradiction" in prompt
        assert "X is always true." in prompt
        assert "Conflict Report" in prompt  # structured output required

    def test_version_skew_template_renders(self):
        prompt = ct.get_template(
            "version_skew",
            incoming_claim="Feature Y exists.",
            existing_note_stem="feature-y",
            existing_claim="Feature Y was removed.",
            incoming_version="v3.0",
            existing_version="v2.x",
        )
        assert "Version Skew" in prompt
        assert "v3.0" in prompt

    def test_scope_overlap_template_renders(self):
        prompt = ct.get_template(
            "scope_overlap",
            incoming_claim="Z applies in context A.",
            existing_note_stem="z-note",
            existing_claim="Z applies generally.",
            overlap_description="Both describe Z but at different specificity levels.",
        )
        assert "Scope Overlap" in prompt

    def test_unknown_conflict_type_raises(self):
        with pytest.raises(ValueError, match="Unknown conflict_type"):
            ct.get_template("nonexistent_type", foo="bar")

    def test_missing_variable_raises(self):
        with pytest.raises(ValueError, match="Missing required template variable"):
            ct.get_template("direct_contradiction")  # no context provided

    def test_parse_conflict_report_valid(self):
        raw = {
            "conflict_type": "direct_contradiction",
            "resolution": "Update",
            "rationale": "Newer evidence supersedes.",
            "scope_qualifier": None,
            "condition_a": None,
            "condition_b": None,
            "auth_required": False,
            "auth_reason": None,
        }
        report = ct.parse_conflict_report(raw)
        assert report.resolution == "Update"
        assert not report.requires_hitl

    def test_parse_escalate_forces_auth_required(self):
        raw = {
            "conflict_type": "version_skew",
            "resolution": "Escalate",
            "rationale": "Ambiguous.",
            "scope_qualifier": None,
            "condition_a": None,
            "condition_b": None,
            "auth_required": False,
            "auth_reason": "Need human.",
        }
        report = ct.parse_conflict_report(raw)
        assert report.auth_required is True
        assert report.requires_hitl is True

    def test_parse_invalid_resolution_raises(self):
        with pytest.raises(ValueError, match="Invalid resolution"):
            ct.parse_conflict_report({"conflict_type": "scope_overlap", "resolution": "Ignore"})


# ── Synthesis Rubric ──────────────────────────────────────────────────────────

class TestSynthesisRubric:
    _GOOD_DRAFT = (
        "## Scope Statement\n"
        "This note covers exactly one concept: the relationship between X and Y.\n\n"
        "## Body\n"
        + ("Word " * 100)
    )

    def test_passes_for_clean_draft(self):
        result = sr.check_synthesis_scope(self._GOOD_DRAFT)
        assert result.passed
        assert result.atomicity_score == 1.0
        assert result.has_scope_statement

    def test_fails_too_short(self):
        result = sr.check_synthesis_scope("Too short.")
        assert not result.passed
        assert any("short" in i for i in result.issues)

    def test_fails_too_long(self):
        long_draft = "## Scope Statement\nCovers one thing.\n\n" + ("word " * 1000)
        result = sr.check_synthesis_scope(long_draft)
        assert not result.passed
        assert any("long" in i for i in result.issues)

    def test_fails_missing_scope_statement(self):
        no_scope = "## Body\n" + ("Word " * 100)
        result = sr.check_synthesis_scope(no_scope)
        assert not result.passed
        assert not result.has_scope_statement

    def test_fails_too_many_sections(self):
        draft = "\n".join(f"## Section {i}\n" + "word " * 20 for i in range(10))
        result = sr.check_synthesis_scope(draft)
        assert not result.passed
        assert any("section" in i.lower() for i in result.issues)

    def test_detects_boundary_crossing_phrases(self):
        drifting = self._GOOD_DRAFT + "\n\nOn a different topic, we also covers something else."
        result = sr.check_synthesis_scope(drifting)
        assert not result.passed
        assert result.atomicity_score < 1.0

    def test_to_dict_shape(self):
        result = sr.check_synthesis_scope(self._GOOD_DRAFT)
        d = result.to_dict()
        assert "passed" in d
        assert "atomicity_score" in d
        assert isinstance(d["issues"], list)


# ── Provenance ────────────────────────────────────────────────────────────────

class TestProvenance:
    def test_generates_block(self):
        block = pv.generate_provenance_block(
            chunk_ids=["chk_1", "chk_2"],
            source_record_ids=["sr_1"],
            retrieved_at="2026-04-30T12:00:00Z",
        )
        p = block["provenance"]
        assert p["chunk_ids"] == ["chk_1", "chk_2"]
        assert p["source_record_ids"] == ["sr_1"]
        assert p["retrieved_at"] == "2026-04-30T12:00:00Z"
        assert p["acting_agent"] == "claude-chronicler"

    def test_auto_timestamps_when_none(self):
        block = pv.generate_provenance_block(["chk_x"], ["sr_x"])
        assert block["provenance"]["retrieved_at"] != ""

    def test_requires_chunk_ids(self):
        with pytest.raises(ValueError, match="chunk_id"):
            pv.generate_provenance_block([], ["sr_1"])

    def test_requires_source_record_ids(self):
        with pytest.raises(ValueError, match="source_record_id"):
            pv.generate_provenance_block(["chk_1"], [])

    def test_render_yaml_contains_keys(self):
        block = pv.generate_provenance_block(["chk_1"], ["sr_1"], retrieved_at="2026-04-30T00:00:00Z")
        yaml_text = pv.render_provenance_yaml(block)
        assert "provenance:" in yaml_text
        assert "chk_1" in yaml_text
        assert "sr_1" in yaml_text
        assert "claude-chronicler" in yaml_text

    def test_render_yaml_accepts_inner_block(self):
        inner = {
            "source_record_ids": ["sr_2"],
            "chunk_ids": ["chk_2"],
            "retrieved_at": "2026-04-30T00:00:00Z",
            "acting_agent": "claude-chronicler",
        }
        yaml_text = pv.render_provenance_yaml(inner)
        assert "provenance:" in yaml_text
