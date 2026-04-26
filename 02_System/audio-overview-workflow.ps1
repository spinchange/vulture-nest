[CmdletBinding()]
param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string[]]$InputFiles,

    [string]$OutputRoot = (Join-Path $PSScriptRoot "..\\00_Raw\\audio-overviews"),
    [string]$TranscriptModel = "small",
    [string]$Language,
    [switch]$WaveformVideo
)

$ErrorActionPreference = "Stop"

function Resolve-FFmpegPath {
    $candidates = @(@(
        (Get-Command ffmpeg -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
        (Join-Path $env:LOCALAPPDATA "Microsoft\\WinGet\\Packages\\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\\ffmpeg-8.1-full_build\\bin\\ffmpeg.exe")
    ) | Where-Object { $_ -and (Test-Path $_) })

    if (-not $candidates) {
        throw "ffmpeg.exe not found. Install FFmpeg or add it to PATH."
    }

    return $candidates[0]
}

function Resolve-FFprobePath {
    $candidates = @(@(
        (Get-Command ffprobe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source -ErrorAction SilentlyContinue),
        (Join-Path $env:LOCALAPPDATA "Microsoft\\WinGet\\Packages\\Gyan.FFmpeg_Microsoft.Winget.Source_8wekyb3d8bbwe\\ffmpeg-8.1-full_build\\bin\\ffprobe.exe")
    ) | Where-Object { $_ -and (Test-Path $_) })

    if (-not $candidates) {
        throw "ffprobe.exe not found. Install FFmpeg or add it to PATH."
    }

    return $candidates[0]
}

function Invoke-Step {
    param(
        [string]$FilePath,
        [string[]]$ArgumentList
    )

    & $FilePath @ArgumentList
    if ($LASTEXITCODE -ne 0) {
        throw "Command failed: $FilePath $($ArgumentList -join ' ')"
    }
}

function ConvertTo-DrawtextText {
    param(
        [string]$Text
    )

    return $Text.Replace("\", "\\").Replace(":", "\:").Replace("'", "\'")
}

try {
    $repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
    $ffmpeg = Resolve-FFmpegPath
    $ffprobe = Resolve-FFprobePath
    $python = (Get-Command python -ErrorAction Stop).Source
    $transcribeScript = Join-Path $PSScriptRoot "audio-overview-transcribe.py"

    $resolvedOutputRoot = (Resolve-Path $OutputRoot -ErrorAction SilentlyContinue)
    if ($resolvedOutputRoot) {
        $outputRootPath = $resolvedOutputRoot.Path
    } else {
        $outputRootPath = [System.IO.Path]::GetFullPath($OutputRoot, $repoRoot)
        New-Item -ItemType Directory -Force -Path $outputRootPath | Out-Null
    }

    foreach ($inputFile in $InputFiles) {
        $audioPath = (Resolve-Path $inputFile).Path
        $stem = [System.IO.Path]::GetFileNameWithoutExtension($audioPath)
        $safeStem = ($stem -replace "[^\w\-. ]", "_").Trim()
        $itemOutputDir = Join-Path $outputRootPath $safeStem
        New-Item -ItemType Directory -Force -Path $itemOutputDir | Out-Null

        $durationSeconds = & $ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $audioPath
        if ($LASTEXITCODE -ne 0) {
            throw "ffprobe failed for $audioPath"
        }

        $mp4Path = Join-Path $itemOutputDir "$safeStem.youtube.mp4"

        if ($WaveformVideo) {
            $filterComplex = "color=c=0x111111:s=1920x1080,format=yuv420p[bg];[0:a]showwaves=s=1700x420:mode=line:colors=0x7FDBFF,format=rgba[sw];[bg][sw]overlay=(W-w)/2:(H-h)/2[v]"
            Invoke-Step -FilePath $ffmpeg -ArgumentList @(
                "-y",
                "-i", $audioPath,
                "-filter_complex", $filterComplex,
                "-map", "[v]",
                "-map", "0:a",
                "-c:v", "libx264",
                "-preset", "medium",
                "-tune", "stillimage",
                "-pix_fmt", "yuv420p",
                "-c:a", "aac",
                "-b:a", "192k",
                "-shortest",
                $mp4Path
            )
        } else {
            Invoke-Step -FilePath $ffmpeg -ArgumentList @(
                "-y",
                "-f", "lavfi",
                "-i", "color=c=0x111111:s=1920x1080:d=$durationSeconds",
                "-i", $audioPath,
                "-c:v", "libx264",
                "-preset", "medium",
                "-tune", "stillimage",
                "-pix_fmt", "yuv420p",
                "-c:a", "aac",
                "-b:a", "192k",
                "-shortest",
                $mp4Path
            )
        }

        $transcribeArgs = @(
            $transcribeScript,
            "--audio", $audioPath,
            "--output-dir", $itemOutputDir,
            "--model", $TranscriptModel,
            "--repo-root", $repoRoot
        )

        if ($Language) {
            $transcribeArgs += @("--language", $Language)
        }

        Invoke-Step -FilePath $python -ArgumentList $transcribeArgs

        Write-Host "Created video:      $mp4Path"
        Write-Host "Artifact directory: $itemOutputDir"
        Write-Host ""
    }
} catch {
    Write-Error "audio-overview-workflow.ps1 failed: $_"
    exit 1
}
