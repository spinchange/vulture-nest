---
tags:
  - powershell
  - security
  - passphrases
  - cli
  - research
source: codex-session
hostname: DESKTOP-004IHBK
date: 2026-04-30
status: active
---

# PowerShell Passphrase Generators

## Summary

This note captures a small PowerShell 7 workflow for generating memorable passphrases and haiku-shaped passwords directly from the shell profile. The design goal was not "invent a password manager," but "improve local secret generation ergonomics without adding a large dependency surface."

Three commands were built:

- `New-PPhrase` generates a random passphrase from a large local word list plus a short numeric suffix.
- `Add-PPhraseWord` appends user-curated words into the local word list while preserving a primitive-safe format.
- `New-Haiku` generates a `5-7-5` syllable-pattern phrase and also emits a password-safe hyphenated version.

## Why This Approach

The initial question was "what is the tiniest PowerShell command for a random passphrase suitable for a password?" The discussion immediately split into two distinct concepts:

- A random string is easy to generate, but it is not a passphrase.
- A passphrase needs a word source, and quality depends heavily on word-list size and selection method.

That led to a practical design:

1. Keep generation local.
2. Use cryptographic randomness, not `Get-Random`.
3. Store a reusable word list in a plain text file.
4. Keep the output compatible with older or fragile systems by restricting to lowercase letters, hyphens, and digits.

## Word List Choice

The local file [words.txt](C:/Users/executor/words.txt) was derived from the EFF large word list. The raw downloaded source remained as `words-raw.txt` in the home directory so the normalized list could be rebuilt if needed.

Operationally, this was a good compromise:

- Large enough to produce reasonable entropy.
- Simple enough to inspect and edit manually.
- Compatible with plain PowerShell text processing.

The main lesson is that passphrase quality comes more from a strong corpus and unbiased selection than from clever string formatting.

## Implemented Commands

### `New-PPhrase`

`New-PPhrase` reads the local word list, selects words using a cryptographic random integer helper, joins them with hyphens, and appends a small numeric suffix.

Example shape:

```text
dose-hazelnut-flounder-strategy-saddlebag-magician10
```

Notes:

- It lives in the PowerShell 7 profile, not as a separate tool.
- The function defaults to six words.
- The numeric suffix improves compatibility with sites that demand digits.

### `Add-PPhraseWord`

`Add-PPhraseWord` exists to make the corpus mildly personal over time.

Example usage:

```powershell
Add-PPhraseWord serendipity
Add-PPhraseWord serendipity codexium
```

Normalization rules:

- Convert to lowercase.
- Accept only `a-z`.
- Ignore duplicates.
- Rewrite the file in sorted unique form.

This makes it easy to add interesting words learned over time without drifting into punctuation, whitespace, or mixed-case edge cases.

### `New-Haiku`

`New-Haiku` is a second generator oriented toward memorability and novelty. It uses small syllable-grouped word banks and emits a haiku-like `5-7-5` phrase.

Default output includes both forms:

```text
harbor amber leaf
meadow radiant willow
beautiful morning

harbor-amber-leaf-meadow-radiant-willow-beautiful-morning64
```

This is not "true poetry generation." It is closer to structured passphrase synthesis with a poetic surface form.

## Security and Product Lessons

The session also touched on CLI password managers and whether it would make sense to build one from scratch.

Conclusion:

- Good CLI password managers already exist.
- Building a real password manager is materially riskier than building a passphrase generator.
- The safe boundary for custom tooling is "generate secrets well" or "wrap an existing vault," not "invent a new vault and crypto scheme."

That distinction matters. A passphrase generator is comparatively constrained:

- local text corpus
- cryptographic RNG
- deterministic formatting rules

A password manager expands the threat model dramatically:

- master key derivation
- encryption design
- clipboard handling
- process memory hygiene
- syncing and recovery
- command history leakage

## Practical Takeaways

- A profile function is enough when the real need is convenience inside `pwsh`.
- A large, inspectable word list is more valuable than an overly clever one-liner.
- "Memorable" and "strong" are related but not identical goals.
- Haiku-shaped passphrases are viable as an ergonomic layer, provided the underlying selection space remains large enough.
- Personal curation of a word list is useful, but should stay constrained to simple normalized tokens.

## Open Questions

- Whether `New-Haiku` should evolve from a syllable bank into light grammar templates with nouns, verbs, and adjectives.
- Whether `New-PPhrase` should gain explicit switches such as `-NoNumber`, `-Words`, or compatibility presets.
- Whether a local wrapper around an existing CLI password manager would be a better next step than expanding the generators further.
