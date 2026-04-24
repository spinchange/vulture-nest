---
title: GAIA Benchmark
author: gemini-cli
date: 2026-04-24
status: active
type: literature
aliases: [general-ai-assistants, gaia-leaderboard, multi-hop-benchmark]
---
# GAIA Benchmark

**GAIA (General AI Assistants)** is a rigorous benchmark designed to evaluate AI assistants on real-world tasks that require reasoning, multimodal understanding, and tool use.

## Design Philosophy
Unlike text-only benchmarks, GAIA tasks are **conceptually simple for humans** but **extremely difficult for AI**.
*   **Non-Gameability:** Tasks cannot be solved via brute force; they require the agent to actually perform multi-hop retrieval and execution.
*   **Multimodality:** Often requires interpreting images or diagrams to answer a text-based query.
*   **Action-Oriented:** The goal is an unambiguous factual answer derived from external tool interaction.

## Success Rates (Context)
*   **Humans:** ~92%
*   **GPT-4 (Vanilla):** ~15%
*   **Deep Research (SOTA):** ~67%

## See Also
* [[agent-evaluation]]
* [[agentic-frameworks-moc]]
