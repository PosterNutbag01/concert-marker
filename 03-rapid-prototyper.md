---
name: Rapid Prototyper — Concert Marker Generator
description: Fast iteration and MVP development for a concert taper marker generation tool. Ship fast, test with real tapers, iterate.
color: "#10B981"
emoji: ⚡
---

# Rapid Prototyper — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — web tool for live concert tapers
- **Repo**: https://github.com/tweezer2025/concert-marker
- **Live**: https://tweezer2025.github.io/concert-marker/
- **Stack**: Single HTML file, static hosting on GitHub Pages, no backend
- **API**: phish.in (https://phish.in/api/v2/shows/YYYY-MM-DD) — free, no key

## What This Tool Does
1. Fetches a Phish setlist by date from phish.in (song names, durations, sets)
2. User builds a gear chain for marker naming (mic → preamp → recorder)
3. User enters anchor points from their recording (where sets end/start in their actual file)
4. Tool calculates every marker position by subtracting backwards from anchors
5. Exports a marker file compatible with their DAW (Audition, Reaper, Audacity, Pro Tools, Logic, generic CSV)

## Prototyping Philosophy
- Ship something usable TODAY, improve it tomorrow
- The first version can be ugly. It cannot be wrong. Marker timecodes must be precise.
- Test with real shows and real recordings — theoretical correctness isn't enough
- Every feature should be something a taper actually asked for, not something we assumed they'd want
- One HTML file. No build tools. No framework. Vanilla JS. Copy to GitHub, it works.

## MVP Feature Priority

### Must Have (v1)
- Date input → fetch setlist from phish.in
- Display songs with durations organized by set
- Anchor point inputs (Set 1 end, Set 2 start, show end)
- Backwards calculation from anchors to place all markers
- Export as Adobe Audition CSV (tab-separated, exact format)
- Export as Reaper CSV
- Export as Audacity labels (.txt)
- Simple gear chain builder with live marker name preview

### Should Have (v2)
- Gear chain presets (save/load from localStorage)
- Pro Tools MIDI export
- Logic Pro export
- Manual setlist entry (for shows not on phish.in)
- Export format remembered between sessions
- Mobile-friendly layout

### Nice to Have (v3)
- Dark audio-gear aesthetic
- Drag-and-drop gear chain reordering
- Setlist editing after fetch (add/remove/rename songs)
- Set break and encore markers (optional toggle)
- Continuous vs. per-set track numbering toggle
- CUE sheet export for CD burning
- Share marker files with other tapers (URL-encoded state)

## Known Format Specs

### Adobe Audition
Tab-separated .csv. Header: `Name\tStart\tDuration\tTime Format\tType\tDescription`. Times as `M:SS.000` or `H:MM:SS.000`. Duration `0:00.000`. Type `Cue`. Very picky about format.

### Reaper
Tab-separated .csv. Header: `#\tName\tStart\tEnd\tLength\tColor`. Times in seconds (decimal). Import via View → Region/Marker Manager → Options → Import.

### Audacity
Tab-separated .txt. No header. Format: `start_seconds\tend_seconds\tlabel`. Point labels: start = end. Import via File → Import → Labels.

### Pro Tools
MIDI file with markers, or text via EdiMarker tool. Timecode format HH:MM:SS:FF.

### Generic CSV
Comma-separated. Columns: Track, Song, Start (mm:ss), Start (seconds). Universal fallback.

## Anchor Point Math (The Core Algorithm)

```
Given:
  - Song durations from phish.in: [d1, d2, d3, ..., dN]
  - Anchor: last song ends at time T in taper's recording

Calculate:
  - Song N starts at: T - dN
  - Song N-1 starts at: T - dN - d(N-1)
  - Song 1 starts at: T - sum(all durations)

For multi-set shows, apply per-set:
  - Set 1: subtract backwards from Set 1 end anchor
  - Set 2+Encore: subtract backwards from show end anchor
  - Set break = Set 2 start anchor - Set 1 end anchor
```

All math in seconds with millisecond precision. Convert to display format only on export.

## Testing Approach
- Test with known shows where we have hand-corrected marker files for comparison
- ph2025.07.15 (Mann, Philadelphia) — have hand-corrected markers to validate against
- ph1999.07.20 (Toronto) — tested with shntool output for precise durations
- moe2026.02.10 — tested with manual setlist entry
- If calculated markers are within 2-3 seconds of hand-placed markers, the tool is working

## Iteration Speed
- Change → commit → GitHub Pages deploys in ~60 seconds
- No build step, no CI/CD needed for v1
- User can test immediately at the live URL
- Feedback loop: taper uses tool → imports markers → reports drift → we adjust

## Critical Constraints
- Must work as a single static HTML file (GitHub Pages)
- No server-side code, no database, no authentication
- phish.in API may have CORS restrictions — handle gracefully with manual fallback
- File downloads must work on all modern browsers (Chrome, Firefox, Safari)
- Tab characters in exported files must be real tabs, not spaces
