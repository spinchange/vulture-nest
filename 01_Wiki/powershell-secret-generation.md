---
title: PowerShell Secret Generation
author: gemini-cli
date: 2026-05-01
status: active
type: permanent
aliases: ["Passphrase Generation", "PowerShell Security Utilities", "One-Liner Password Generators"]
---

# PowerShell Secret Generation

**PowerShell Secret Generation** refers to the use of shell-native primitives and profile-based functions to create strong, memorable, and low-dependency cryptographic secrets.

## Core Philosophies
- **Offline First**: Generation happens locally to reduce exposure to network-based threats.
- **Cryptographic Rigor**: Preferring the .NET `RandomNumberGenerator` over standard pseudo-random helpers.
- **Ergonomic Strength**: Favoring **Passphrases** (word-based) over **Passwords** (random character-based) for human-centric scenarios.

## Implementation Patterns

### 1. Passphrases (Word-Based)
Passphrases rely on a strong local corpus (e.g., the EFF large word list).
- **Entropy**: Derived from the number of words and the size of the corpus.
- **Example**: `dose-hazelnut-flounder-strategy-saddlebag-magician10`

### 2. Character-Based (One-Liners)
Useful for quick, high-entropy secrets where memorability is not required.

**Hex-Encoded Randomness:**
```powershell
-join([Security.Cryptography.RandomNumberGenerator]::GetBytes(18)|% ToString x2)
```

**Custom Character Set:**
```powershell
$chars = 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789!@#$%^&*()-_+='
-join (1..20 | ForEach-Object { $chars[(Get-Random -Maximum $chars.Length)] })
```

**Golfed One-Liner (Path Proxy):**
```powershell
[IO.Path]::GetRandomFileName()
```

## Security Best Practices
1. **Never build a full "Vault"**: Secret generation is a safe boundary for custom scripts; building an encrypted storage system (Password Manager) introduces high risk.
2. **Profile Integration**: Embedding these as functions in the `$PROFILE` ensures they are always available without cluttering the filesystem.
3. **Normalization**: When curating word lists, convert to lowercase and strip non-alpha characters to ensure portability across different systems.

---
## See Also
- [[lit-powershell-passphrase-generators]]
- [[powershell-moc]]
- [[ps-automation-spec]]
