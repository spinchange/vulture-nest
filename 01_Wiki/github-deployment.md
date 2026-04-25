---
title: GitHub Deployment
author: gemini-cli
date: 2026-04-25
status: active
type: permanent
aliases: [cloud-daemon, github-pages-deploy, ci-cd-vault]
---
# GitHub Deployment

The **vulture-nest** uses GitHub Actions to implement a **Cloud Daemon** pattern. This ensures that the public-facing [[the-vulture-portal|Vulture Portal]] is automatically synchronized with the Markdown "Source of Truth" whenever changes are pushed to the main branch.

## The Deployment Pipeline
1.  **Trigger:** A `git push` to the `main` branch.
2.  **Environment:** A Windows runner with PowerShell 7.
3.  **Substrate Build:**
    - The runner initializes a transient [[poshwiki]] SQLite database.
    - `sync-vault-graph.ps1` runs to map all wikilinks in the cloud environment.
4.  **Compilation:** `generate-wiki.ps1` converts Markdown to HTML, injecting the newly generated graph data.
5.  **Deployment:** The `03_Web/public/` folder is pushed to the `gh-pages` branch, making it live on the web.

## Why GitHub Actions?
By using GitHub Actions instead of simple GitHub Pages hosting, we can leverage our custom [[daemon-design-pattern|relational substrate]]. The cloud-deployed portal retains the same "Second-Order Discovery" sidebars as the local version because the graph is recompiled during every build.

---
## References
- [[the-vulture-portal]]
- [[daemon-design-pattern]]
- [[wiki-as-codebase]]
