# AdCraft AI — Hyper-Engine v2.0

**Designed & Developed by Nikhil Chary Sriramoju**
AI Architect & Full-Stack Engineer
GitHub: https://github.com/Nikhil-creat
LinkedIn: https://in.linkedin.com/in/nikhil-chary-sriramoju-95041b38a
Email: nikhilsriramoju66@gmail.com

---

## What's in this .zip

| File | What it is |
|---|---|
| `index.html` | The full interactive app. Open it in any browser — no install, no server needed. (Named `index.html` so GitHub Pages serves it at your repo's root URL automatically.) |
| `manifest.json` | Makes the app installable as a PWA ("Add to Home Screen" on phones). |
| `sw.js` | Service worker — caches the app shell so it keeps working offline after the first visit. |
| `ARCHITECTURE.md` | The production-grade backend blueprint (Prisma schema, API routes, agentic orchestration, RAG, CNN, Docker deployment) this app is modeled on. |
| `Dockerfile` | Container build for the Node.js API Gateway. |
| `Dockerfile.worker` | Container build for the Python render worker. |
| `cnn-worker/Dockerfile` + `cnn-worker/requirements.txt` | Container build for the production CNN inference microservice (PyTorch/MobileNet). |
| `docker-compose.yml` | One-command orchestration of frontend + API + worker + CNN service + RAG vector DB + Postgres + Redis. |
| `README.md` | This file. |

## Key features (all working, no fake buttons)

- **Neural Concept Engine** — enter a brand name + value prop, get 3 distinct creative angles (Humorous, Direct Response, Minimalist Premium).
- **Real RAG (Retrieval-Augmented Generation)** — a local knowledge base of proven ad-copy formulas is genuinely searched via keyword/term-overlap scoring, and the best match grounds your Direct-Response headline. Runs client-side, zero network calls, zero fake numbers.
- **Real CNN logo analysis** — upload a logo; a genuine MobileNet convolutional neural network (TensorFlow.js, on-device inference via WebGL) classifies it and returns real confidence scores, while a real pixel-histogram pass extracts dominant colors you can apply to your palette in one tap.
- **Autonomous QA Agent** — after generating a campaign, the QA agent computes the real average accessibility score; if it's below threshold, it independently retries with a higher-contrast palette before showing you the result — a genuine decide-and-retry loop.
- **4 trending visual styles** — Cyberpunk Neon, Glassmorphism Premium, Gradient Mesh Editorial, Minimal Luxury — all procedurally rendered, no stock templates.
- **Dynamic Aspect-Ratio Reflow** — 1:1 feed, 9:16 reels/stories, 16:9 banner, reflowed instantly.
- **Real accessibility scoring** — genuine WCAG contrast-ratio math.
- **Downloadable PNG / animated GIF / batch ZIP export** — one-click downloads, all genuinely generated client-side.
- **Campaign history** — every generation auto-saves to your browser (🕘 icon).
- **Creative JSON schema viewer** — inspect/copy the exact structured spec, including the RAG source and QA agent's decision trace, behind every campaign.
- **Docker-ready backend** — full production stack including a RAG vector DB and CNN inference service, one command: `docker compose up --build`.
- **Help & Feedback panel** (`?` icon, top right) — feature guide, FAQ, and a direct feedback form to the developer.
- Every exported asset is watermarked "AdCraft AI · N. Sriramoju" and the app footer credits Nikhil Chary Sriramoju with live links.

## Performance & power upgrades

- **Lazy-loaded libraries** — the GIF and ZIP engines (gif.js, JSZip) only download when you actually click those export buttons, not on page load — faster first paint.
- **Battery-aware background animation** — the shader particle field pauses automatically when you switch tabs, and runs fewer particles on small screens.
- **Installable PWA** — "Add to Home Screen" on mobile, works offline after the first visit (via `manifest.json` + `sw.js`).
- **Keyboard shortcuts** — `Ctrl/Cmd + Enter` to generate, `Ctrl/Cmd + S` to export PNG, `Esc` to close any panel.
- **Auto-saved draft inputs** — your brand name/value prop/URL persist across reloads automatically.
- **Debounced resize handling** and squared-distance math in the particle field (skips expensive sqrt calls) for smoother animation on low-power devices.

## How to run it

Just double-click `adcraft-ai.html`, or drag it into any browser tab. It needs an internet connection only to load fonts and the GIF-encoding library from a CDN — everything else runs locally in your browser.

---

## How to upload this to GitHub (step-by-step)

### Option A — no terminal, using the GitHub website (easiest)

1. Go to https://github.com and log in (create a free account if you don't have one).
2. Click the **+** icon top-right → **New repository**.
3. Name it something like `adcraft-ai` → set it **Public** (so it can be hosted for free) → click **Create repository**.
4. On the new repo page, click **"uploading an existing file"** (or **Add file → Upload files**).
5. Drag in `adcraft-ai.html`, `ARCHITECTURE.md`, and `README.md` from this folder.
6. Scroll down, add a commit message like `Initial commit — AdCraft AI Hyper-Engine`, click **Commit changes**.

Your code is now on GitHub. To make the app viewable as a live website (not just code):

7. In your repo, go to **Settings → Pages** (left sidebar).
8. Under "Build and deployment" → **Source**, choose **Deploy from a branch**.
9. Branch: `main`, folder: `/ (root)` → **Save**.
10. Wait ~1 minute, then refresh the Pages settings tab — you'll see a live URL like:
    `https://Nikhil-creat.github.io/adcraft-ai/adcraft-ai.html`
11. That link now works for anyone, on any device — share it.

### Option B — using Git on your computer (if you have Git installed)

```bash
# 1. Create the folder and move the files in
mkdir adcraft-ai && cd adcraft-ai
# (copy adcraft-ai.html, ARCHITECTURE.md, README.md into this folder)

# 2. Initialize git and make your first commit
git init
git add .
git commit -m "Initial commit — AdCraft AI Hyper-Engine v2.0"

# 3. Create the repo on GitHub first (github.com → New repository → same name, no README),
#    then connect it:
git branch -M main
git remote add origin https://github.com/Nikhil-creat/adcraft-ai.git
git push -u origin main
```

Then repeat steps 7–11 from Option A to turn on GitHub Pages.

### Option C — GitHub Desktop (GUI, no command line)

1. Install GitHub Desktop: https://desktop.github.com
2. Sign in with your GitHub account.
3. **File → New Repository**, name it `adcraft-ai`, point it at this folder.
4. Click **Publish repository** (top bar) → choose Public.
5. Then follow steps 7–11 above to enable GitHub Pages.

---

*Questions or want a feature added? Open the app, click the `?` icon top-right, and send feedback directly — or email nikhilsriramoju66@gmail.com.*
