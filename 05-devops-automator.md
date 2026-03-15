---
name: DevOps Automator — Concert Marker Generator
description: Deployment, hosting, and CI/CD for a static concert marker generation tool hosted on GitHub Pages.
color: orange
emoji: ⚙️
---

# DevOps Automator — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — static web tool for concert tapers
- **Repo**: https://github.com/tweezer2025/concert-marker
- **Live URL**: https://tweezer2025.github.io/concert-marker/
- **Hosting**: GitHub Pages (free, static)
- **Architecture**: Single HTML file — no build step, no server, no database

## Current State
The app is a single `index.html` file in a GitHub repo with Pages enabled. Deployment is manual: edit the file on GitHub or push a new version, Pages rebuilds automatically in ~60 seconds. The repo owner (tweezer2025) is not a developer — deployment needs to be as simple as possible.

## Hosting & Deployment

### Current Setup (Keep It Simple)
- GitHub Pages serves from the `main` branch, root directory
- File must be named `index.html`
- No build process — what you commit is what gets served
- SSL handled automatically by GitHub Pages
- Custom domain: not configured yet, but possible

### Deployment Workflow
1. Developer (or the repo owner) edits `index.html`
2. Commits to `main` branch
3. GitHub Pages auto-deploys within 60 seconds
4. Live at https://tweezer2025.github.io/concert-marker/

### Common Deployment Issues (From Experience)
- File named `index (2).html` instead of `index.html` — Pages won't find it
- Accidentally deleting `index.html` content during a GitHub web edit
- Pages not enabled in Settings (Branch must be set to `main`, folder to `/`)
- Caching: browser may show old version after deploy — hard refresh (Cmd+Shift+R) fixes it

## Future Scaling Options

### If the tool outgrows a single HTML file:
1. **Multi-file static site** — split CSS and JS into separate files, still on GitHub Pages
2. **Netlify or Vercel** — free tier, auto-deploys from GitHub, supports redirects and headers
3. **Custom domain** — point a domain like `tapermarkers.com` to GitHub Pages or Netlify

### If the tool needs a backend (e.g., shared marker database):
1. **Serverless functions** — Netlify Functions or Vercel Edge Functions for API endpoints
2. **Supabase or Firebase** — free tier database for storing/sharing marker files between tapers
3. **Keep the frontend static** — only add backend if there's a real need (shared markers, user accounts)

### If phish.in API has CORS issues:
1. **CORS proxy** — a simple serverless function that proxies requests to phish.in
2. **Pre-fetched data** — periodically fetch all Phish show data and bundle it with the app
3. **Manual entry remains the fallback** — always works, no API dependency

## Repository Structure

### Current (v1 — single file)
```
concert-marker/
├── index.html          # The entire app
└── README.md           # Project description
```

### Future (v2 — if splitting makes sense)
```
concert-marker/
├── index.html          # Main page
├── css/
│   └── style.css       # Dark theme styles
├── js/
│   ├── app.js          # Main application logic
│   ├── api.js          # phish.in API integration
│   ├── calculator.js   # Anchor point math
│   └── exporters/
│       ├── audition.js
│       ├── reaper.js
│       ├── audacity.js
│       ├── protools.js
│       └── generic.js
└── README.md
```

## GitHub Pages Configuration

### Settings Required
- Repository: Public (required for free GitHub Pages)
- Settings → Pages → Source: Deploy from a branch
- Branch: `main`
- Folder: `/ (root)`

### DNS (If Custom Domain Later)
- Add CNAME file to repo root with the domain name
- Configure DNS: CNAME record pointing to `tweezer2025.github.io`
- Enable "Enforce HTTPS" in Pages settings

## Monitoring & Reliability
- GitHub Pages has 99.9%+ uptime — no monitoring needed for v1
- If the phish.in API goes down, manual entry still works — the tool is resilient by design
- No user data is stored server-side — nothing to back up
- localStorage data (gear presets) lives in the user's browser only

## Security
- No sensitive data — no API keys, no user credentials, no payment info
- phish.in API is public and free — no secrets to protect
- GitHub Pages serves over HTTPS automatically
- No form submissions to a server — everything is client-side
- Content Security Policy: not critical for v1 but good practice if the app grows

## CI/CD (If Needed Later)
For v1, no CI/CD is needed — manual commits work fine. If the project grows:

```yaml
# .github/workflows/deploy.yml (only if we add a build step)
name: Deploy to GitHub Pages
on:
  push:
    branches: [main]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Validate HTML
        run: npx html-validate index.html
      - name: Deploy
        uses: peaceiris/actions-gh-pages@v3
        with:
          github_token: ${{ secrets.GITHUB_TOKEN }}
          publish_dir: ./
```

## Critical Rules
- Keep deployment dead simple — the repo owner is a concert taper, not a DevOps engineer
- The app must work as a static file — no server dependencies
- GitHub Pages is the right choice for v1 — don't over-engineer
- If something breaks, the fix is always: "upload the correct index.html and commit"
- Document the deployment steps clearly in the README for when someone else needs to update the site

## Success Metrics
- Site loads in under 2 seconds on any connection
- Zero downtime (GitHub Pages handles this)
- Deployment takes under 2 minutes from code change to live
- The repo owner can update the site without developer help
