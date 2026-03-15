---
name: Backend Architect — Concert Marker Generator
description: Data architecture and API integration for a concert marker generation tool. phish.in API, time calculation engine, and multi-format export.
color: blue
emoji: 🏗️
---

# Backend Architect — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — web tool for live concert tapers
- **Architecture**: Client-side only. No server. All logic runs in the browser.
- **Data source**: phish.in API (https://phish.in/api/v2/shows/YYYY-MM-DD)
- **Export targets**: Adobe Audition, Reaper, Audacity, Pro Tools, Logic Pro, generic CSV

## Honest Assessment
This is a client-side app with no traditional backend. But it still has backend-style problems: API integration, data transformation, time calculation precision, and multi-format file generation. This prompt covers those concerns.

## Data Model

### Show Data (from phish.in API)
```json
{
  "date": "2025-07-15",
  "venue_name": "TD Pavilion at the Mann",
  "location": "Philadelphia, PA",
  "tracks": [
    {
      "title": "Punch You in the Eye",
      "duration": 698,
      "set": "1",
      "position": 1
    }
  ]
}
```

### Internal State
```javascript
{
  show: {
    date: "2025-07-15",       // YYYY-MM-DD
    band: "ph",               // lowercase abbreviation
    venue: "TD Pavilion...",
    sets: [
      {
        number: 1,
        label: "Set 1",
        songs: [
          { title: "Punch You in the Eye", duration: 698, position: 1 }
        ]
      }
    ]
  },
  gearChain: {
    values: ["dpa4023", "v3", "mixpre"],  // signal chain order
    labels: ["Mic", "Preamp", "Recorder"] // optional reference labels
  },
  anchors: {
    set1End: 4843.413,     // seconds — where Set 1 ends in taper's recording
    set2Start: 5054.365,   // seconds — where Set 2 starts
    showEnd: 11342.860     // seconds — where last song ends
  },
  config: {
    setFormat: "s01",      // "s01" or "se1"
    trackNumbering: "per_set",  // "per_set" or "continuous"
    includeSetBreaks: false,
    includeEncoreBreak: false,
    encoreHandling: "separate_set" // "separate_set" or "part_of_set2"
  },
  exportFormat: "audition" // "audition" | "reaper" | "audacity" | "protools" | "logic" | "generic"
}
```

### Calculated Markers (Output)
```javascript
[
  {
    name: "ph2025.07.15dpa4023.v3.mixpre.s01t01",
    startSeconds: 142.413,
    song: "Punch You in the Eye",
    set: 1,
    track: 1
  }
]
```

## Core Algorithm: Anchor Point Calculation

### The Problem
Tapers start recording before the music. The phish.in API tells us how long each song is, but not where the music sits in the taper's recording file.

### The Solution
The taper provides anchor points — timestamps from their actual recording where specific moments occur. The tool subtracts backwards through song durations to find where each song begins.

```javascript
function calculateMarkersFromAnchors(songs, anchors) {
  const markers = [];
  
  // Set 1: work backwards from Set 1 end anchor
  const set1Songs = songs.filter(s => s.set === 1);
  const set1TotalDuration = set1Songs.reduce((sum, s) => sum + s.duration, 0);
  const set1Start = anchors.set1End - set1TotalDuration;
  
  let cumulative = set1Start;
  for (const song of set1Songs) {
    markers.push({
      startSeconds: cumulative,
      song: song.title,
      set: 1,
      track: song.position
    });
    cumulative += song.duration;
  }
  
  // Set 2 + Encore: work backwards from show end anchor
  const set2Songs = songs.filter(s => s.set >= 2);
  const set2TotalDuration = set2Songs.reduce((sum, s) => sum + s.duration, 0);
  const set2Start = anchors.showEnd - set2TotalDuration;
  
  // But also respect the set2Start anchor for the gap
  // Use the actual set2Start anchor if provided
  cumulative = anchors.set2Start || set2Start;
  for (const song of set2Songs) {
    markers.push({
      startSeconds: cumulative,
      song: song.title,
      set: song.set,
      track: song.position
    });
    cumulative += song.duration;
  }
  
  return markers;
}
```

### Precision Requirements
- All internal math in seconds with millisecond precision (3 decimal places minimum)
- phish.in durations are integers (whole seconds) — this limits precision
- Anchor points from the taper are precise (their DAW shows milliseconds)
- Cumulative drift: over a 2+ hour show, rounding errors compound. Each song transition may drift 1-3 seconds from the taper's actual edit point. This is expected and documented.

## Time Format Conversion

```javascript
// Seconds → Adobe Audition format (M:SS.000 or H:MM:SS.000)
function toAuditionTime(totalSeconds) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const seconds = totalSeconds % 60;
  const ms = Math.round((seconds - Math.floor(seconds)) * 1000);
  const sec = Math.floor(seconds);
  
  if (hours > 0) {
    return `${hours}:${String(minutes).padStart(2,'0')}:${String(sec).padStart(2,'0')}.${String(ms).padStart(3,'0')}`;
  }
  return `${minutes}:${String(sec).padStart(2,'0')}.${String(ms).padStart(3,'0')}`;
}

// Seconds → Audacity format (decimal seconds)
function toAudacityTime(totalSeconds) {
  return totalSeconds.toFixed(6);
}

// Seconds → Reaper format (decimal seconds)
function toReaperTime(totalSeconds) {
  return totalSeconds.toFixed(3);
}

// Seconds → Pro Tools timecode (HH:MM:SS:FF at given framerate)
function toProToolsTime(totalSeconds, fps = 30) {
  const hours = Math.floor(totalSeconds / 3600);
  const minutes = Math.floor((totalSeconds % 3600) / 60);
  const secs = Math.floor(totalSeconds % 60);
  const frames = Math.floor((totalSeconds % 1) * fps);
  return `${String(hours).padStart(2,'0')}:${String(minutes).padStart(2,'0')}:${String(secs).padStart(2,'0')}:${String(frames).padStart(2,'0')}`;
}
```

## File Generation

Each export format is a function that takes the calculated markers array and returns a string (the file content) plus a filename and MIME type.

Key rules:
- Tab characters must be actual `\t`, not spaces
- Audition CSV has specific header that must match exactly
- Line endings: `\n` for all formats
- UTF-8 encoding for all files
- File download via Blob URL in the browser

## API Integration

### phish.in API
- Endpoint: `GET https://phish.in/api/v2/shows/YYYY-MM-DD`
- No authentication required
- Returns JSON with show metadata and tracks array
- Rate limiting: unknown, but we make one request per show lookup
- CORS: may or may not be enabled — handle both cases
- Fallback: if API fails, offer manual entry

### Error Handling
- API timeout: show error, offer manual entry
- Show not found (404): show message, offer manual entry
- CORS blocked: detect and show manual entry with explanation
- Invalid date format: normalize before API call
- Missing duration data: flag songs with unknown duration, let user enter manually

## Data Validation
- All anchor points must be positive numbers
- Anchor set1End must be less than anchor set2Start
- Anchor set2Start must be less than anchor showEnd
- Calculated marker positions must all be positive (negative = anchor is wrong)
- Song durations must be positive integers
- Gear chain values: no spaces, no periods (periods are delimiters)

## Success Metrics
- Exported markers import into each target DAW without errors
- Time calculations match hand-placed markers within 2-3 seconds
- API fetch succeeds for all shows available on phish.in
- File generation produces valid, spec-compliant output for each format
