import argparse
import json
import re
import sys
from pathlib import Path


def add_local_site_packages(repo_root: Path) -> None:
    site_packages = repo_root / ".media-py"
    package_init = site_packages / "faster_whisper" / "__init__.py"
    try:
        if package_init.exists():
            sys.path.insert(0, str(site_packages))
    except PermissionError:
        return


def format_timestamp(seconds: float) -> str:
    total_ms = int(round(seconds * 1000))
    hours, rem = divmod(total_ms, 3_600_000)
    minutes, rem = divmod(rem, 60_000)
    secs, millis = divmod(rem, 1000)
    return f"{hours:02d}:{minutes:02d}:{secs:02d},{millis:03d}"


def normalize_text(text: str) -> str:
    return re.sub(r"\s+", " ", text).strip()


def build_markdown(stem: str, transcript: str, segments: list[dict]) -> str:
    links = sorted(set(re.findall(r"https?://\S+", transcript)))
    lines = [
        f"# {stem}",
        "",
        "## Transcript",
        "",
        transcript or "(empty transcript)",
        "",
        "## Links",
        "",
    ]

    if links:
        lines.extend(f"- {link}" for link in links)
    else:
        lines.append("- None detected in transcript")

    lines.extend(
        [
            "",
            "## Timestamped Notes",
            "",
        ]
    )

    if segments:
        for segment in segments:
            start = int(segment["start"])
            minutes, seconds = divmod(start, 60)
            stamp = f"{minutes:02d}:{seconds:02d}"
            lines.append(f"- [{stamp}] {segment['text']}")
    else:
        lines.append("- No segments emitted")

    lines.append("")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--audio", required=True)
    parser.add_argument("--output-dir", required=True)
    parser.add_argument("--model", default="small")
    parser.add_argument("--language", default=None)
    parser.add_argument("--device", default="cpu")
    parser.add_argument("--compute-type", default="int8")
    parser.add_argument("--repo-root", default=".")
    args = parser.parse_args()

    repo_root = Path(args.repo_root).resolve()
    add_local_site_packages(repo_root)

    from faster_whisper import WhisperModel

    audio_path = Path(args.audio).resolve()
    output_dir = Path(args.output_dir).resolve()
    output_dir.mkdir(parents=True, exist_ok=True)

    model = WhisperModel(args.model, device=args.device, compute_type=args.compute_type)
    segment_iter, info = model.transcribe(
        str(audio_path),
        language=args.language,
        vad_filter=True,
        beam_size=5,
        word_timestamps=False,
    )

    segments = []
    for segment in segment_iter:
        text = normalize_text(segment.text)
        if not text:
            continue
        segments.append(
            {
                "id": segment.id,
                "start": round(float(segment.start), 3),
                "end": round(float(segment.end), 3),
                "text": text,
            }
        )

    transcript = "\n".join(segment["text"] for segment in segments)
    stem = audio_path.stem

    txt_path = output_dir / f"{stem}.transcript.txt"
    srt_path = output_dir / f"{stem}.transcript.srt"
    json_path = output_dir / f"{stem}.transcript.json"
    md_path = output_dir / f"{stem}.notes.md"

    txt_path.write_text(transcript + ("\n" if transcript else ""), encoding="utf-8")

    srt_lines = []
    for index, segment in enumerate(segments, start=1):
        srt_lines.extend(
            [
                str(index),
                f"{format_timestamp(segment['start'])} --> {format_timestamp(segment['end'])}",
                segment["text"],
                "",
            ]
        )
    srt_path.write_text("\n".join(srt_lines), encoding="utf-8")

    json_payload = {
        "source": str(audio_path),
        "model": args.model,
        "language": info.language,
        "language_probability": info.language_probability,
        "duration": info.duration,
        "segments": segments,
    }
    json_path.write_text(json.dumps(json_payload, indent=2), encoding="utf-8")
    md_path.write_text(build_markdown(stem, transcript, segments), encoding="utf-8")

    print(f"Transcript written: {txt_path}")
    print(f"Subtitles written:  {srt_path}")
    print(f"Metadata written:   {json_path}")
    print(f"Notes written:      {md_path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
