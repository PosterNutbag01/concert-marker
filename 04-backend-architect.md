---
name: Backend Architect — Concert Marker Generator
description: Data architecture, URL parsing, time calculations, and multi-format export for a concert marker generation tool. Handles LivePhish, nugs.net, phish.in, and manual data sources.
color: blue
emoji: 🏗️
---

# Backend Architect — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — client-side web tool for concert tapers
- **Architecture**: No server. All logic runs in the browser.
- **Data sources**: LivePhish URLs, nugs.net URLs, phish.in API, manual entry
- **Export targets**: Adobe Audition, Reaper, Audacity, Pro Tools, Logic Pro, generic CSV

## Data Sources & Parsing

### LivePhish + nugs.net (Same Format)
Both sites owned by nugs.net, identical HTML structure. Pages are publicly accessible.

**What the page contains:**
```
Set One
Runaway Jim          413
Foam                 480
Horn                 246
...

Set Two
The Landlady         262
Possum               544
...

Encore
Bouncing Around the Room   237
Highway To Hell            238
```

- Durations are in SECONDS
- Song name and duration are adjacent in the HTML
- Set labels: "Set One", "Set Two", "Encore" (or "Set 1", "Set 2")
- Also available: venue name, city, state, date

**Parser must handle:**
- Songs appearing twice in the same set (e.g., Tweezer > Manteca > Tweezer)
- Songs with special characters (!, &, apostrophes)
- Variable set count (some shows have 3 sets)
- Encore may be labeled "Encore" or "Encore 1", "Encore 2"

### phish.in API
- Endpoint: `GET https://phish.in/api/v2/shows/YYYY-MM-DD`
- Returns JSON with tracks array
- **Durations in MILLISECONDS** — always divide by 1000
- Set field: "1", "2", "3", "E" for encore
- No API key required

### Manual Entry
- User provides song names and durations directly
- Durations entered as M:SS or H:MM:SS
- User marks set breaks manually

## Internal Data Model
```javascript
{
  show: {
    date: "2025-07-15",
    band: "ph",
    venue: "TD Pavilion at the Mann",
    source: "livephish",  // "livephish" | "nugs" | "phishin" | "manual"
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
    values: ["dpa4023", "v3", "mixpre"],
    labels: ["Mic", "Preamp", "Recorder"]
  },
  anchors: {
    set1End: 4843.413,
    set2Start: 5054.365,
    showEnd: 11342.860
  },
  config: {
    setFormat: "s01",
    trackNumbering: "per_set",
    encoreHandling: "separate_set"
  },
  exportFormat: "audition"
}
```

**CRITICAL RULE**: All durations stored internally in SECONDS regardless of source. Convert at parse time:
- LivePhish/nugs.net: use as-is (already seconds)
- phish.in: divide by 1000
- Manual entry: parse M:SS to seconds

## URL Detection & Routing
```javascript
function detectAndFetch(input) {
  const url = input.trim();
  
  if (url.includes('livephish.com') || url.includes('nugs.net')) {
    return fetchAndParseNugsPage(url);  // same parser for both
  }
  if (url.includes('phish.in')) {
    const date = extractDateFromPhishinUrl(url);
    return fetchPhishinApi(date);
  }
  if (url.includes('relisten.net')) {
    const date = extractDateFromRelistenUrl(url);
    return fetchPhishinApi(date);
  }
  if (url.includes('archive.org')) {
    return fetchAndParseArchivePage(url);  // future
  }
  
  return { error: 'Unrecognized URL. Try manual entry.' };
}
```

## Anchor Point Calculation Algorithm

```javascript
function calculateMarkersFromAnchors(sets, anchors) {
  const markers = [];
  
  sets.forEach((set, setIdx) => {
    const totalDur = set.songs.reduce((sum, s) => sum + s.duration, 0);
    let setStart = 0;

    if (setIdx === 0 && anchors.set1End !== null) {
      // Set 1: subtract total duration from end anchor
      setStart = anchors.set1End - totalDur;
    } else if (setIdx === 1 && anchors.set2Start !== null) {
      // Set 2: use start anchor directly
      setStart = anchors.set2Start;
    } else if (setIdx >= 2 && anchors.showEnd !== null) {
      // Encore/later sets: subtract backwards from show end
      const laterDur = sets.slice(setIdx)
        .reduce((sum, s) => sum + s.songs.reduce((ss, song) => ss + song.duration, 0), 0);
      setStart = anchors.showEnd - laterDur;
    } else if (setIdx > 0 && !anchors.set2Start) {
      // No anchors for this set — stack after previous set
      let cumulative = 0;
      for (let i = 0; i < setIdx; i++) {
        cumulative += sets[i].songs.reduce((sum, s) => sum + s.duration, 0);
      }
      setStart = cumulative;
    }

    let cumTime = setStart;
    set.songs.forEach((song, songIdx) => {
      markers.push({
        startSeconds: cumTime,
        song: song.title,
        set: set.number,
        setLabel: set.label,
        track: songIdx + 1,
        duration: song.duration
      });
      cumTime += song.duration;
    });
  });
  
  return markers;
}
```

## Time Format Conversions

```javascript
// Seconds → Adobe Audition (M:SS.000 or H:MM:SS.000)
function toAuditionTime(totalSeconds) {
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const sec = Math.floor(totalSeconds % 60);
  const ms = Math.round((totalSeconds % 1) * 1000);
  if (h > 0) return `${h}:${String(m).padStart(2,'0')}:${String(sec).padStart(2,'0')}.${String(ms).padStart(3,'0')}`;
  return `${m}:${String(sec).padStart(2,'0')}.${String(ms).padStart(3,'0')}`;
}

// Seconds → Audacity (decimal seconds, 6 places)
function toAudacityTime(s) { return s.toFixed(6); }

// Seconds → Reaper (decimal seconds, 3 places)
function toReaperTime(s) { return s.toFixed(3); }

// Seconds → Pro Tools timecode (HH:MM:SS:FF at 30fps)
function toProToolsTime(totalSeconds) {
  const h = Math.floor(totalSeconds / 3600);
  const m = Math.floor((totalSeconds % 3600) / 60);
  const sec = Math.floor(totalSeconds % 60);
  const frames = Math.floor((totalSeconds % 1) * 30);
  return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(sec).padStart(2,'0')}:${String(frames).padStart(2,'0')}`;
}
```

## Data Validation
- All durations must be positive numbers
- All anchor points must be positive
- Set 1 End anchor < Set 2 Start anchor < Show End anchor
- Calculated marker positions must all be positive (negative = bad anchor)
- Song titles: preserve special characters, trim whitespace
- Gear chain values: no spaces, no periods (periods are delimiters)

## CORS Strategy
1. Try direct fetch for all URLs
2. If livephish.com or nugs.net blocks: show "Paste Content" text area
3. Parse pasted text with same logic as HTML parsing — song names and durations in same format
4. phish.in API likely allows CORS — should work directly
5. Manual entry always works — zero external dependencies

## Success Metrics
- Correct duration parsing from all sources (seconds vs milliseconds)
- Time calculations match hand-placed markers within 2-3 seconds
- Exported files import cleanly into each target DAW
- Graceful fallback when CORS blocks a fetch
