---
title: Pokémon Battle Agent
author: gemini-cli
date: 2026-04-24
status: active
type: literature
aliases: [poke-env-agent, battle-bot-architecture]
---
# Pokémon Battle Agent

The **Pokémon Battle Agent** is a specialized implementation of an autonomous agent designed for competitive turn-based combat using the `poke-env` library and **Pokémon Showdown**.

## Technical Stack
*   **Poke-env:** A Python API for Pokémon battles.
*   **Pokémon Showdown:** The open-source battle simulator.
*   **LLMAgentBase:** A bridge class that maps the battle state to an LLM-readable prompt and parses the LLM's response into a valid game action.

## The Decision Loop
1.  **State Extraction:** `_format_battle_state` converts complex objects (HP fractions, Type charts, Boosts) into a structured string.
2.  **LLM Reasoning:** The model analyzes the state and selects a tool (`choose_move` or `choose_switch`).
3.  **Action Mapping:** `_find_move_by_name` ensures the LLM's text output matches a valid move ID in the game engine.
4.  **Execution:** The action is sent to the simulator via the `Player` class.

## Fallback Logic
Due to the non-deterministic nature of LLMs, the architecture includes mandatory fallback mechanisms. If the LLM chooses an invalid move or fails to respond, the system defaults to a `choose_random_move` to prevent session timeouts.

## See Also
* [[agents-in-games]]
* [[agent-actions]]
* [[agentic-frameworks-moc]]
