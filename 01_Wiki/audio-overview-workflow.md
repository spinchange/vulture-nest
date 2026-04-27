---
title: Audio Overview Workflow
author: codex
hostname: LYRA
date: 2026-04-26
status: active
type: permanent
aliases: [m4a-to-youtube-workflow, audio-transcript-pipeline, youtube-audio-overview]
---
# Audio Overview Workflow

The **Audio Overview Workflow** converts a downloaded `.m4a` narration into a YouTube-ready `.mp4` and emits transcript artifacts that can be mined into notes. It is designed for a fresh Windows machine with minimal assumptions beyond [[python]].

## Purpose

The workflow solves two linked problems:

1. Turn generated audio overviews into uploadable video assets for YouTube.
2. Turn the same audio into text artifacts that can be harvested into durable notes, links, and follow-on synthesis.

## Implementation

The operational entrypoint is `02_System/audio-overview-workflow.ps1`. It orchestrates:

- **FFmpeg** for `.m4a -> .mp4` conversion.
- **faster-whisper** on CPU for local transcription.
- **Python helper logic** in `02_System/audio-overview-transcribe.py` for artifact generation.

The default render path creates a plain 1920x1080 black-background MP4 with the original audio track. This avoids font and UI dependencies on blank Windows machines. The transcript helper emits:

- `.transcript.txt`
- `.transcript.srt`
- `.transcript.json`
- `.notes.md`

## Setup Decisions

- **Winget** was repaired by restoring `WindowsApps` to the user PATH.
- **FFmpeg** was installed from `Gyan.FFmpeg`.
- **faster-whisper** was installed against the existing Python 3.12 runtime.
- **Microsoft VC++ Redistributable** was required for `ctranslate2` to load correctly.

This stack won because it balanced local execution, repeatability, and low operator overhead better than GUI tools or a more manual `whisper.cpp` pipeline.

## Usage

```powershell
& .\02_System\audio-overview-workflow.ps1 -InputFiles 'C:\path\file.m4a'
```

Optional waveform render:

```powershell
& .\02_System\audio-overview-workflow.ps1 -InputFiles 'C:\path\file.m4a' -WaveformVideo
```

Output folders are written under `00_Raw/audio-overviews/<stem>/`.

## Engineering Lessons

- Blank Windows boxes are not just missing packages; they are often missing path wiring and native runtime dependencies.
- A font-free video generation path is more robust than a styled title-card path when system configuration is unknown.
- Repo-local package targets are not automatically safer than user-site installs; Windows ACL behavior can make them more fragile.
- Transcript generation becomes more useful when it emits note-shaped markdown, not just raw text.

---
## See Also
- [[verbalized-sampling-experiment]]
- [[foundry-local]]
- [[powershell-moc]]
- [[python-moc]]

