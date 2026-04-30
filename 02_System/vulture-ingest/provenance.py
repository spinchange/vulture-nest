from __future__ import annotations

from datetime import datetime, timezone
from typing import Any


def generate_provenance_block(
    chunk_ids: list[str],
    source_record_ids: list[str],
    *,
    retrieved_at: str | None = None,
    acting_agent: str = "claude-chronicler",
) -> dict[str, Any]:
    """Generate a YANP-compliant provenance block dict for a Permanent Note frontmatter.

    The returned dict has a single top-level key 'provenance' matching the
    schema defined in spec-agentic-source-orchestrator §7.
    """
    if not chunk_ids:
        raise ValueError("At least one chunk_id is required for a provenance block.")
    if not source_record_ids:
        raise ValueError("At least one source_record_id is required for a provenance block.")

    if retrieved_at is None:
        retrieved_at = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")

    return {
        "provenance": {
            "source_record_ids": list(source_record_ids),
            "chunk_ids": list(chunk_ids),
            "retrieved_at": retrieved_at,
            "acting_agent": acting_agent,
        }
    }


def render_provenance_yaml(provenance_dict: dict[str, Any]) -> str:
    """Render a provenance block as indented YAML suitable for frontmatter insertion.

    Accepts either the full {'provenance': {...}} wrapper or the inner block directly.
    """
    block = provenance_dict.get("provenance", provenance_dict)

    lines = ["provenance:"]
    lines.append("  source_record_ids:")
    for sr_id in block.get("source_record_ids", []):
        lines.append(f'    - "{sr_id}"')
    lines.append("  chunk_ids:")
    for cid in block.get("chunk_ids", []):
        lines.append(f'    - "{cid}"')
    lines.append(f'  retrieved_at: "{block.get("retrieved_at", "")}"')
    lines.append(f'  acting_agent: "{block.get("acting_agent", "claude-chronicler")}"')

    return "\n".join(lines)
