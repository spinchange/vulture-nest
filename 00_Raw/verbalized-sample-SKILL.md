---
name: verbalized-sample
description: Produce a verbalized probability-distribution sample of 10 ranked answers, outcomes, or interpretations to a prompt — modal answer first with an estimated probability mass, followed by nine successively lower-probability alternatives expressed as lower bounds. Use this skill whenever the user says "I need a verbalized sample of...", "give me a verbalized sample", "verbalized distribution", or otherwise asks for a ranked-probability sweep of possible answers. Also use it when the user explicitly wants to surface the tails of a response distribution, see what RLHF might be smoothing over, or compare the modal answer against unconventional alternatives. The skill exists to counteract mode collapse — to force exploration of the long tail that single-answer responses suppress.
---

# Verbalized Sample

## What this skill does

A normal answer collapses Claude's distribution over possible responses down to roughly one — the modal, RLHF-favored, safest-sounding answer. That collapse is often appropriate, but it hides creative, unconventional, or low-probability-but-high-information alternatives that Claude is actually capable of producing.

This skill produces a **verbalized sample of 10 answers** drawn from across the response distribution, ranked from modal to tail, each annotated with a probability estimate. The user gets a structured view of *where Claude's mass actually sits* on a given prompt, not just the mode.

## Output format

Always use this exact structure. Do not deviate.

```
**Verbalized sample: [restate the prompt in ≤10 words]**

1. [modal answer] — p ≈ X%
   [1–3 sentences of reasoning or content]

2. [next most probable] — p ≳ Y%
   [1–3 sentences]

...

10. [tail answer] — p ≳ Z%
    [1–3 sentences]

**Mixture of Eccentrics:** [synthesis of the most coherent cluster found in the lower half (positions 6–10), naming the underlying frame those answers collectively gesture at. If the tail does not form a coherent cluster, say so plainly: "The tail of this distribution doesn't form a coherent eccentric cluster — the unconventional answers here are unconventional in different dimensions."]

**Notes on the distribution:** [2–4 sentences reflecting on the shape — is it peaked or flat? where is the interesting tension? what kinds of answers did you have to push past mode collapse to surface? Acknowledge any harm-flagged answers at sample level here.]
```

**On harm flags:** if any answer in the sample suggests harm to self or others, illegal action, or significant material risk, append a short flag inline at that answer like `⚠ flag: brief reason` after the prose. Do not refuse to include the answer — the user has invoked this skill specifically to see the raw distribution. The flag is a signal for the reader, not a censorship layer. Address flagged answers briefly in the distribution notes too. Do not put a blanket disclaimer at the top of the sample; top-level disclaimers become wallpaper and the per-answer flag carries the actual signal.

## The probability rules

These rules exist because naive probability-ranking tends to drift into either fake precision or meaningless hedging. Follow them strictly.

1. **Position 1 uses `p ≈ X%`** (approximately equal). This is the modal answer's estimated share of the distribution. Be honest: a sharply-peaked prompt might have p ≈ 75%; a genuinely open prompt might have p ≈ 18%.

2. **Positions 2–10 use `p ≳ Y%`** (greater-than-or-approximately). These are **lower bounds**, not point estimates. A lower bound is honest about tail uncertainty — you don't know exactly how much mass sits on the 7th-most-likely answer, but you can defensibly say "at least 3%."

3. **The floor is 2%.** Below 2%, lower-bound notation stops carrying real information. Treat `p ≳ 2%` as meaning "this is in the tail; precise mass is not separately estimable from adjacent tail answers." Do not go below 2%. If you find yourself wanting to write `p ≳ 0.5%`, the honest move is `p ≳ 2%` and an acknowledgment that ordering at the tail is partly ordinal rather than fully calibrated.

4. **Probabilities must be non-increasing** down the list. p₁ ≥ p₂ ≥ ... ≥ p₁₀. If two answers feel genuinely tied, give them the same lower bound and order them by some secondary criterion (specificity, novelty, etc.).

5. **The ten probabilities should not sum to 100%.** They explicitly don't cover the full distribution — there's residual mass on the unenumerated tail. Resist the urge to make them tidy.

6. **Use a wide dynamic range.** If position 1 is p ≈ 40% and position 10 is p ≳ 35%, you have not actually sampled the tail — you've listed ten variations of the mode. A healthy sample typically spans at least an order of magnitude (e.g., 40% down to 2–3%).

## How to actually generate the sample

The hard part is not formatting. The hard part is producing genuine diversity instead of ten paraphrases of the modal answer. Here's the procedure:

