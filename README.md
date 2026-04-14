# concert-marker

Audio marker generator for live concert tapers. Fetch a setlist from phish.in or archive.org, build your signal-chain marker names, set three anchor timecodes, and export markers to the DAW of your choice.

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

Anchors map the real audio timeline onto the setlist durations:

- **Anchor 1:** where the last song of Set 1 ENDS
- **Anchor 2:** where Set 2 STARTS
- **Anchor 3:** where the very last song ENDS (usually end of encore)

Leave all three blank for markers starting at `0:00`. Intermediate sets with no anchor stack from the previous set's end with no gap.

## Features

- Fetch setlists from **phish.in** (any date) or **archive.org** (etree identifiers)
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
