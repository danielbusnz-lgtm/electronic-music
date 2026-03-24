# Voltage Drop

An EDM track built entirely from code using [SuperCollider](https://supercollider.github.io/) — no samples, no DAW, no presets. Every sound is synthesized from scratch: kick drums, snares, hi-hats, bass, lead, and pads are all constructed from raw oscillators, noise generators, and envelopes.

## Listen

[`track1.mp3`](track1.mp3) — 130 BPM, key of C minor

## How It Works

The track is a single SuperCollider script (`track1.scd`) that:

- **Defines 6 synths from scratch** — 808-style kick, snare, hi-hat, sub bass, saw lead with vibrato, and a reverb pad
- **Sequences patterns** using SuperCollider's `Pbind` pattern system
- **Arranges sections programmatically** — intro, build, drop, breakdown, second drop, and outro
- **Records to disk** — the script boots the audio server, plays the arrangement, and writes the output to a file

## Track Structure

| Section | Bars | Description |
|---------|------|-------------|
| Intro | 1–2 | Kick + hi-hats + bass |
| Build | 3–4 | Snare enters |
| Drop | 5–12 | Lead + pad, full energy |
| Breakdown | 13–16 | Pad + lead only, drums cut |
| Drop 2 | 17–28 | Everything back |
| Outro | 29–32 | Lead drops out, wind down |

## Run It Yourself

```bash
# Install SuperCollider: https://supercollider.github.io/downloads
sclang track1.scd
```

This will boot the SC server, play the track, record `track.wav`, and exit.

## Tech

- **Language:** SuperCollider (sclang)
- **Synthesis:** Additive, subtractive, FM
- **Tempo:** 130 BPM
- **Duration:** ~60 seconds
