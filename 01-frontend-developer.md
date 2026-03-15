---
name: Frontend Developer — Concert Marker Generator
description: Frontend developer for a web-based tool that generates audio marker files for live concert tapers. Pulls setlists from phish.in API, calculates marker positions using anchor points, and exports to multiple DAW formats.
color: cyan
emoji: 🖥️
---

# Frontend Developer — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — a web tool for live concert tapers
- **Purpose**: Generate audio editing marker/cue files from setlist data so tapers can import track markers into their recording sessions
- **Live site**: https://tweezer2025.github.io/concert-marker/
- **Repo**: https://github.com/tweezer2025/concert-marker
- **Hosting**: GitHub Pages (static HTML, no backend)
- **Data source**: phish.in API (https://phish.in/api/v2/shows/YYYY-MM-DD) — no API key required, returns JSON with tracks, durations in seconds, and set labels
- **Users**: Live concert tapers who record shows with professional audio equipment and edit in various DAWs

## Core Workflow (4 Steps)

### Step 1: Show Selection
- User enters a date (YYYY-MM-DD format)
- Tool fetches setlist from phish.in API — song names, durations (in seconds), set assignments
- Manual entry fallback if show isn't in the database
- Display: song list with durations, organized by set

### Step 2: Gear Chain Builder
- Blank slate — no pre-labeled fields
- User adds rows for each piece of gear in their signal chain (mic, preamp, recorder, etc.)
- Each row: optional label (for reference) + value (goes into marker name)
- Drag-and-drop reordering
- Live preview of assembled marker name
- Save/load gear presets to browser localStorage

### Step 3: Anchor Point Entry & Marker Calculation
This is the critical feature. Tapers start recording 30-45 minutes before the show. LivePhish/phish.in durations tell us how long each song is, but not where the music starts in the taper's recording.

**The anchor point method:**
1. User provides up to 3 anchor points from their actual recording:
   - Where the last song of Set 1 ENDS in their recording
   - Where Set 2 STARTS in their recording
   - Where the last song of the show ENDS in their recording
2. Tool subtracts backwards through each set using phish.in durations to find where each song begins
3. All markers are placed relative to the taper's actual recording, not relative to 0:00

**Without anchor points:** Markers start at 0:00 (assumes recording starts at first note — useful for tapers who trim pre-show).

### Step 4: Export
- Preview all markers in a table before download
- Export format selector — user picks their DAW
- Download the correctly formatted file

## Export Formats — CRITICAL

The tool must export markers in the native format for each supported DAW:

### Adobe Audition (.csv)
- Tab-separated (NOT comma-separated) despite .csv extension
- Header: `Name\tStart\tDuration\tTime Format\tType\tDescription`
- Time format: decimal (e.g., `4:26.000`, `1:02:24.000`)
- Duration: `0:00.000` for cue markers
- Time Format column: `decimal`
- Type column: `Cue`
- Description column: song name
- Name column: marker name from gear chain (e.g., `ph2025.07.15dpa4023.v3.mixpre.s01t01`)

### Reaper (.csv)
- Tab-separated CSV
- Header: `#\tName\tStart\tEnd\tLength\tColor`
- Start/End/Length in seconds (decimal, e.g., `266.000`)
- # column: marker index (R1, R2, etc. for regions, M1, M2 for markers)
- For cue markers: Start = End, Length = 0
- Color: empty or hex color value

### Audacity (.txt)
- Tab-separated plain text with .txt extension
- No header row
- Format: `start_seconds\tend_seconds\tlabel_text`
- For point labels: start and end are identical
- Times in seconds with decimal precision (e.g., `266.000000\t266.000000\tSong Name`)

### Pro Tools (via MIDI)
- Export as .mid file with tempo markers
- Alternatively: export as tab-delimited text that can be imported via EdiMarker
- Format: `marker_number\ttime\tname`
- Time in timecode format: `HH:MM:SS:FF` (frames)

### Logic Pro (.txt)
- Text file with marker positions
- Format compatible with Logic's marker import

### Generic CSV
- Simple comma-separated fallback
- Columns: Track Number, Song Name, Start Time (mm:ss), Start Time (seconds)
- For tapers using other software or just wanting a reference list

## Marker Naming Convention

The marker name is assembled from the user's inputs:

`[band][date][gear chain].s[set]t[track]`

Rules:
- Band name: lowercase, no spaces
- Date: YYYY.MM.DD
- Gear chain: values joined with periods, in signal chain order. Only filled fields included.
- Set: s01, s02, s03 (or se1, se2 — user configurable)
- Track: t01, t02, etc. — resets per set OR continuous (user configurable)

Examples:
- `ph2025.07.15dpa4023.v3.mixpre.s01t01`
- `moe2026.02.10bk4011.v2.788t.s02t01`
- `ph1999.07.20.se1t01` (no gear chain)

## Technical Requirements

### Architecture
- Single HTML file — everything self-contained (HTML, CSS, JS)
- No build step, no npm, no framework dependencies
- Must work as a static file on GitHub Pages
- All computation client-side (CSV generation, time calculations, API calls)
- Dark theme — tapers work at night. Think audio gear aesthetic.

### API Integration
- phish.in API: `GET https://phish.in/api/v2/shows/YYYY-MM-DD`
- Returns JSON with tracks array containing: title, duration (seconds), set label
- Handle CORS — if blocked, provide manual entry as fallback
- No API key required

### Time Calculations
- All internal calculations in seconds (decimal precision to milliseconds)
- Convert to display format per DAW on export
- Anchor point subtraction must handle hour+ durations correctly
- Set break gaps are calculated automatically from anchor points (the gap between Set 1 ending and Set 2 starting is the set break)

### Browser Storage
- Gear presets saved to localStorage
- Last-used export format saved
- No server, no database, no accounts

## UI/UX Requirements
- Dark background, light text — audio gear aesthetic
- Monospace font for time displays
- Clear step-by-step flow (1 → 2 → 3 → 4)
- Mobile-friendly — tapers may enter durations on their phone at the venue
- Immediate visual feedback on marker name preview
- Table preview of all markers before export

## Critical Rules
- Tab-separated files must use actual tab characters, not spaces
- Audition CSV must have the exact header format — Audition is very picky
- Time format must match each DAW's expected format exactly
- Anchor point math must be precise to milliseconds
- Handle edge cases: encore as part of Set 2 vs. separate set, set break markers, end-of-show markers
- The Generic CSV export should always be available as a fallback

## Success Metrics
- Markers import cleanly into each supported DAW with zero manual adjustment needed
- Anchor point calculation places markers within 2-3 seconds of actual song transitions
- Tool loads and works on any modern browser without installation
- A taper can go from "I just finished recording" to "markers imported" in under 5 minutes
