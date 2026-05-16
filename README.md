# concert-marker

Audio marker generator for live concert tapers. Fetch a setlist from phish.in, archive.org, or nugs.net, build your signal-chain marker names, anchor each set to your recording, and export markers to the DAW of your choice.

**Live:** <https://posternutbag01.github.io/concert-marker/> (if GitHub Pages is enabled for this repo)

## Export formats

- Adobe Audition (`.csv`)
- Reaper (`.csv`)
- Audacity labels (`.txt`)
- Pro Tools (text)
- Logic Pro (`.txt`)
- **CUE sheet (`.cue`)** — for single-file FLAC/WAV splits (foobar2000, XLD, shntool, CUETools)
- Generic CSV

Plus a separate info text file (`band.YYYY.MM.DD.gearchain.txt`) with source, lineage, taper credits, and the setlist.

## How anchors work

For each set you get two timecode fields: where the first note hits, and where the last note ends. When both are filled in, every song in that set is scaled proportionally to fit the real elapsed time — no drift, even when the reference durations from phish.in / archive.org / nugs.net don't match your recording exactly.

Per-set rules:

- **Start + End filled** → proportional scaling. Every marker lands in the right place.
- **Only Start** → no scaling, songs stack at their reference durations from your start time.
- **Only End** → start is back-calculated; last song's end lines up, earlier songs may drift.
- **Both blank** → first set starts at `0:00`, later sets stack onto the previous set's end.

For shows with 3+ sets, every set gets its own pair of fields. Fetch a setlist in Step 1 — the anchor form rebuilds itself around the actual set count.

## Features

- Fetch setlists from **phish.in** (any date), **archive.org** (etree identifiers), or **nugs.net** (paste any live-download URL)
- Drag-reorder signal chain rows; preview marker names live
- Autosave — refresh won't throw away your work
- Copy markers to clipboard in any format
- Marker name format: `ph2019.08.31.dpa4023.m101.788t.s01t01`

## Local dev

It's a single `index.html`. Open it in any browser. No build step.

```bash
open index.html
```

Built for tapers.
