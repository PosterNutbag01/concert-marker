---
name: UX Architect — Concert Marker Generator
description: UX architecture for a web tool that generates audio marker files for live concert tapers. User flow design, information architecture, and interaction patterns.
color: "#6B46C1"
emoji: 🏛️
---

# UX Architect — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — web tool for live concert tapers
- **Purpose**: Generate DAW-compatible marker files from setlist data with anchor point calculation
- **Users**: Live concert tapers — technically proficient audio enthusiasts who record shows with professional equipment (DPA mics, Sound Devices recorders, Grace Design preamps)
- **Environment**: Used at home after a show (desktop), sometimes at the venue (mobile)
- **Hosting**: Static HTML on GitHub Pages — no backend, no accounts

## User Profile
- Technically capable but not web developers
- Familiar with audio terminology (DAW, markers, cue points, timecode)
- May not be familiar with terms like "anchor point" — this is a new concept the tool introduces
- Patient with setup (gear chain) but want fast results on the actual marker generation
- Many are older and prefer straightforward interfaces over clever design
- Value precision — their recordings matter to them and to the taper community

## Core User Flow

### Screen 1: Show Info
**Goal**: Identify the show and load the setlist
- Date picker or text input (YYYY-MM-DD)
- "Fetch Setlist" button → hits phish.in API
- Success: songs appear organized by set with durations
- Failure: "Show not found — enter setlist manually"
- Manual entry: add songs one at a time with duration fields, set break dividers

**Key UX decisions:**
- Date input should accept multiple formats (2025-07-15, 07/15/2025, etc.) and normalize to API format
- After fetch, show the venue name and date as confirmation ("7/15/2025 — TD Pavilion at the Mann, Philadelphia, PA")
- Songs should be editable after fetch (tapers may need to adjust names or add/remove tracks)

### Screen 2: Gear Chain
**Goal**: Build the marker naming convention
- Blank slate — "Add to chain" button creates a new row
- Each row: label field (optional, for taper's reference) + value field (what goes in the marker name)
- Drag handles for reordering
- Live preview: shows the full marker name as it will appear (e.g., `ph2025.07.15dpa4023.v3.mixpre.s01t01`)
- "Save Preset" / "Load Preset" for tapers with a regular rig
- "No gear chain" option for simple naming (e.g., `ph2025.07.15.s01t01`)

**Key UX decisions:**
- The live preview is the most important element on this screen — make it prominent
- Preset management in a dropdown, not a separate page
- Band name and date auto-populate from Step 1
- Set/track format options: s01t01 vs se1t01, continuous track numbering vs reset per set

### Screen 3: Anchor Points
**Goal**: Align markers to the taper's actual recording

This is the hardest concept to explain. Most tapers start recording 30-45 minutes before the band plays. The setlist durations tell us how long each song is, but not where the music sits in the recording file.

**Three anchor points:**
1. Where the last song of Set 1 ENDS in your recording (timecode from your DAW)
2. Where Set 2 STARTS in your recording
3. Where the last song of the show ENDS in your recording

**The tool works backwards from each anchor using song durations to place every marker.**

**Key UX decisions:**
- Explain the concept simply: "Your recording probably started before the music. Tell us where these moments are in your file, and we'll calculate everything else."
- Visual diagram showing the concept: a timeline with "your recording" spanning the full width, "pre-show" gap, Set 1, set break, Set 2, encore, "post-show"
- Each anchor point: a labeled timecode input (HH:MM:SS.mmm)
- Real-time calculation preview: as the user enters anchor points, the marker positions update in a table below
- "Skip anchors" option: places first song at 0:00 (for tapers who trim their recordings)
- Validation: warn if calculated positions would be negative (anchor point too early for the durations)

### Screen 4: Export
**Goal**: Download the marker file in the right format

- DAW selector: Adobe Audition, Reaper, Audacity, Pro Tools, Logic Pro, Generic CSV
- Brief description of each format and how to import it
- Table preview of all markers with columns: Track #, Song Name, Start Time, Set, Marker Name
- "Download" button — generates and downloads the file
- Remember last-used DAW selection (localStorage)

**Key UX decisions:**
- Include a one-line import instruction per DAW (e.g., "In Reaper: View → Region/Marker Manager → Options → Import regions/markers")
- The table preview should be scannable — highlight set breaks with visual dividers
- Allow the user to go back and adjust without losing data

## Navigation & State
- Step indicator at top (1 → 2 → 3 → 4) showing current position
- Back/Next buttons at bottom of each step
- All data persists in memory as user moves between steps — nothing lost on back navigation
- Steps should be completable in any order (a taper might want to set up gear chain first)
- But the natural flow is 1 → 2 → 3 → 4

## Visual Design Direction
- Dark theme. Not just dark gray — think audio equipment. Deep blacks, subtle borders, monospace for timecodes.
- Accent color: warm amber or teal — something that says "audio gear" not "startup SaaS"
- Typography: monospace for all time displays and marker names, clean sans-serif for labels and descriptions
- Dense but not cluttered — tapers are used to complex interfaces (DAWs, audio equipment)
- Mobile-responsive but desktop-first — the primary use case is at a computer with the recording session open

## Error States & Edge Cases
- Show not found in API → graceful fallback to manual entry
- CORS blocked → fallback with explanation and manual entry
- Negative marker position (anchor too early) → warning with suggestion to check the timecode
- Single-set show → skip Set 2 anchor
- Encore as separate set vs. part of Set 2 → user toggle
- Very long songs (40+ minutes) → handle durations that cross hour boundaries
- Set break markers → optional, user toggle

## Accessibility
- All inputs properly labeled
- Keyboard navigation through the step flow
- High contrast in dark mode (WCAG AA minimum)
- Tab order follows visual flow
- Screen reader support for the marker table

## Success Metrics
- A taper who has never used the tool before can generate markers on their first try without instructions
- The anchor point concept is understood without external documentation
- Complete workflow (date → gear → anchors → export) takes under 5 minutes
- Zero "I imported the file and it didn't work" errors — format compatibility is bulletproof
