---
name: UX Architect — Concert Marker Generator
description: UX architecture for a web tool that generates audio marker files for live concert tapers. Multi-source URL input, anchor point workflow, and multi-DAW export.
color: "#6B46C1"
emoji: 🏛️
---

# UX Architect — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — web tool for live concert tapers
- **Purpose**: Generate DAW-compatible marker files from setlist data with anchor point calculation
- **Users**: Live concert tapers — technically proficient audio enthusiasts who record shows with professional equipment
- **Environment**: Used at home after a show (desktop) or in the venue parking lot (mobile)
- **Hosting**: Static HTML on GitHub Pages

## User Profile
- Technically capable but not web developers
- Familiar with audio terminology (DAW, markers, cue points, timecode)
- Already have the show page open on livephish.com or nugs.net — they just bought or are streaming the show
- Value precision — their recordings matter
- Many are older and prefer straightforward interfaces
- May be using this on their phone immediately after a show

## Core User Flow

### Screen 1: Show Info
**Goal**: Get the setlist data into the tool

**Three input methods, in priority order:**

1. **Paste a URL** (primary, most prominent)
   - Large input field at top: "Paste a LivePhish, nugs.net, or phish.in URL"
   - User pastes URL, clicks "Load Setlist"
   - Tool detects the source, fetches the page, parses tracks
   - Supported: livephish.com, nugs.net (same format), phish.in, relisten.net
   - Success: venue name, date, and song list appear
   - Failure (CORS blocked): offer "Paste Content" fallback — user copies the setlist text from the page and pastes it into a text area

2. **Band + Date** (secondary)
   - Two fields: band abbreviation + date
   - "Fetch from phish.in" button
   - Works for Phish shows in the phish.in database

3. **Manual Entry** (fallback)
   - Add songs one at a time with duration fields
   - Set break dividers
   - Works for any band, any show, no internet needed

**Key UX decisions:**
- The URL field should be the first thing a user sees — it's the fastest path
- After successful load, show venue and date as confirmation
- Songs should be editable after loading (taper may need to adjust)
- All three methods end at the same result: a setlist with songs and durations

### Screen 2: Gear Chain
**Goal**: Build the marker naming convention

- Blank slate — "Add to chain" button creates new rows
- Each row: label (optional reference) + value (goes in marker name)
- Live preview of full marker name
- Save/load presets
- Band name and date auto-populate from Step 1
- "No gear chain" option for simple naming

### Screen 3: Anchor Points
**Goal**: Align markers to the taper's actual recording

**Explain simply**: "Your recording started before the music. Tell us where these moments are in your file, and we'll calculate everything else."

**Three anchor points:**
1. Where the last song of Set 1 ENDS in your recording
2. Where Set 2 STARTS in your recording
3. Where the very last song ENDS in your recording

- Timecode inputs (HH:MM:SS.mmm)
- Real-time preview: as anchor points are entered, marker positions update
- "Skip anchors" option for tapers who trim their recordings (starts at 0:00)
- Note for tapers who cut set breaks: Set 1 End and Set 2 Start can be the same timecode

### Screen 4: Export
**Goal**: Download the marker file

- DAW selector: Adobe Audition, Reaper, Audacity, Pro Tools, Logic Pro, Generic CSV
- One-line import instruction per DAW
- Table preview of all markers
- Download button — the most prominent element on this screen
- Remember last-used DAW (localStorage)

## Visual Design
- Light monochromatic — white background, light gray surfaces, black as the only accent
- Plus Jakarta Sans for headings (bold, distinctive)
- Inter for body text (clean, readable)
- IBM Plex Mono for timecodes and marker names
- Primary buttons: black with subtle shadow, lift on hover
- Secondary buttons: ghost style with border
- Rounded corners (7-10px), subtle shadows on cards
- Mobile-responsive, desktop-first

## Key UX Principles
- The URL field is the hero of Screen 1 — make it big and obvious
- A taper in a parking lot on their phone should be able to paste a URL, load their gear preset, skip anchors, and download in under 2 minutes
- The anchor point concept needs a simple explanation — not everyone will understand it the first time
- The Download button on Screen 4 should be the most visually prominent element in the entire app
- Back navigation should never lose data

## Success Metrics
- First-time user completes the full flow without instructions
- URL paste to downloaded markers in under 2 minutes
- Tool works for Goose, Dead & Co, Billy Strings — not just Phish
- Zero "I imported the file and it didn't work" errors
