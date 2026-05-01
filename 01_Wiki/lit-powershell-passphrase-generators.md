---
title: "Literature: PowerShell Passphrase Generators"
author: "gemini-cli"
date: "2026-05-01"
status: "active"
type: "literature"
source: "00_Raw/powershell-passphrase-generators.md"
aliases: ["Passphrase Generator Research", "Local Secret Generation"]
---

# Literature: PowerShell Passphrase Generators

This note captures the research and design rationale for local passphrase and haiku-shaped secret generation using **PowerShell 7**.

## Core Design Goals
- **Dependency Reduction**: Improve local secret generation without large external tools.
- **Local Generation**: Keep the process entirely within the user's shell environment.
- **Ergonomics**: Create memorable yet strong secrets (passphrases vs. random strings).

## Implemented Primitives
- **`New-PPhrase`**: Generates random passphrases (e.g., `word-word-word-12`) using a local word list (EFF large list) and cryptographic randomness.
- **`Add-PPhraseWord`**: A utility to curate a personal word corpus while maintaining lowercase normalization.
- **`New-Haiku`**: A novel generator that synthesizes `5-7-5` syllable phrases, emitting both a poetic form and a hyphenated secret form.

## Key Technical Lessons
- **Cryptographic Randomness**: Use `[Security.Cryptography.RandomNumberGenerator]` instead of the standard `Get-Random` for secrets.
- **Corpus over Algorithm**: Passphrase quality depends more on the size and selection method of the word source than on complex formatting.
- **Tool Boundary**: The design explicitly avoids building a full "Password Manager" (which requires master keys, encryption, and history hygiene), focusing instead on "Secret Generation."

## Synthesis
These utilities demonstrate the use of **PowerShell Profile Functions** as a lightweight way to embed secure workflows directly into the developer's daily environment.

---
## See Also
- [[powershell-secret-generation]]
- [[powershell-moc]]
- [[ps-automation-spec]]
