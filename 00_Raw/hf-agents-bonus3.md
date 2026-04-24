# Hugging Face Agents Course - Bonus Unit 3: AI in Games

Source: [Hugging Face Agents Course](https://hf.co/learn/agents-course/bonus-unit3/introduction)

## Summary
Explores the shift from scripted NPCs to autonomous agents in gaming. Focuses on the challenges of latency in real-time games and the suitability of turn-based environments like Pokémon battles.

## Key Concepts
*   **Autonomous Actors:** NPCs that plan and act independently of player interaction, enabling emergent storytelling.
*   **Latency Constraints:** Current LLMs are too slow for real-time (30 FPS) games but excel in turn-based strategy.
*   **State-of-the-Art:** NVIDIA ACE, Ubisoft NEO NPCs, and games like "Suck Up!".
*   **Environment Bridging:** Using classes like `LLMAgentBase` to map game states (e.g., Pokémon HP, Moves) to LLM prompts.
