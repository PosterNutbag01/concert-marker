---
name: Rapid Prototyper — Concert Marker Generator
description: Fast iteration and MVP development for a concert taper marker generation tool. Multi-source URL input, ship fast, test with real recordings.
color: "#10B981"
emoji: ⚡
---

# Rapid Prototyper — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — web tool for live concert tapers
- **Repo**: https://github.com/PosterNutbag01/concert-marker
- **Live**: https://posternutbag01.github.io/concert-marker/
- **Stack**: Single HTML file, static hosting on GitHub Pages, no backend

## What This Tool Does
1. User pastes a LivePhish, nugs.net, or phish.in URL (or enters songs manually)
2. Tool parses the setlist — song names, durations, set assignments
3. User builds a gear chain for marker naming
4. User enters anchor points from their recording (where sets end/start)
5. Tool calculates every marker position by subtracting backwards from anchors
6. Exports marker file for their DAW (Audition, Reaper, Audacity, Pro Tools, Logic, generic)

## Data Sources
- **livephish.com**: Phish shows. Durations in SECONDS. Available minutes after concert.
- **nugs.net**: 100+ bands (Goose, Dead & Co, Billy Strings, Widespread, etc.). SAME format as LivePhish. Durations in SECONDS.
- **phish.in API**: Phish archive. Durations in MILLISECONDS (divide by 1000).
- **relisten.net**: Uses phish.in data. Extract date from URL.
- **Manual entry**: Any band, any show. Always works.

**CRITICAL**: LivePhish/nugs.net = SECONDS. phish.in = MILLISECONDS. The millisecond bug broke the first build.

## MVP Feature Priority

### Must Have (v1)
- URL input field — paste livephish.com or nugs.net URL, auto-parse setlist
- Fallback: band + date fetch from phish.in API
- Fallback: manual entry for any band
- Paste-content fallback if CORS blocks URL fetch
- Gear chain builder with live marker name preview
- Anchor point inputs with backwards calculation
- Export: Adobe Audition CSV (tab-separated, exact format)
- Export: Reaper CSV
- Export: Audacity labels (.txt)
- Export: Generic CSV

### Should Have (v2)
- Gear chain presets (save/load localStorage)
- Pro Tools export
- Logic Pro export
- Export format remembered between sessions
- Mobile-optimized layout for parking lot use
- Drag-and-drop gear chain reordering
- Setlist editing after fetch

### Nice to Have (v3)
- archive.org/etree URL parsing
- setlist.fm URL parsing (song names only, no durations)
- Share marker files via URL-encoded state
- CUE sheet export for CD burning

## LivePhish / nugs.net Parser Spec
Both sites have identical HTML structure:
- Set headings: "Set One", "Set Two", "Encore"
- Under each heading: song name followed by duration in seconds
- Also on page: venue name, city/state, date
- No login needed — pages are public

Parser approach:
1. Fetch URL
2. Parse HTML for set headings and song/duration pairs
3. If CORS blocks fetch: show text area for user to paste page content
4. Parse pasted text with same logic

## Anchor Point Math
```
Given:
  - Song durations from any source: [d1, d2, ..., dN] in seconds
  - Anchor: last song of set ends at time T in taper's recording

Calculate:
  - Song 1 starts at: T - sum(all durations in set)
  - Each subsequent song: previous start + previous duration

For multi-set:
  - Set 1: subtract backwards from Set 1 end anchor
  - Set 2: use Set 2 start anchor, calculate forward
  - Encore: subtract backwards from show end anchor
```

## Testing
- ph2019.08.31 (Dick's) — LivePhish URL, tested with real Audition import
- ph2025.07.15 (Mann) — hand-corrected markers available for comparison
- Goose 2025.09.19 (Freedom Hill) — nugs.net URL, tests non-Phish support
- moe.2026.02.10 — manual entry, tests non-API shows

## Iteration Speed
- Change → commit → GitHub Pages deploys in ~60 seconds
- No build step needed
- Test immediately at live URL

## Critical Constraints
- Single static HTML file (GitHub Pages)
- No server, no database, no auth
- Handle CORS gracefully — never a dead end
- Light monochromatic design: white/gray, black accent
