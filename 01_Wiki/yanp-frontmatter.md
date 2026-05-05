---
title: YANP Frontmatter
author: human
date: 2026-05-04
status: active
type: permanent
aliases:
  - frontmatter-block-table
  - yanp-metadata-baseline
  - yanp-frontmatter-spec
---

# YANP Frontmatter

This is the frontmatter block table from the YANP (Yet Another Notes Project) v.01 specificiation.

|Field|Type|Values/Notes|
|---|---|---|
|tags|array|strings — frontmatter tags are machine-written; inline #tags are human-written|
|author|string|who wrote the note — agent name (claude, gemini, codex) or human name|
|hostname|string|system hostname where note was originally authored — set once, never updated|
|date|string|YYYY-MM-DD — authorship date, day granularity only|
|status|string|draft · active · archived|
|title|string|human-readable title — filename used if absent|
|aliases|array|strings — alternate names for wikilink resolution|
|priority|string|low · medium · normal · high · urgent|
|due|string|YYYY-MM-DD|
|scheduled|string|YYYY-MM-DD|
|project|string|grouping label|

## Conservative Amendment Notes

If this baseline is amended, the safest changes currently appear to be:

- keep `type` and `status` as-is
- preserve `literature`, `permanent`, and `fleeting` as working note kinds
- allow or require `author` to become a YAML list for multi-agent authorship
- standardize `sources` as a YAML list when source grounding is present

This preserves the live vault's working ecology while fixing the two metadata shapes most visibly under strain.

I had to go back and look this up becauase I felt a sense of deja vu, like we are addressing things that already have been spoken to previously, and that I had assumed were the vulture-nest's status quo without really checking deeply.

Here's an immediate observation and something that I was uncomfortbale all along: YAML frontmatter blocks and my YANP specification don't really seek to say what something **_is_**

Vulture-Nest links do. Like it is an important part of the way all the agents think about it.

I still need to think on this. I am going to be able to because I am headed off to work and this session will be unattended again for a while. I wanted to share these thoughts with you and see what your reaction was. I still have not shared either prompt becuase this new information needs to be digested and thought about by both of us, "for a turn" in your case, at least.

My gut instinc is that the table in this document is the true north or real starting point, at least it should have been. I don't think it was, fully. One quirk of this table is the ordering , which icidentally doesn't matter to YAML parsers and shouldn't to YANP ones either. I don't know hy the spec shows tags *first* aesthetically they look best last. Ordering of this stuff is all still an open or unsettled question.

My thinking is the table needs to look like this. What do you think? I think that I might be able to live with literature, permenant, and fleeting after all.

Status and Priority speak to what phase was going to adress by keeping vauge.  The question is what is missing?

|Field|Type|Values/Notes|
|---|---|---|
|title|string|human-readable title — filename used if absent|
|date|string|YYYY-MM-DD — authorship date, day granularity only|
|kind|string|literature · permanent · fleeting|
|models|array|agent(s) who principally wrote or materially worked the substance of the note: agent name (claude, gemini, codex) or human name|
|hostname|string|system hostname where note was originally authored — set once, never updated|
|status|string|draft · active · archived|
|aliases|array|strings — alternate names for wikilink resolution|
|priority|string|low · medium · normal · high · urgent|
|due|string|YYYY-MM-DD|
|scheduled|string|YYYY-MM-DD|
|project|string|grouping label|
|tags|array|strings — frontmatter tags are machine-written; inline #tags are human-written|
