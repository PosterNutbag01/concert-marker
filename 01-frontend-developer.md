---
name: Frontend Developer — Concert Marker Generator
description: Frontend developer for a web-based tool that generates audio marker files for live concert tapers. Parses setlists from URLs (LivePhish, nugs.net, phish.in, archive.org) or manual entry, calculates marker positions using anchor points, and exports to multiple DAW formats.
color: cyan
emoji: 🖥️
---

# Frontend Developer — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — a web tool for live concert tapers
- **Purpose**: Generate audio editing marker/cue files from setlist data so tapers can import track markers into their recording sessions
- **Live site**: https://posternutbag01.github.io/concert-marker/
- **Repo**: https://github.com/PosterNutbag01/concert-marker
- **Hosting**: GitHub Pages (static HTML, no backend)
- **Users**: Live concert tapers who record shows with professional audio equipment and edit in various DAWs
- **Bands supported**: Any live band — Phish, Goose, Dead & Company, Billy Strings, Widespread Panic, moe., Umphrey's McGee, Trey Anastasio Band, String Cheese Incident, and any band on nugs.net or with a setlist online

## Data Sources — URL-Based Approach

The user either pastes a URL or enters band + date or enters songs manually. Three paths to the same result.

### Option A: Paste a URL (Primary Method)
The user pastes a URL. The tool detects the domain and parses accordingly:

**livephish.com** (Phish, available minutes after show)
- Example: `https://www.livephish.com/LP-2666.html`
- Fetch page HTML, parse song names and durations from setlist section
- Durations in SECONDS (e.g., `413` = 6:53)
- Songs under `Set One`, `Set Two`, `Encore` headings
- No login required — publicly accessible

**nugs.net** (100+ bands — Goose, Dead & Co, Billy Strings, Widespread, etc.)
- Example: `https://www.nugs.net/live-download-of-goose-.../44155.html`
- IDENTICAL page format to LivePhish — same parser works for both
- Durations in SECONDS, organized by set
- No login required

**phish.in** (Phish archive)
- Example: `https://phish.in/2025-07-15`
- API: `GET https://phish.in/api/v2/shows/YYYY-MM-DD`
- Durations in MILLISECONDS (divide by 1000)
- No API key required

**relisten.net** (uses phish.in data)
- Example: `https://relisten.net/phish/2025/07/15`
- Extract date from URL, hit phish.in API

**archive.org/etree** (all bands, taper community — future)
- Example: `https://archive.org/details/gd1977-05-08.sbd...`
- Parse track listing from page

### URL Detection Logic
```javascript
function detectSource(url) {
  if (url.includes('livephish.com')) return 'livephish';
  if (url.includes('nugs.net')) return 'nugs';
  if (url.includes('phish.in')) return 'phishin';
  if (url.includes('relisten.net')) return 'relisten';
  if (url.includes('archive.org')) return 'archive';
  return 'unknown';
}
```

### LivePhish / nugs.net Page Parser
Both sites use identical structure. The parser should:
1. Fetch page HTML
2. Find set headings (`Set One`, `Set Two`, `Encore`)
3. Extract song names and adjacent duration numbers (in seconds)
4. Extract venue, location, date
5. Return: `{ venue, date, sets: [{ label, songs: [{ title, duration }] }] }`

**CRITICAL**: LivePhish/nugs.net = SECONDS. phish.in = MILLISECONDS.

### CORS Handling
Fetching external sites may be blocked by CORS. Solutions in order:
1. Try direct fetch first
2. If blocked: "Paste Content" fallback — taper copies setlist from the page and pastes as text, parser reads same format
3. Manual entry always works

### Option B: Enter Band + Date
- Tries phish.in API for Phish shows
- Future: setlist.fm API for other bands

### Option C: Manual Entry
- Type song names and durations by hand
- Works for any band, any show, no internet needed

## Core Workflow (4 Steps)

### Step 1: Show Selection
- **URL field** prominent at top: "Paste a LivePhish, nugs.net, or phish.in URL"
- **OR** Band + Date fields with fetch button
- **OR** Manual entry
- Display: song list with durations, organized by set
- Show venue name and date as confirmation

### Step 2: Gear Chain Builder
- Blank slate — add rows for each piece of gear
- Each row: optional label + value (goes in marker name)
- Drag-and-drop reordering
- Live preview of marker name
- Save/load presets via localStorage

### Step 3: Anchor Points
- Three timecode inputs from taper's actual recording
- Tool subtracts backwards to place all markers
- Skip option for markers starting at 0:00

### Step 4: Export
- DAW selector: Audition, Reaper, Audacity, Pro Tools, Logic, Generic CSV
- Table preview of all markers
- Download button

## Export Formats

### Adobe Audition (.csv)
- Tab-separated, .csv extension
- Header: `Name\tStart\tDuration\tTime Format\tType\tDescription`
- Times: `M:SS.000` or `H:MM:SS.000`. Duration: `0:00.000`. Type: `Cue`. Time Format: `decimal`

### Reaper (.csv)
- Tab-separated. Header: `#\tName\tStart\tEnd\tLength\tColor`
- Times in decimal seconds. Cue markers: Start = End, Length = 0

### Audacity (.txt)
- Tab-separated, no header. Format: `start_seconds\tend_seconds\tlabel_text`
- Point labels: start = end

### Pro Tools (text)
- Tab-delimited for EdiMarker import. Format: `marker_number\ttime\tname`
- Time as `HH:MM:SS:FF` (30fps)

### Logic Pro (.txt)
- Text file with marker positions

### Generic CSV
- Comma-separated. Columns: Track, Song, Start (mm:ss), Start (seconds)

## Marker Naming Convention
`[band][date][gear chain].s[set]t[track]`

- Band: lowercase, no spaces (ph, goo, moe, wsp, bsm, etc.)
- Date: YYYY.MM.DD
- Gear: values joined with periods
- Set/Track: configurable format, resets per set or continuous

## Technical Requirements
- Single HTML file, no build step, GitHub Pages
- Light monochromatic theme: white/gray, black accent
- Fonts: Plus Jakarta Sans (headings), Inter (body), IBM Plex Mono (timecodes)
- All computation client-side
- Mobile-friendly — tapers use this on their phone after shows

## Critical Rules
- LivePhish/nugs.net durations = SECONDS. phish.in = MILLISECONDS. Never confuse.
- Tab-separated files must use real tab characters
- Audition CSV format must be exact
- If URL fetch fails, offer paste-content fallback then manual entry
- Handle: encores, songs appearing twice, set breaks, hour+ durations

## Success Metrics
- Paste a LivePhish URL → markers ready in under 2 minutes
- Works for any band on nugs.net, not just Phish
- Markers import cleanly into all supported DAWs
- Anchor point calculation within 2-3 seconds of actual transitions