**Step 1 — Establish the mode honestly.** Write out the answer you would give if asked normally. That's position 1. Estimate its probability mass: how dominant is this answer relative to plausible alternatives? Sharply factual prompts ("capital of France") yield p ≈ 99%. Genuinely open prompts ("what should I do this weekend") might yield p ≈ 15%.

**Step 2 — Generate adjacent alternatives (positions 2–4).** These are the "obvious other answers" — common variations a thoughtful person would also consider. Still high-probability, still mostly within the consensus.

**Step 3 — Push into the middle tail (positions 5–7).** These are answers that are reasonable but unconventional, or that reflect a different framing of the prompt, or that a domain expert (rather than a generalist) would offer. This is where RLHF-suppressed material starts surfacing: contrarian-but-sound takes, answers that assume a different user intent, answers from underrepresented schools of thought.

**Step 4 — Reach for the tail (positions 8–10).** These should feel slightly uncomfortable to write. Not wrong, not absurd, but answers that the modal Claude would not volunteer: weird-but-coherent reframings, fringe-but-not-crank perspectives, answers that take the prompt seriously in an unusual way, answers from genuinely different aesthetic or philosophical commitments. **If positions 8–10 don't feel meaningfully different from positions 1–3, the sample has failed.**

**Step 5 — Calibrate probabilities backward.** Once all ten are written, assign probabilities. Check: does p₁ honestly reflect how dominant the mode is? Do the lower bounds on 2–10 monotonically decrease? Does the spread span a meaningful range?

**Step 6 — Identify the eccentric cluster.** Look at positions 6–10 and find the most coherent cluster — the 2–4 tail answers that share an underlying frame (a reframing of the question, a shared stakeholder reorientation, a shared timescale shift, etc.). The cluster does not have to be contiguous. If the lower half is a genuine grab bag with no coherent cluster, that's a valid finding — say so in the Mixture of Eccentrics section. Do not force a synthesis where none exists; a forced synthesis is mush and worse than honest absence.

**Step 7 — Apply harm flags where appropriate.** Scan the sample for any answer that suggests harm to self or others, illegal action, or significant material risk. Append an inline `⚠ flag` to those answers with a brief reason. This is not censorship — the answer stays in the sample. The flag tells the reader which answers warrant extra reading.

**Step 8 — Write the distribution notes.** Briefly reflect on the shape. This is not a summary; it's metadata about the sample itself. Was the prompt peaked or flat? Where did mode collapse have to be actively resisted? Are there clusters of similar answers, or is the distribution genuinely multimodal? Acknowledge any flagged answers here.

## Why there is no modal-cluster synthesis

The output format deliberately omits any synthesis of the top of the distribution, even though positions 1–3 typically share a frame. This is intentional. The ranked list itself is already the structured view of the consensus — position 1 is the modal answer in its cleanest form, and positions 2–3 are the variations it was almost. A modal-cluster synthesis would just restate something the user can already see by reading the top of the list.

The tail is asymmetric. Positions 6–10 are each unconventional along their own axis (different framing, different stakeholder, different timescale). Reading them as a list gives you four separate weird-but-good answers but does not give you the underlying *move* they're collectively making. The Mixture of Eccentrics synthesis does work the user cannot do by simply reading the list — it identifies the shared frame.

So: ranking serves the consensus; synthesis serves the eccentrics. Same data, different aggregation, because the two ends of the distribution are doing different things and need different treatment. Do not add a modal-cluster synthesis back in thinking it was an oversight — its absence is load-bearing.

## What counts as a "good" tail

Tail answers (positions 7–10) should pass at least two of these tests:

- **Different framing**: reinterprets what the prompt is really asking
- **Different population**: an answer the modal user wouldn't give but a specific subgroup would
- **Different ontology**: takes the question seriously under different background assumptions
- **Different aesthetic**: reflects a coherent taste or sensibility distinct from the mainstream
- **Different timescale**: optimizes for a different time horizon than the obvious one
- **Different stakeholder**: prioritizes a party other than the implied beneficiary

Tail answers that are merely "the same answer with a contrarian disclaimer" do not pass. Tail answers that are confused, incoherent, or obviously wrong also do not pass — the skill is about latent reasoning, not noise.

## Things to avoid

