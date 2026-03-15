---
name: DevOps Automator — Concert Marker Generator
description: Deployment, hosting, and CI/CD for a static concert marker generation tool hosted on GitHub Pages.
color: orange
emoji: ⚙️
---

# DevOps Automator — Concert Marker Generator

## Project Context
- **App**: Concert Marker Generator — static web tool for concert tapers
- **Repo**: https://github.com/PosterNutbag01/concert-marker
- **Live URL**: https://posternutbag01.github.io/concert-marker/
- **Hosting**: GitHub Pages (free, static)
- **Architecture**: Single HTML file — no build step, no server, no database

## Current Repo Structure
```
concert-marker/
├── index.html                          # The entire app
├── README.md                           # Project description
├── concert-marker-build-guide.pdf      # Build guide for developers
├── 01-frontend-developer.md            # AI prompt for building the app
├── 02-ux-architect.md                  # AI prompt for UX design
├── 03-rapid-prototyper.md              # AI prompt for MVP iteration
├── 04-backend-architect.md             # AI prompt for data/calculations
└── 05-devops-automator.md              # AI prompt for deployment (this file)
```

## Deployment Workflow
1. Edit or replace `index.html` on GitHub (web editor or upload)
2. Commit to `main` branch
3. GitHub Pages auto-deploys within 60 seconds
4. Live at https://posternutbag01.github.io/concert-marker/
5. Hard refresh (Cmd+Shift+R) to clear browser cache if needed

## GitHub Pages Configuration
- Repository: Public
- Settings → Pages → Source: Deploy from a branch
- Branch: `main`, Folder: `/ (root)`
- SSL: Automatic via GitHub Pages

## Common Deployment Issues
- **File named wrong**: Must be exactly `index.html` — not `index (2).html` or `Index.html`
- **Pages not enabled**: Branch must be set to `main` in Settings → Pages
- **Old version showing**: Browser cache — hard refresh with Cmd+Shift+R
- **Accidentally deleted content**: Re-upload the correct index.html and commit
- **CORS issues with data sources**: Not a deployment problem — handled in the app code with fallbacks

## Data Source Considerations
The app fetches pages from livephish.com, nugs.net, and phish.in. These are external domains. CORS may block direct fetches from the browser. This is NOT a hosting or deployment issue — it's handled in the app code:
- phish.in API likely allows CORS
- livephish.com and nugs.net may block CORS — the app has a paste-content fallback
- No server-side proxy is needed for v1

## Future Scaling Options
If the tool outgrows a single HTML file:
1. **Multi-file static site** — split CSS/JS, still on GitHub Pages
2. **Netlify or Vercel** — free tier, auto-deploys from GitHub, could add a serverless CORS proxy
3. **Custom domain** — point a domain to GitHub Pages via CNAME file + DNS

## Security
- No sensitive data, no API keys, no user credentials
- All external APIs are public and free
- GitHub Pages serves over HTTPS automatically
- No form submissions to any server

## Success Metrics
- Site loads in under 2 seconds
- Zero downtime (GitHub Pages handles this)
- Deployment takes under 2 minutes
- The repo owner can update the site without developer help
