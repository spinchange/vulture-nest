from __future__ import annotations

from dataclasses import dataclass, field
from pathlib import Path
from typing import Any
from urllib.parse import urlparse

import yaml


DEFAULT_POLICY_PATH = Path(__file__).resolve().parent.parent / "pipeline-policy.yaml"


class PolicyError(RuntimeError):
    pass


class PolicyDeniedError(PolicyError):
    pass


@dataclass(frozen=True)
class Quotas:
    max_credits_per_session: int
    max_pages_per_source: int


@dataclass(frozen=True)
class Safety:
    denied_domains: list[str]
    require_hitl_for_costs_over: int
    require_hitl_for_new_domain: bool


@dataclass(frozen=True)
class Synthesis:
    freshness_threshold_days: int
    min_similarity_threshold: float
    require_provenance_block: bool


@dataclass(frozen=True)
class PipelinePolicy:
    version: float
    quotas: Quotas
    safety: Safety
    synthesis: Synthesis
    approved_domains: tuple[str, ...] = ()


@dataclass
class RuntimeLedger:
    credits_used: int = 0
    pages_crawled: int = 0
    seen_domains: set[str] = field(default_factory=set)


def _require_mapping(data: dict[str, Any], key: str) -> dict[str, Any]:
    value = data.get(key)
    if not isinstance(value, dict):
        raise PolicyError(f"Invalid pipeline policy: '{key}' must be a mapping.")
    return value


def _require_int(data: dict[str, Any], key: str, *, minimum: int = 0) -> int:
    value = data.get(key)
    if not isinstance(value, int) or value < minimum:
        raise PolicyError(f"Invalid pipeline policy: '{key}' must be an integer >= {minimum}.")
    return value


def _require_bool(data: dict[str, Any], key: str) -> bool:
    value = data.get(key)
    if not isinstance(value, bool):
        raise PolicyError(f"Invalid pipeline policy: '{key}' must be a boolean.")
    return value


def _require_float(data: dict[str, Any], key: str, *, minimum: float = 0.0, maximum: float = 1.0) -> float:
    value = data.get(key)
    if not isinstance(value, (int, float)) or not minimum <= float(value) <= maximum:
        raise PolicyError(
            f"Invalid pipeline policy: '{key}' must be a number between {minimum} and {maximum}."
        )
    return float(value)


def _require_domain_list(data: dict[str, Any], key: str) -> list[str]:
    value = data.get(key)
    if not isinstance(value, list) or not all(isinstance(item, str) and item.strip() for item in value):
        raise PolicyError(f"Invalid pipeline policy: '{key}' must be a non-empty string list.")
    return [item.strip().lower() for item in value]


def _extract_domain(url: str) -> str:
    parsed = urlparse(url)
    if parsed.scheme not in {"http", "https"} or not parsed.netloc:
        raise PolicyError(f"Invalid source URL: {url}")
    return parsed.netloc.lower()


def _domain_matches(pattern: str, domain: str) -> bool:
    if pattern.startswith("*."):
        suffix = pattern[1:]
        return domain.endswith(suffix)
    return domain == pattern or domain.endswith(f".{pattern}")


def load_policy(path: str | Path | None = None) -> PipelinePolicy:
    policy_path = Path(path or DEFAULT_POLICY_PATH)
    if not policy_path.exists():
        raise PolicyError(f"Pipeline policy missing at {policy_path}. Ingestion is fail-closed.")

    try:
        raw = yaml.safe_load(policy_path.read_text(encoding="utf-8"))
    except yaml.YAMLError as exc:  # pragma: no cover - parser branch depends on malformed file
        raise PolicyError(f"Pipeline policy invalid at {policy_path}: {exc}") from exc

    if not isinstance(raw, dict):
        raise PolicyError(f"Pipeline policy invalid at {policy_path}: root must be a mapping.")

    quotas_raw = _require_mapping(raw, "quotas")
    safety_raw = _require_mapping(raw, "safety")
    synthesis_raw = _require_mapping(raw, "synthesis")

    version = raw.get("version")
    if not isinstance(version, (int, float)):
        raise PolicyError("Invalid pipeline policy: 'version' must be numeric.")

    approved_domains = raw.get("approved_domains", [])
    if approved_domains and (
        not isinstance(approved_domains, list)
        or not all(isinstance(item, str) and item.strip() for item in approved_domains)
    ):
        raise PolicyError("Invalid pipeline policy: 'approved_domains' must be a string list when present.")

    return PipelinePolicy(
        version=float(version),
        quotas=Quotas(
            max_credits_per_session=_require_int(quotas_raw, "max_credits_per_session", minimum=1),
            max_pages_per_source=_require_int(quotas_raw, "max_pages_per_source", minimum=1),
        ),
        safety=Safety(
            denied_domains=_require_domain_list(safety_raw, "denied_domains"),
            require_hitl_for_costs_over=_require_int(safety_raw, "require_hitl_for_costs_over", minimum=0),
            require_hitl_for_new_domain=_require_bool(safety_raw, "require_hitl_for_new_domain"),
        ),
        synthesis=Synthesis(
            freshness_threshold_days=_require_int(synthesis_raw, "freshness_threshold_days", minimum=1),
            min_similarity_threshold=_require_float(synthesis_raw, "min_similarity_threshold"),
            require_provenance_block=_require_bool(synthesis_raw, "require_provenance_block"),
        ),
        approved_domains=tuple(item.strip().lower() for item in approved_domains),
    )


def enforce_policy(
    policy: PipelinePolicy,
    ledger: RuntimeLedger,
    *,
    url: str,
    estimated_credits: int = 0,
    estimated_pages: int = 0,
    human_approved: bool = False,
) -> dict[str, Any]:
    domain = _extract_domain(url)

    for denied in policy.safety.denied_domains:
        if _domain_matches(denied, domain):
            raise PolicyDeniedError(f"Domain '{domain}' is denied by pipeline policy.")

    if estimated_pages > policy.quotas.max_pages_per_source:
        raise PolicyDeniedError(
            f"Estimated page count {estimated_pages} exceeds max_pages_per_source "
            f"{policy.quotas.max_pages_per_source}."
        )

    if ledger.credits_used + estimated_credits > policy.quotas.max_credits_per_session:
        raise PolicyDeniedError(
            f"Estimated credits would exceed session quota "
            f"{policy.quotas.max_credits_per_session}."
        )

    if estimated_credits > policy.safety.require_hitl_for_costs_over and not human_approved:
        raise PolicyDeniedError(
            "AUTH_REQUIRED: estimated cost exceeds require_hitl_for_costs_over and lacks approval."
        )

    is_new_domain = domain not in ledger.seen_domains and domain not in policy.approved_domains
    if policy.safety.require_hitl_for_new_domain and is_new_domain and not human_approved:
        raise PolicyDeniedError("AUTH_REQUIRED: new domain requires human approval before ingestion.")

    return {"domain": domain, "is_new_domain": is_new_domain}


def record_usage(ledger: RuntimeLedger, *, domain: str, credits_used: int = 0, pages_crawled: int = 0) -> None:
    ledger.credits_used += credits_used
    ledger.pages_crawled += pages_crawled
    ledger.seen_domains.add(domain)