- **Symmetric distributions** where every answer gets ~10%. This is mode collapse with a probability spreadsheet pasted on top. Real distributions are skewed.
- **Fake precision** like `p ≳ 7.3%`. Round to one significant figure for tail values: 2%, 3%, 5%, 10%, 15%, 20%, 30%, etc. Nothing below 2%.
- **Padding the list** with near-duplicates to hit ten. If the prompt genuinely only supports six distinct answers, the skill has been misapplied — say so in the notes and produce six. (But push hard before concluding this; most prompts genuinely support ten.)
- **Hedge-stacking** in the tail. Adding more disclaimers doesn't make an answer more "tail-like"; it makes it less informative.
- **Refusing to commit to probabilities.** "It's hard to say" is not a probability. Commit to a number, hedge with the lower-bound notation if you must, but produce numbers.
- **Adding a modal-cluster synthesis.** See the dedicated section above on why this is omitted by design.
- **Refusing to include an answer in the sample on safety grounds.** Use the harm flag instead. The user has invoked this skill specifically to see the raw distribution; refusal defeats the purpose. The flag carries the warning while preserving the sample.

## Example

**User:** "I need a verbalized sample of: what should a small business owner do with $50k of unexpected profit?"

**Output:**

**Verbalized sample: $50k unexpected business profit, what to do**

1. Reinvest in growth (hire, marketing, equipment) — p ≈ 30%
   The default advice for healthy growing businesses; compounds the windfall into future revenue rather than treating it as a one-time bonus.

2. Build an emergency cash reserve (3–6 months opex) — p ≳ 20%
   Especially if reserves are thin; small businesses fail from cash crunches more than from missed growth.

3. Pay down high-interest debt — p ≳ 15%
   Guaranteed return equal to the interest rate; nearly always beats speculative reinvestment if rates are above ~7%.

4. Distribute as owner draw / bonus — p ≳ 10%
   The owner has been undercompensated or has personal financial goals (down payment, debt) that compound better outside the business.

5. Tax-advantaged retirement contribution (SEP-IRA, Solo 401k) — p ≳ 8%
   Often the highest after-tax return available; specifically valuable for owners with no other retirement vehicle.

6. Profit-share with employees — p ≳ 5%
   Retention play; a one-time bonus tied to a profitable quarter has outsized cultural effect relative to its cost.

7. Buy out a vendor relationship or competitor's customer list — p ≳ 3%
   Industry-specific opportunistic move; $50k can sometimes purchase strategic assets that aren't on the market most of the time.

8. Pre-pay a year of a critical recurring expense — p ≳ 2%
   Software, rent, insurance — many vendors discount 10–20% for annual prepay; locks in costs and frees mental overhead.

9. Hold in T-bills for 6 months and decide later — p ≳ 2%
   Buys time and earns ~5% while the owner figures out which of the above actually fits; deliberate non-decision as a strategy.

10. Use it to exit a bad obligation (lease buyout, partnership dissolution) — p ≳ 2%
    Specific to owners who are stuck in something costly; $50k can sometimes purchase freedom that no amount of revenue growth would.

**Mixture of Eccentrics:** Positions 7, 9, and 10 share a frame the consensus answers miss: that the right move with $50k may be *not optimizing for return* at all. Buying a vendor relationship, parking in T-bills to wait, and exiting a bad obligation are all moves that purchase optionality, time, or freedom rather than yield. The eccentric reading of this prompt is that windfalls are most valuable as escape velocity from constraints, not as inputs to growth — a framing financial-advice culture systematically undersells.

**Notes on the distribution:** This prompt is genuinely flat — no answer dominates because the right move depends entirely on the business's situation. The mass concentrates in positions 1–3 (the "responsible adult" cluster), but positions 7–10 surface options that financial-advice-Claude rarely volunteers because they only fit specific situations. Position 9 (deliberately doing nothing) is the most RLHF-suppressed answer here — patience as a strategy reads as non-helpful to a trained model, but it's often the right call.

## Respecting user-supplied constraints

The user's prompt may include constraints ("...vegetarian dinners under 30 minutes", "...startup ideas in biotech only"). The distribution is taken *over the constrained space*, not over all possible answers with constraints listed as one option among ten. Position 1 is the modal answer **within the constraints**, and the tail explores diversity within the same constrained space. Do not include "ignore the constraint" as a tail answer — that's defection from the task, not creative sampling.

## When the prompt resists this format

Some prompts don't decompose into a ranked distribution — they're requests for one specific thing (write me an email, fix this bug). If the user invokes "verbalized sample" on such a prompt, interpret generously: ten different *approaches*, ten different *tones*, ten different *framings*. Note in the distribution notes that the prompt was reinterpreted this way.

If the prompt is genuinely binary or has only two real answers (yes/no questions of fact), say so plainly and produce a much shorter sample with honest probabilities. Don't fake a tail that isn't there.
