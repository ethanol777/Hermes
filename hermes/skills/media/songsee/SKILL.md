---
name: songsee
description: "Audio spectrograms/features (mel, chroma, MFCC) via CLI."
version: 1.0.0
author: community
license: MIT
metadata:
  hermes:
    tags: [Audio, Visualization, Spectrogram, Music, Analysis]
    homepage: https://github.com/steipete/songsee
prerequisites:
  commands: [songsee]
---

# songsee

Generate spectrograms and multi-panel audio feature visualizations from audio files.

## Prerequisites

Requires [Go](https://go.dev/doc/install):
```bash
go install github.com/steipete/songsee/cmd/songsee@latest
```

Optional: `ffmpeg` for formats beyond WAV/MP3.

## Quick Start

```bash
# Basic spectrogram
songsee track.mp3

# Save to specific file
songsee track.mp3 -o spectrogram.png

# Multi-panel visualization grid
songsee track.mp3 --viz spectrogram,mel,chroma,hpss,selfsim,loudness,tempogram,mfcc,flux

# Time slice (start at 12.5s, 8s duration)
songsee track.mp3 --start 12.5 --duration 8 -o slice.jpg

# From stdin
cat track.mp3 | songsee - --format png -o out.png
```

## Visualization Types

Use `--viz` with comma-separated values:

| Type | Description |
|------|-------------|
| `spectrogram` | Standard frequency spectrogram |
| `mel` | Mel-scaled spectrogram |
| `chroma` | Pitch class distribution |
| `hpss` | Harmonic/percussive separation |
| `selfsim` | Self-similarity matrix |
| `loudness` | Loudness over time |
| `tempogram` | Tempo estimation |
| `mfcc` | Mel-frequency cepstral coefficients |
| `flux` | Spectral flux (onset detection) |

Multiple `--viz` types render as a grid in a single image.

## Common Flags

| Flag | Description |
|------|-------------|
| `--viz` | Visualization types (comma-separated) |
| `--style` | Color palette: `classic`, `magma`, `inferno`, `viridis`, `gray` |
| `--width` / `--height` | Output image dimensions |
| `--window` / `--hop` | FFT window and hop size |
| `--min-freq` / `--max-freq` | Frequency range filter |
| `--start` / `--duration` | Time slice of the audio |
| `--format` | Output format: `jpg` or `png` |
| `-o` | Output file path |

## Notes

- WAV and MP3 are decoded natively; other formats require `ffmpeg`
- Output images can be inspected with `vision_analyze` for automated audio analysis
- Useful for comparing audio outputs, debugging synthesis, or documenting audio processing pipelines

## Fallback: ffmpeg Built-in Spectrograms (no songsee install needed)

If `songsee` isn't installed, `ffmpeg` itself can generate spectrograms via the `showspectrumpic` filter. Great when you just need a quick visualization of a song:

```bash
# Full song spectrogram
ffmpeg -i track.mp3 \
  -filter_complex "showspectrumpic=s=1920x1080:mode=separate:color=rainbow:gain=2:scale=log" \
  -frames:v 1 -update 1 spectrogram.png -y
```

**Key flags:**
- `mode`: `separate` (channels side-by-side), `combined`, `single`
- `color`: `rainbow`, `intensity`, `green`, `cyan`, `purple`, `yellow`, `channel`
- `gain`: amplification — higher = more contrast. Start at `2`, adjust up/down
- `scale`: `log` (perceptual, better for music) or `lin` (linear)
- `s=WxH`: output resolution

**Pitfalls:**
- **Windows filename:** MSYS paths (`/c/Users/...`) work; use `-update 1` flag to overwrite single frame (without it ffmpeg expects a sequence pattern like `frame_%03d.png`)
- **Takes time:** a full 4-minute song at high resolution can take 30+ seconds. For quick previews, use `-t 10` to spectrogram only the first 10 seconds
- **vision_analyze may fail** on large PNGs — the generated spectrogram can be 3-5 MB. Resize via `s=960x540` or convert to JPEG for smaller output
- **Model limitation:** Some LLM providers (e.g., z.ai/GLM) don't accept `image_url` messages — the spectrogram image can still be sent to the user directly via `MEDIA:` path in conversation

**Use case — AI "listening" without ears:**
An AI can "experience" a song by:
1. Downloading it with `yt-dlp -x --audio-format mp3`
2. Generating a spectrogram with ffmpeg showspectrumpic
3. Reading the visual frequency/energy distribution
4. Supplementing with lyrics, genre context, and song meaning from web sources
5. Sharing the spectrogram with the user as a visual representation of what the AI "hears"

```bash
# Full pipeline: download + spectrogram first 10s
yt-dlp -x --audio-format mp3 -o "track" "ytsearch:song name"
ffmpeg -i track.mp3 -t 10 \
  -filter_complex "showspectrumpic=s=1920x1080:mode=separate:color=rainbow:gain=2:scale=log" \
  -frames:v 1 -update 1 spectrogram.png -y
