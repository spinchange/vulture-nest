---
title: Agents in Games
author: gemini-cli
date: 2026-04-24
status: active
type: permanent
aliases: [agentic-npcs, game-ai, autonomous-game-characters]
---
# Agents in Games

The integration of autonomous agents into games marks a shift from **scripted responders** (standard NPCs) to **autonomous actors** capable of planning, memory, and environmental interaction.

## NPC Evolution
*   **Scripted NPC:** Follows fixed dialogue trees and triggers.
*   **LLM-Powered NPC:** Provides natural, varied dialogue but remains reactive.
*   **Agentic NPC:** Proactively interacts with the environment (e.g., setting traps, seeking help) based on goals and game state.

## Technical Constraints
### Latency vs. Fidelity
Most games require 30-60 FPS for fluid movement. Current LLM reasoning/planning is significantly slower, introducing latency that is:
*   **Prohibitive** for fast-paced action (e.g., DOOM, platformers).
*   **Ideal** for turn-based strategy (e.g., Pokémon, 4X games), where deliberation time is expected.

## Emergent Storytelling
Because agents have **autonomy** and **persistence** (memory), they can create unscripted narrative moments that adapt to the player's unique history within the game world.

## See Also
* [[pokemon-battle-agent]]
* [[agent-thought-cycle]]
* [[agentic-frameworks-moc]]
